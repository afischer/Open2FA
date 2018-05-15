//
//  Token.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/3/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//

#import "Base32.h"
#import "NSString+Open2FA.h"

#import <CommonCrypto/CommonHMAC.h>

@interface Token : NSObject

@property (nonatomic) NSString* issuer;
@property (nonatomic) NSString* label;
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* account;
@property (nonatomic) CCHmacAlgorithm algorithm;
@property (nonatomic) NSUInteger digits;
@property (nonatomic, readonly) NSString* uid;
@property (nonatomic) uint32_t period;
@property (nonatomic) uint64_t counter;
+ (NSArray *) supportedTypes;
- (NSString *)getOTP;
- (NSString *)getOTPForDate:(NSDate *)date;
- (float)progress;
- (id)initWithURI:(NSURL *)uri;
- (id)initWithType:(NSString *)method
              Issuer:(NSString *)issuer
             Account:(NSString *)account
              Secret:(NSString *)secret;
- (NSString *)tokenURI;
@end
