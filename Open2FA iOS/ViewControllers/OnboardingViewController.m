//
//  OnboardingViewController.m
//  Open2FA
//
//  Created by Andrew Fischer on 6/2/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "OnboardingViewController.h"

@interface OnboardingViewController ()
@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didCompleteOnboarding:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
  self.didDismiss();
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
