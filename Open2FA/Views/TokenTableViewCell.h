//
//  TokenTableViewCell.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/10/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Token.h"

@interface TokenTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *tokenText;
@property (strong, nonatomic) IBOutlet UILabel *issuerLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *timeProgress;
@property (strong, nonatomic) IBOutlet UILabel *accountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoView;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;

- (void)setToken:(Token *)token;
- (void)setProgressVisibility:(BOOL)visibile;
@end
