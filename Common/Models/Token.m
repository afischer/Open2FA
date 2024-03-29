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
#import "TokenStore.h"
#import "CDFInitialsAvatar.h"


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

NSString *const storePrefix = @"me.andrewfischer.Open2FA.token:";

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
  
  if (!uri)
    return nil;
  
  // set defaults, will be overwritten by query params if present
  self.period = 30;
  self.digits = 6;
  self.counter = 0;
  self.algorithm = kCCHmacAlgSHA1;
  
  // SCHEME PARSING
  if (![[uri scheme] isEqualToString:@"otpauth"])
    return nil;

  // get type
  self.type = [uri host];
  if (![[Token supportedTypes] containsObject:self.type])
    return nil;

  // PATH PARSING
  NSString *path = [uri path];
  if (!path || [path isEqualToString:@""])
    return nil;
  while ([path hasPrefix:@"/"])
    path = [path substringFromIndex:1];
  if ([path length] == 0)
    return nil;

  // get account, issuer if exists
  NSArray *pathComponents = [path componentsSeparatedByString:@":"];
  if (pathComponents == nil || [pathComponents count] == 0)
    return nil;
  if ([pathComponents count] > 1) {
    self.issuer = [[pathComponents objectAtIndex:0] urlDecodedString];
    self.account = [[pathComponents objectAtIndex:1] urlDecodedString];
  } else {
    self.account = [[pathComponents objectAtIndex:0] urlDecodedString];
  }

  // parse query items
  NSURLComponents *components = [[NSURLComponents alloc] initWithURL:uri
                                             resolvingAgainstBaseURL:NO];
  
  for (NSURLQueryItem *item in [components queryItems]) {
    if ([item.name isEqualToString:@"secret"]) {          // SECRET
      secretStr = item.value;
      secret = [NSData dataWithBase32String:item.value];
    } else if ([item.name isEqualToString:@"algorithm"]) {
      CCHmacAlgorithm alg = [item.value hmacAlgorithm];
      self.algorithm = alg == -1 ? kCCHmacAlgSHA1 : alg; // default to sha1
    } else if ([item.name isEqualToString:@"period"]) {
      NSString *p = item.value;
      self.period = p == 0 ? 30 : (int)[p integerValue]; // fix malformed period
    } else if ([item.name isEqualToString:@"issuer"]) {
      // TODO: if this is not equal to self.issuer, warn user
    } else if ([item.name isEqualToString:@"digits"]) {
      NSString *d = item.value;
      self.digits = d == 0 ? 6 : (int)[d integerValue];  // fix malformed digits
    } else if ([item.name isEqualToString:@"counter"]) {
      if ([self.type isEqualToString:@"hotp"])
        self.counter = [item.value longLongValue];
    }
  }
  // fail if no secret
  if (secret == nil)
    return nil;

  return self;
}

- (id)initWithType:(NSString *)method
              Issuer:(NSString *)issuer
             Account:(NSString *)account
              Secret:(NSString *)secret {
  NSString *uri = [NSString stringWithFormat:@"otpauth://%@/%@:%@?&secret=%@",
                                             method, [issuer urlDecodedString],
                                             [account urlDecodedString], secret];

  return [self initWithURI:[NSURL URLWithString:uri]];
}

- (NSString *)uid {
  return [NSString stringWithFormat:@"%@%@:%@", storePrefix,
       [self.issuer urlEncodedString], [self.account urlEncodedString]];
}

- (NSString *)tokenURI {

  NSString *uri = [NSString
      stringWithFormat:@"otpauth://%@/"
                       @"%@:%@?algorithm=%s&digits=%lu&secret=%@&issuer=%@&"
                       @"period=%u",
                       self.type, [self.issuer urlEncodedString], [self.account urlEncodedString],
                       unparseAlgo(self.algorithm), (unsigned long)self.digits,
                       secretStr, [self.issuer urlEncodedString], self.period];
  if ([self.type isEqualToString:@"hotp"]) {
    uri = [NSString stringWithFormat:@"%@&counter=%llu", uri, self.counter];
  }
  return uri;
}

- (NSString *)getOTP {
  if ([self.type isEqualToString:@"hotp"]) {
    NSString *otp = [self codeWithCount:self.counter];
    self.counter += 1;
    TokenStore *store = [[TokenStore alloc] init];
    [store updateToken:self];
    return otp;
  } else {
    return [self getOTPForDate:[NSDate date]]; // totp for current time
  }
  
  return [self getOTPForDate:[NSDate date]];
}

- (NSString *)getOTPForDate:(NSDate *)date {
  if ([self.type isEqualToString:@"hotp"]) {
    return [self codeWithCount:self.counter++];
  } else {
    // calculate counter for totp
    NSTimeInterval seconds = [date timeIntervalSince1970];
    uint64_t counter = (uint64_t)(seconds / self.period);
    return [self codeWithCount:counter];
  }
}


- (NSString *)codeWithCount:(uint64_t)counter {
  uint64_t now = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
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
  

//  NSLog(@"secret: %@", secret);
//  NSLog(@"counter: %llu", counter);
//  NSLog(@"hash: %@", hash);
//  NSLog(@"offset: %d", offset);
//  NSLog(@"truncatedHash: %d", binary);
//  NSLog(@"otp: %d", otp);
  
  tokenStart = now - (now % (self.period * 1000)); // round to nearest T0
  tokenEnd = tokenStart + (self.period * 1000);
  currCode = [NSString stringWithFormat:@"%0*u", (int)self.digits, otp];
  
  return currCode;
}

- (UIImage *) getImage {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  NSString *path = [NSString stringWithFormat:@"%@/%@.png", basePath, self.uid];

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    return [UIImage imageWithContentsOfFile:path];;
  }
  
  CDFInitialsAvatar *avatar = [[CDFInitialsAvatar alloc]
                               initWithRect:CGRectMake(0, 0, 75, 75)
                                   fullName:self.issuer];
  [avatar setInitialsFont: [UIFont fontWithName:@"ArialRoundedMTBold"
                                           size:18]];
 
  UIImage *avatarImg = avatar.imageRepresentation;
  
  NSData *imgData = UIImagePNGRepresentation(avatarImg);
  NSString *imgName = [NSString stringWithFormat:@"%@.png", self.uid];
  [imgData writeToFile:[basePath stringByAppendingPathComponent:imgName]
            atomically:YES];

  return avatarImg;
}

- (float)progress {
  uint64_t now = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
  
  float timeRemaining = ((float)(tokenEnd - now) / 1000) / self.period;
  if (timeRemaining > 1) // need new token
    return 0.0;
  else
    return timeRemaining;
  
  return 0.0;
}

// override for print debugging
- (NSString *) description {
  return [NSString stringWithFormat:@"%@ issuer: `%@` period: `%u`", [super description], self.issuer, self.period];
}

@end
