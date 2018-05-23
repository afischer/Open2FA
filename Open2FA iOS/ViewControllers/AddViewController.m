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
  
  self.imgPicker = [[UIImagePickerController alloc] init];
  self.imgPicker.delegate = self;
  self.imgPicker.modalPresentationStyle = UIModalPresentationFormSheet;
  self.imgPicker.allowsEditing = YES;
  self.iconPreview.layer.cornerRadius = (CGFloat)self.iconPreview.bounds.size.width/2;
  self.iconPreview.clipsToBounds = YES;

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
  // Save image if one is set
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  NSData *imgData = UIImagePNGRepresentation(self.iconPreview.image);
  NSString *imgName = [NSString stringWithFormat:@"%@.png", token.uid];
  [imgData writeToFile:[basePath stringByAppendingPathComponent:imgName] atomically:YES];
  
  [[[TokenStore alloc] init] add:token];
  [self dismissViewControllerAnimated:YES completion:nil];
  self.didDismiss();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath indexAtPosition:0]) { // change icon
    [self presentViewController:self.imgPicker animated:YES completion:nil];
  }
}

#pragma MARK - UIImagePickerControllerDelegate


- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
  [self.iconPreview setImage:img];
  [self dismissViewControllerAnimated:YES completion:nil];
}


//#pragma mark - Circle overlay trick

//-(void)addCircleOverlayToImagePicker:(UIViewController*)viewController
//{
//  UIColor *circleColor = [UIColor clearColor];
//  UIColor *maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//
//  CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
//  CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
//
//  CAShapeLayer *circleLayer = [CAShapeLayer layer];
//  //Center the circleLayer frame:
//  UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, screenHeight/2 - screenWidth/2, screenWidth, screenWidth)];
//  circlePath.usesEvenOddFillRule = YES;
//  circleLayer.path = [circlePath CGPath];
//  circleLayer.fillColor = circleColor.CGColor;
//  //Mask layer frame: it begins on y=0 and ends on y = plCropOverlayBottomBar.origin.y
//  UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, screenHeight - 70) cornerRadius:0];
//  [maskPath appendPath:circlePath];
//  maskPath.usesEvenOddFillRule = YES;
//
//  CAShapeLayer *maskLayer = [CAShapeLayer layer];
//  maskLayer.path = maskPath.CGPath;
//  maskLayer.fillRule = kCAFillRuleEvenOdd;
//  maskLayer.fillColor = maskColor.CGColor;
//  [viewController.view.layer addSublayer:maskLayer];
//
//  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//    //On iPhone add an hint label on top saying "scale and move" or whatever you want
//    UILabel *cropLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, screenWidth, 50)];
//    [cropLabel setText:NSLocalizedString(@"IMAGE_PICKER_CROP_LABEL", nil)];
//    [cropLabel setTextAlignment:NSTextAlignmentCenter];
//    [cropLabel setTextColor:[UIColor whiteColor]];
//    [viewController.view addSubview:cropLabel];
//  }
//}


@end
