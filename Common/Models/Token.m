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

static uint64_t currentTimeMillis() {
  struct timeval t;
  if (gettimeofday(&t, NULL) != 0)
    return 0;
  
  return t.tv_sec * 1000 + t.tv_usec / 1000;
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
  NSString *secretStr;
  uint64_t tokenStart;
  uint64_t tokenEnd;
  NSString *currCode;
}

+ (NSArray *)supportedTypes {
  NSArray *methods = [NSArray arrayWithObjects:@"totp", @"hotp", nil];
  return methods;
}

- (id)initWithURI:(NSURL *)uri {
  self = [super init];

  // SCHEME PARSING
  if (![[uri scheme] isEqualToString:@"otpauth"])
    return nil;

  // get type
  self.type = [uri host];
  if (![[Token supportedTypes] containsObject:self.type])
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
  NSURLComponents *components = [[NSURLComponents alloc] initWithURL:uri
                                             resolvingAgainstBaseURL:NO];
  
  NSLog(@"QUERY ITEMS: %@", [components queryItems]);
  for (NSURLQueryItem *item in [components queryItems]) {
    if ([item.name isEqualToString:@"secret"]) {
      secretStr = item.value;
      secret = [NSData dataWithBase32String:item.value];
    }
  }
  
  pathComponents = [[uri query] componentsSeparatedByString:@"&"];
  for (NSString *kv in pathComponents) {
    NSArray *tmp = [kv componentsSeparatedByString:@"="];
    if (tmp.count != 2)
      continue;
    [query setValue:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
  }
//
//  secretStr = [query objectForKey:@"secret"];
  
//  NSLog(@"SEcret tho? %@", query);
  NSLog(@"SECRET PARSED: %@", [secret base32String]);
  if (secret == nil)
    return nil;

  // Get algorithm and digits
  self.algorithm = [[query objectForKey:@"algorithm"] hmacAlgorithm];
  if (self.algorithm == -1) {
    self.algorithm = kCCHmacAlgSHA1;
  }

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
  if ([self.type isEqualToString:@"hotp"]) {
    NSString *c = [query objectForKey:@"counter"];
    self.counter = c != nil ? [c longLongValue] : 0;
  }


  return self;
}

- (id)initWithType:(NSString *)method
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
      [NSString stringWithFormat:@"%@:%@", self.issuer, self.type];
  return [uidStr stringByAddingPercentEncodingWithAllowedCharacters:
                     [NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)tokenURI {

  NSString *uri = [NSString
      stringWithFormat:@"otpauth://%@/"
                       @"%@:%@?algorithm=%s&digits=%lu&secret=%@&issuer=%@&"
                       @"period=%u",
                       self.type, self.issuer, self.account,
                       unparseAlgo(self.algorithm), (unsigned long)self.digits,
                       secretStr, self.issuer, self.period];
  NSLog(@"GETTING URI %@", uri);
  return [uri stringByAddingPercentEncodingWithAllowedCharacters:
                  [NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)getOTP {
  if ([self.type isEqualToString:@"hotp"]) {
    return [self codeWithCount:self.counter++];
  } else {
    return [self getOTPForDate:[NSDate date]]; // totp for current time
  }
  
  return [self getOTPForDate:[NSDate date]];
}

- (NSString *)getOTPForDate:(NSDate *)date {
  if ([self.type isEqualToString:@"hotp"]) {
    return [self codeWithCount:self.counter++];
  } else {
    // generate counter for totp
    NSTimeInterval seconds = [date timeIntervalSince1970];
    uint64_t counter = (uint64_t)(seconds / self.period);
    NSLog(@"We calculated the counter to be %llu", counter);
    return [self codeWithCount:counter];
  }
}


- (NSString *)codeWithCount:(uint64_t)counter {
  uint64_t now = currentTimeMillis();
  NSUInteger hashLength = 0;
  
  // mod table divisor
  uint32_t div = 1;
  for (NSUInteger i = self.digits; i > 0; i--)
    div *= 10;

  
  if (self.algorithm == kCCHmacAlgSHA1) {
    hashLength = CC_SHA1_DIGEST_LENGTH;
  } else if (self.algorithm == kCCHmacAlgSHA256) {
    hashLength = CC_SHA256_DIGEST_LENGTH;
  } else if (self.algorithm == kCCHmacAlgSHA512) {
    hashLength = CC_SHA512_DIGEST_LENGTH;
  } else if (self.algorithm == kCCHmacAlgMD5) {
    hashLength = CC_MD5_DIGEST_LENGTH;
  } else {
    return nil;
  }
  
  NSMutableData *hash = [NSMutableData dataWithLength:hashLength];
  
  counter = NSSwapHostLongLongToBig(counter); // fix endianness  
  CCHmac(self.algorithm, [secret bytes], [secret length], &counter, sizeof(counter), [hash mutableBytes]);

  const char *ptr = [hash bytes];
  
  uint32_t binary;
  uint32_t offset = ptr[hashLength - 1] & 0x0f;
  binary  = (ptr[offset + 0] & 0x7f) << 24;
  binary |= (ptr[offset + 1] & 0xff) << 16;
  binary |= (ptr[offset + 2] & 0xff) << 8;
  binary |= (ptr[offset + 3] & 0xff);
  uint32_t otp = binary % div;
  

  NSLog(@"secret: %@", secret);
  NSLog(@"counter: %llu", counter);
  NSLog(@"hash: %@", hash);
  NSLog(@"offset: %d", offset);
  NSLog(@"truncatedHash: %d", binary);
  NSLog(@"otp: %d", otp);
  
  tokenStart = now - (now % (self.period * 1000)); // round to nearest T0
  tokenEnd = tokenStart + (self.period * 1000);
  currCode = [NSString stringWithFormat:@"%0*u", (int)self.digits, otp];
  
  return currCode;
}

- (float)progress {
  uint64_t now = currentTimeMillis();
//  NSLog(@"NOW %llu START %llu ENED %llu", now, tokenStart, tokenEnd);
  
  float timeRemaining = (float)(tokenEnd - now) / 1000 / self.period;
  if (timeRemaining > 1) // need new token
    return 0.0;
  else
    return timeRemaining;
  
  return 0.0;
}

- (int)secondsLeft {
  uint64_t now = currentTimeMillis();
  return (float)(tokenEnd - now) / 1000;
}

@end
