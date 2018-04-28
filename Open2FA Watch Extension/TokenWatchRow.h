//
//  TokenWatchRow.h
//  Open2FA Watch Extension
//
//  Created by Andrew Fischer on 4/25/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "Token.h"

@interface TokenWatchRow : NSObject
- (void)setToken:(Token *)token;
@end
