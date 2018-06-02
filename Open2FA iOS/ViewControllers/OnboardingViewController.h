//
//  OnboardingViewController.h
//  Open2FA
//
//  Created by Andrew Fischer on 6/2/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingViewController : UIViewController
@property (nonatomic, copy) void (^didDismiss)(void);
@end
