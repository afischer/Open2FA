//
//  NSString+Open2FA.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/16/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "NSString+Open2FA.h"

@implementation NSString (Open2FA)

//- (NSData*) asBase32Data {
//    uint8_t key[4096];
//    if (self == nil)
//        return nil;
//    const char *tmp = [self cStringUsingEncoding:NSASCIIStringEncoding];
//    if (tmp == NULL)
//        return nil;
//
//    int res = base32_decode(tmp, key, sizeof(key));
//    if (res < 0 || res == sizeof(key))
//        return nil;
//    
//    return [NSData dataWithBytes:key length:res];
//}

- (NSString *) percentEncoded {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}
@end
