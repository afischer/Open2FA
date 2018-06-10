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

@implementation TokenTableViewCell
- (void)awakeFromNib { // Initialization code
  [super awakeFromNib];
  [self.timeProgress setProgressTintColor:[UIColor colorNamed:@"greenColor"]];
}

- (void)setSelected:(BOOL)selected // Configure the view for the selected state
           animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setToken:(Token *)token {
  self.cellToken = token;
  NSString *otp = [self.cellToken getOTP];
  self.tokenText.text = otp;
  self.issuerLabel.text = self.cellToken.issuer;
  self.accountLabel.text = self.cellToken.account;
  self.logoView.layer.cornerRadius = (CGFloat)self.logoView.bounds.size.width/2;
  self.logoView.clipsToBounds = YES;
  self.showsReorderControl = YES;
  self.logoView.image = self.cellToken.getImage;
  
  UIFont *mono = [UIFont monospacedDigitSystemFontOfSize:30.0
                                                  weight:UIFontWeightSemibold];
  self.tokenText.font = mono;
  
  if ([self.cellToken.type isEqualToString:@"hotp"]) {
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
  float tokenProgress = [self.cellToken progress];
  BOOL restarted = tokenProgress == 0.0;
  [self.timeProgress setProgress:tokenProgress animated:tokenProgress < 0.01f];
  if (tokenProgress < 0.1f) {
    [self.timeProgress setProgressTintColor:[UIColor colorNamed:@"warningColor"]];
  }
  if (restarted) {
    NSLog(@"New token!");
    self.tokenText.text = self.cellToken.getOTP;
    [self.timeProgress setProgressTintColor:[UIColor colorNamed:@"greenColor"]];
  }
}

- (void)setProgressVisibility:(BOOL)visibile {
  [self.timeProgress setHidden:!visibile];
}

- (IBAction)hotpDidRefresh:(id)sender {
  NSLog(@"new hotp");
  // TODO: NEED TO RETAIN COUNTER
  self.tokenText.text = self.cellToken.getOTP;
  
}

@end
