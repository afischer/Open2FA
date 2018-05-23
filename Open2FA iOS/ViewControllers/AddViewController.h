//
//  AddViewController.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/8/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Open2FA.h"

@interface AddViewController : UITableViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *protocol;
@property (weak, nonatomic) IBOutlet UITextField *issuer;
@property (weak, nonatomic) IBOutlet UITextField *secret;
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UISegmentedControl *digitToggle;
@property (strong, nonatomic) IBOutlet UISegmentedControl *algorithmToggle;
@property (strong, nonatomic) IBOutlet UIImageView *iconPreview;
@property (nonatomic, copy) void (^didDismiss)(void);
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@end
