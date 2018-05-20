//
//  NSString+Open2FA.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/16/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Base32.h"

@interface NSString (Open2FA)
- (NSString *) urlEncodedString;
- (NSString *) urlDecodedString;
- (CCHmacAlgorithm) hmacAlgorithm;
@end
