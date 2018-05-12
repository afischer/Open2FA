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
@end
