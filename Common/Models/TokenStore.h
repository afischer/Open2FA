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

@interface TokenStore : NSObject
- (NSUInteger)count;
- (void)add:(Token*)token;
- (void)add:(Token*)token atIndex:(NSUInteger)index;
- (Token*)get:(NSUInteger)index;
- (void)del:(NSUInteger)index;
- (void)syncToWatch;
@end
