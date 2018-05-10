//
//  Token.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/3/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//

#import "Token.h"
#import <sys/time.h>

static NSString *getOTP(CCHmacAlgorithm algo, uint8_t digits, NSData *key,
                        uint64_t counter) {

#ifdef __LITTLE_ENDIAN__
  // Network byte order
  counter = (((uint64_t)htonl(counter)) << 32) + htonl(counter >> 32);
#endif

  // Create digits divisor
  uint32_t div = 1;
  for (int i = digits; i > 0; i--)
    div *= 10;

  // Create the HMAC
  size_t digestLen;
  switch (algo) {
  case kCCHmacAlgMD5:
    digestLen = CC_MD5_DIGEST_LENGTH;
  case kCCHmacAlgSHA256:
    digestLen = CC_SHA256_DIGEST_LENGTH;
  case kCCHmacAlgSHA512:
    digestLen = CC_SHA512_DIGEST_LENGTH;
  case kCCHmacAlgSHA1:
  default:
    digestLen = CC_SHA1_DIGEST_LENGTH;
  }

  uint8_t digest[digestLen];
  CCHmac(algo, [key bytes], [key length], &counter, sizeof(counter), digest);

  // Truncate
  uint32_t binary;
  uint32_t off = digest[sizeof(digest) - 1] & 0xf;
  binary = (digest[off + 0] & 0x7f) << 0x18;
  binary |= (digest[off + 1] & 0xff) << 0x10;
  binary |= (digest[off + 2] & 0xff) << 0x08;
  binary |= (digest[off + 3] & 0xff) << 0x00;
  binary = binary % div;

  return [NSString
      stringWithFormat:[NSString stringWithFormat:@"%%0%hhulu", digits],
                       binary];
}

static CCHmacAlgorithm parseAlgo(const NSString *algo) {
  static struct {
    const char *name;
    CCHmacAlgorithm num;
  } algomap[] = {
      {"md5", kCCHmacAlgMD5},
      {"sha1", kCCHmacAlgSHA1},
      {"sha256", kCCHmacAlgSHA256},
      {"sha512", kCCHmacAlgSHA512},
  };
  if (algo == nil)
    return kCCHmacAlgSHA1;

  const char *calgo = [algo cStringUsingEncoding:NSUTF8StringEncoding];
  if (calgo == NULL)
    return kCCHmacAlgSHA1;
  for (int i = 0; i < sizeof(algomap) / sizeof(algomap[0]); i++) {
    if (strcasecmp(calgo, algomap[i].name) == 0)
      return algomap[i].num;
  }

  return kCCHmacAlgSHA1; // fallback to sha1
}

static inline const char *unparseAlgo(CCHmacAlgorithm algo) {
  switch (algo) {
  case kCCHmacAlgMD5:
    return "md5";
  case kCCHmacAlgSHA256:
    return "sha256";
  case kCCHmacAlgSHA512:
    return "sha512";
  case kCCHmacAlgSHA1:
  default:
    return "sha1";
  }
}

@implementation Token {
  NSData *secret;
}

+ (NSArray *)supportedMethods {
  NSArray *methods = [NSArray arrayWithObjects:@"totp", @"htop", nil];
  return methods;
}

- (id)initWithURI:(NSURL *)uri {
  self = [super init];

  // SCHEME PARSING
  if (![[uri scheme] isEqualToString:@"otpauth"])
    return nil;

  // get method
  self.method = [uri host];
  if (![[Token supportedMethods] containsObject:self.method])
    return nil;

  // PATH PARSING
  NSString *path = [uri path];
  if (!path)
    return nil;
  while ([path hasPrefix:@"/"])
    path = [path substringFromIndex:1];
  if ([path length] == 0)
    return nil;

  // get label, issuer if exists
  NSArray *pathComponents = [path componentsSeparatedByString:@":"];
  NSLog(@"Path components %@", pathComponents);
  if (pathComponents == nil || [pathComponents count] == 0)
    return nil;
  if ([pathComponents count] > 1) {
    self.issuer = [pathComponents objectAtIndex:0];
    self.account = [pathComponents objectAtIndex:1];
  } else {
    self.account = [pathComponents objectAtIndex:0];
  }

  // Parse query
  NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
  pathComponents = [[uri query] componentsSeparatedByString:@"&"];
  for (NSString *kv in pathComponents) {
    NSArray *tmp = [kv componentsSeparatedByString:@"="];
    if (tmp.count != 2)
      continue;
    [query setValue:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
  }

  secret = [NSData dataWithBase32String:[query objectForKey:@"secret"]];
  NSLog(@"SECRET PARSED: %@", secret);
  if (secret == nil)
    return nil;

  // Get algorithm and digits
  self.algorithm = parseAlgo([query objectForKey:@"algorithm"]);
  if (unparseAlgo(self.algorithm) == nil) {
    // THROW BAD ERROR BAD bad!
  }
  //    self.digits = [query objectForKey:@"digits"];

  // Get period
  NSString *p = [query objectForKey:@"period"];
  self.period = p != nil ? (int)[p integerValue] : 30;
  if (self.period == 0)
    self.period = 30;

  // Get issuer query string
  if (self.issuer == nil) {
    self.issuer = [query
        objectForKey:@"query"]; // THROW WARNING IF NOT EQUAL TO ISSUER ALREADY
  }

  NSString *d = [query objectForKey:@"digits"];
  self.digits = d != nil ? (int)[d integerValue] : 6;
  if (self.digits == 0)
    self.digits = 6;

  // Get counter
  if ([self.method isEqualToString:@"hotp"]) {
    NSString *c = [query objectForKey:@"counter"];
    self.counter = c != nil ? [c longLongValue] : 0;
  }

  NSLog(@"INITIALIZING TOKEN");
  NSLog(@"%@, %u, %@, %@", self.issuer, self.algorithm, self.account,
        self.method);
  return self;
}

- (id)initWithMethod:(NSString *)method
              Issuer:(NSString *)issuer
             Account:(NSString *)account
              Secret:(NSString *)secret {
  NSString *uri = [NSString stringWithFormat:@"otpauth://%@/%@:%@?&secret=%@",
                                             method, [issuer percentEncoded],
                                             [account percentEncoded], secret];
  NSLog(@"THE UR I IS %@", uri);
  return [self initWithURI:[NSURL URLWithString:uri]];
}

- (NSString *)uid { // FIX THIS
  NSString *uidStr =
      [NSString stringWithFormat:@"%@:%@", self.issuer, self.method];
  return [uidStr stringByAddingPercentEncodingWithAllowedCharacters:
                     [NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)tokenURI {

  NSString *uri = [NSString
      stringWithFormat:@"otpauth://%@/"
                       @"%@:%@?algorithm=%s&digits=%lu&secret=%@&issuer=%@&"
                       @"period=%u",
                       self.method, self.issuer, self.account,
                       unparseAlgo(self.algorithm), (unsigned long)self.digits,
                       [secret base32String], self.issuer, self.period];
  NSLog(@"GETTING URI %@", uri);
  return [uri stringByAddingPercentEncodingWithAllowedCharacters:
                  [NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (TokenCode *)code {
  time_t now = time(NULL);
  if (now == (time_t)-1)
    now = 0;

  if ([self.method isEqualToString:@"hotp"]) {
    // TODO: All algorithms
    NSString *code =
        getOTP(self.algorithm, self.digits, secret, self.counter++);
    return [[TokenCode alloc] initWithCode:code
                                 startTime:now
                                   endTime:now + self.period];
  }

  TokenCode *next = [[TokenCode alloc]
      initWithCode:getOTP(self.algorithm, self.digits, secret,
                          now / self.period + 1)

         startTime:now / self.period * self.period + self.period

           endTime:now / self.period * self.period + self.period + self.period];
  NSLog(@"hi");

  return [[TokenCode alloc]
       initWithCode:getOTP(self.algorithm, self.digits, secret,
                           now / self.period)
          startTime:now / self.period * self.period
            endTime:now / self.period * self.period + self.period
      nextTokenCode:next];
}
@end
