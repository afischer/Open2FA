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
  NSLog(@"ACCT TEXT %@", self.account.text);
  
  NSString *proto = [[Token supportedTypes] objectAtIndex:methodIndex];
  NSString *digits = [@[@"6", @"8"] objectAtIndex:[self.digitToggle selectedSegmentIndex]];
  NSString *algorithm = [@[@"sha1", @"sha256", @"sha512", @"md5"] objectAtIndex:[self.algorithmToggle selectedSegmentIndex]];
  
  NSString *uri = [NSString stringWithFormat:@"otpauth://%@/%@:%@?algorithm=%@&digits=%@&secret=%@", proto, [[self.issuer text] urlEncodedString], [[self.account text] urlEncodedString], algorithm, digits, [self.secret text]];
  NSLog(@"User added URI %@", uri);
  Token *token = [[Token alloc] initWithURI:[NSURL URLWithString:uri]];
  [[[TokenStore alloc] init] add:token];
  [self dismissViewControllerAnimated:YES completion:nil];
  self.didDismiss();
}

@end
