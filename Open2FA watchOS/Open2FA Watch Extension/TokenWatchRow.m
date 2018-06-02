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
@property (strong, nonatomic) NSTimer *restartTimer;
@property (strong, nonatomic) Token *t;
@end

@implementation TokenWatchRow




- (void)setToken:(Token *)token {
  self.t = token;
  // NOT REALLY ACCURATE AS WE NEED TIME LEFT ON TOKEN SINCE LAST INTERVAL
  self.restartTimer = [NSTimer scheduledTimerWithTimeInterval:self.t.period
                                                       target:self
                                                     selector:@selector(restart)
                                                     userInfo:nil
                                                      repeats:YES];
  
  [self.imageView setImage:self.t.getImage];
  [self setLabels];
}
  

- (void) setLabels {
  [self.timer setDate:[NSDate dateWithTimeIntervalSinceNow:self.t.period]];
  [self.timer start];

  [self.tokenLabel setText:self.t.getOTP];
  [self.issuerLabel setText:self.t.issuer];
}

- (void) restart {
  [self.timer setDate:[NSDate dateWithTimeIntervalSinceNow:self.t.period]];
  [self.tokenLabel setText:self.t.getOTP];
}
@end
