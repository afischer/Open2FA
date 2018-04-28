//
//  TokenWatchRow.m
//  Open2FA Watch Extension
//
//  Created by Andrew Fischer on 4/25/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "TokenWatchRow.h"
#import "TokenCode.h"

@interface TokenWatchRow ()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tokenLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *issuerLabel;
@end

@implementation TokenWatchRow
- (void)setToken:(Token *)token {
    TokenCode *code = token.code;
    [self.tokenLabel setText:code.currentCode];
    [self.issuerLabel setText:token.issuer];
}
@end
