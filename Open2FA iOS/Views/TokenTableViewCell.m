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
  NSString *otp = [tok getOTP];
  NSLog(@"GETTING AN OTP: %@", otp);
  self.tokenText.text = otp;
  self.issuerLabel.text = tok.issuer;
  self.accountLabel.text = tok.account;
  self.logoView.layer.cornerRadius = (CGFloat)self.logoView.bounds.size.width/2;
  self.logoView.clipsToBounds = YES;
//  self.logoView.image = [UIImage imageNamed:@"DPLogo"];

  self.tokenText.font = [UIFont monospacedDigitSystemFontOfSize:30.0 weight:UIFontWeightSemibold];
  
  if ([tok.type isEqualToString:@"hotp"]) {
    self.refreshButton.hidden = NO;
    self.timeProgress.hidden = YES;
  } else {
    [NSTimer scheduledTimerWithTimeInterval:1.f
                                     target:self
                                   selector:@selector(updateProgress)
                                   userInfo:nil
                                    repeats:YES];
  }
  
}

- (void)updateProgress {
  float tokenProgress = [tok progress];
  BOOL restarted = tokenProgress == 0.0;
  [self.timeProgress setProgress:tokenProgress animated:tokenProgress < 0.01f];
  if (tokenProgress < 0.1f) {
    [self.timeProgress setProgressTintColor:[UIColor warningColor]];
  }
  if (restarted) {
    NSLog(@"New token!");
    self.tokenText.text = tok.getOTP;
    [self.timeProgress setProgressTintColor:[UIColor tintColor]];
  }
}

- (void)setProgressVisibility:(BOOL)visibile {
  [self.timeProgress setHidden:!visibile];
}

- (IBAction)hotpDidRefresh:(id)sender {
  NSLog(@"new hotp");
  self.tokenText.text = tok.getOTP;
}

@end
