//
//  NSString+Open2FA.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/16/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "NSString+Open2FA.h"

@implementation NSString (Open2FA)

- (NSString *) percentEncoded {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (CCHmacAlgorithm) hmacAlgorithm {
  NSString *algoStr = [self lowercaseString];
  if ([algoStr isEqualToString:@"sha1"]) {
    return kCCHmacAlgSHA1;
  } else if ([algoStr isEqualToString:@"md5"]) {
    return kCCHmacAlgMD5;
  } else if ([algoStr isEqualToString:@"sha256"]) {
    return kCCHmacAlgSHA256;
  } else if ([algoStr isEqualToString:@"sha384"]) {
    return kCCHmacAlgSHA384;
  } else if ([algoStr isEqualToString:@"sha256"]) {
    return kCCHmacAlgSHA512;
  } else if ([algoStr isEqualToString:@"sha224"]) {
    return kCCHmacAlgSHA224;
  }
  return -1;
}

@end
