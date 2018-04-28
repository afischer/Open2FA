//
//  TokenTableViewCell.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/10/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "TokenTableViewCell.h"
#import "UIColor+Open2FA.h"

#import <QuartzCore/QuartzCore.h>


@implementation TokenTableViewCell {
    Token *tok;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setToken:(Token *)token {
    tok = token;
    self.tokenText.text = tok.code.currentCode;
    self.issuerLabel.text = tok.issuer;
    self.accountLabel.text = tok.account;
    self.logoView.layer.cornerRadius = (CGFloat)8.f;
    self.logoView.clipsToBounds = YES;
    self.logoView.image = [UIImage imageNamed:@"DPLogo"];
    UIFont *sfMonoDig = [UIFont monospacedDigitSystemFontOfSize:38.0
                                                         weight:UIFontWeightMedium];
 
    self.tokenText.font = sfMonoDig;
    
    
    [NSTimer scheduledTimerWithTimeInterval: 1.f
                                     target: self
                                   selector: @selector(updateProgress)
                                   userInfo: nil
                                    repeats: YES];
}

- (void)updateProgress {
    NSLog(@"updating");
    float tokenProgress = tok.code.currentProgress;
    BOOL restarted = self.timeProgress.progress < tokenProgress;
    [self.timeProgress setProgress:tokenProgress animated:!restarted];
    if (tokenProgress < 0.1f) {
        [self.timeProgress setProgressTintColor:[UIColor warningColor]];
    }
    if (restarted) {
        self.tokenText.text = tok.code.currentCode;
        [self.timeProgress setProgressTintColor:[UIColor tintColor]];
    }
}


- (void)setProgressVisibility:(BOOL)visibile {
    [self.timeProgress setHidden:!visibile];
}
@end
