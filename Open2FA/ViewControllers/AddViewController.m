//
//  AddViewController.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/8/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "AddViewController.h"
#import "Token.h"
#import "TokenStore.h"

@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)didSave:(id)sender {

  // protocol
  NSInteger methodIndex = [self.protocol selectedSegmentIndex];
  NSString *method = [[Token supportedMethods] objectAtIndex:methodIndex];
  NSLog(@"ACCT TEXT %@", self.account.text);
  Token *token = [[Token alloc] initWithMethod:method
                                        Issuer:[self.issuer text]
                                       Account:[self.account text]
                                        Secret:[self.secret text]];
  [[[TokenStore alloc] init] add:token];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
