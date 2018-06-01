//
//  TokenStore.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/10/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//

#import "Token.h"

extern NSString *const ORDER_KEY;

@interface TokenStore : NSObject
- (NSUInteger)count;
- (void)add:(Token*)token;
- (void)add:(Token*)token atIndex:(NSUInteger)index;
- (Token*)get:(NSUInteger)index;
- (void)deleteTokenAtIndex:(NSUInteger)index;
- (void)deleteToken:(Token *)token;
- (void) moveFrom:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex;
- (void) updateToken:(Token *)token;
- (void)clear;
@end
