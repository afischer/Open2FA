//
//  AddViewController.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/8/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "AddViewController.h"
#import "TokenStore.h"

@interface AddViewController ()
@property BOOL pickedImage;
@end

@implementation AddViewController

- (void)viewWillAppear:(BOOL)animated {
  self.navigationController.navigationBar.tintColor = [UIColor colorNamed:@"tintColor"];
  if (self.editingToken) {
    self.issuer.text = self.editingToken.issuer;
    self.account.text = self.editingToken.account;
    self.secret.text = @"••••••••••••";
    [self.secret setEnabled:NO];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.pickedImage = NO;
  self.imgPicker = [[UIImagePickerController alloc] init];
  self.imgPicker.delegate = self;
  self.imgPicker.modalPresentationStyle = UIModalPresentationFormSheet;
  self.imgPicker.allowsEditing = YES;
  self.iconPreview.layer.cornerRadius = (CGFloat)self.iconPreview.bounds.size.width/2;
  self.iconPreview.clipsToBounds = YES;
  [self.saveButton setEnabled:NO];
  
  [self.secret addTarget:self
                  action:@selector(checkSecret)
        forControlEvents:UIControlEventEditingChanged];
}

- (BOOL) checkSecret {
  NSString *secretStr = self.secret.text;
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath
                                                                 indexPathForRow:2
                                                                 inSection:1]];

  if ([secretStr length] > 7) {
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [self.saveButton setEnabled:YES];
    return YES;
  } else {
    [self.saveButton setEnabled:NO];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return NO;
  }
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
  
  // Save image if one is set
  if (self.pickedImage) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSData *imgData = UIImagePNGRepresentation(self.iconPreview.image);
    NSString *imgName = [NSString stringWithFormat:@"%@.png", token.uid];
    [imgData writeToFile:[basePath stringByAppendingPathComponent:imgName]
              atomically:YES];
  }
  
  [[[TokenStore alloc] init] add:token];
  [self dismissViewControllerAnimated:YES completion:nil];
  [self didDismiss];
}


//- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
//  NSLog(@"%@", textField.)
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath indexAtPosition:0] == 2) { // change icon
    [self presentViewController:self.imgPicker animated:YES completion:nil];
  }
}

#pragma MARK - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  self.pickedImage = YES;
  UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
  [self.iconPreview setImage:img];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
