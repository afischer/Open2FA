//
//  TokenWatchRow.m
//  Open2FA Watch Extension
//
//  Created by Andrew Fischer on 4/25/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "TokenWatchRow.h"

@interface TokenWatchRow ()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *issuerLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tokenLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *timer;
@property (weak, nonatomic) NSTimer *restartTimer;
@property (strong, nonatomic) Token *t;
@end

@implementation TokenWatchRow


- (float) tokenExpiry {
  return self.t.progress * (float) self.t.period;
}

- (void)setToken:(Token *)token {
  self.t = token;
  [self.issuerLabel setText:self.t.issuer];
  [self.tokenLabel setText:self.t.getOTP];

  float remaining = [self tokenExpiry];
  self.restartTimer = [NSTimer scheduledTimerWithTimeInterval:remaining
                                                       target:self
                                                     selector:@selector(timerFireMethod:)
                                                     userInfo:nil
                                                      repeats:YES];
  
  [self.timer setDate:[NSDate dateWithTimeIntervalSinceNow:remaining]];
  [self.timer start];

  [self.imageView setImage:self.t.getImage];
}


- (void)timerFireMethod:(NSTimer *)timer {
  [self.restartTimer invalidate];
  float remaining = [self tokenExpiry];
  [self.tokenLabel setText:self.t.getOTP];
  self.restartTimer = [NSTimer scheduledTimerWithTimeInterval:remaining
                                           target:self
                                         selector:@selector(timerFireMethod:)
                                         userInfo:nil
                                          repeats:YES];
  
  [self.timer setDate:[NSDate dateWithTimeIntervalSinceNow:remaining]];
  [self.timer start];

}
@end
