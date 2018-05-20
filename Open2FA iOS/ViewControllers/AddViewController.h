//
//  AddViewController.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/8/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *protocol;
@property (weak, nonatomic) IBOutlet UITextField *issuer;
@property (weak, nonatomic) IBOutlet UITextField *secret;
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UISegmentedControl *digitToggle;
@property (strong, nonatomic) IBOutlet UISegmentedControl *algorithmToggle;
@property (nonatomic, copy) void (^didDismiss)(void);
@end
