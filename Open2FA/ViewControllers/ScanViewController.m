//
//  ScanViewController.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/17/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "ScanViewController.h"
#import "Token.h"
#import "TokenStore.h"

@interface ScanViewController ()
@property(nonatomic) BOOL isReading;
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(weak, nonatomic) IBOutlet UIView *cameraView;
@end

@implementation ScanViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self requestCameraPermissionsIfNeeded];

  NSError *error;

  self.captureSession = [[AVCaptureSession alloc] init];
  AVCaptureDevice *captureDevice =
      [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  AVCaptureDeviceInput *input =
      [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
  [self.captureSession addInput:input];
  AVCaptureMetadataOutput *captureMetadataOutput =
      [[AVCaptureMetadataOutput alloc] init];
  [self.captureSession addOutput:captureMetadataOutput];
  // Create a new queue and set delegate for metadata objects scanned.
  dispatch_queue_t dispatchQueue;
  dispatchQueue = dispatch_queue_create("scanQueue", NULL);
  [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
  // Delegate should implement
  // captureOutput:didOutputMetadataObjects:fromConnection: to get callbacks on
  // detected metadata.
  [captureMetadataOutput
      setMetadataObjectTypes:[captureMetadataOutput
                                 availableMetadataObjectTypes]];

  self.videoPreviewLayer =
      [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
  [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  [self.videoPreviewLayer setFrame:self.cameraView.layer.bounds];
  [self.cameraView.layer addSublayer:self.videoPreviewLayer];
  [self.captureSession startRunning];
  // Do any additional setup after loading the view.
}

- (void)requestCameraPermissionsIfNeeded {
  // check camera authorization status
  AVAuthorizationStatus authStatus =
      [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  switch (authStatus) {
  case AVAuthorizationStatusAuthorized: { // camera authorized
                                          // do camera intensive stuff
  } break;
  case AVAuthorizationStatusNotDetermined: { // request authorization

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                               dispatch_async(dispatch_get_main_queue(), ^{

                                 if (granted) {
                                   // do camera intensive stuff
                                 } else {
                                   [self notifyUserOfCameraAccessDenial];
                                 }
                               });
                             }];
  } break;
  case AVAuthorizationStatusRestricted:
  case AVAuthorizationStatusDenied: {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self notifyUserOfCameraAccessDenial];
    });
  } break;
  default:
    break;
  }
}

- (void)notifyUserOfCameraAccessDenial {
  // display a useful message asking the user to grant permissions from within
  // Settings > Privacy > Camera
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)cancelClicked:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output
    didOutputMetadataObjects:
        (NSArray<__kindof AVMetadataObject *> *)metadataObjects
              fromConnection:(AVCaptureConnection *)connection {
  NSString *capturedBarcodeText = nil;
  for (AVMetadataObject *barcodeMetadata in metadataObjects) {
    // ..check if it is a suported barcode

    if ([barcodeMetadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
      AVMetadataMachineReadableCodeObject *barcodeObject =
          (AVMetadataMachineReadableCodeObject *)[self.videoPreviewLayer
              transformedMetadataObjectForMetadataObject:barcodeMetadata];
      capturedBarcodeText = [barcodeObject stringValue];
      if ([capturedBarcodeText containsString:@"otpauth"]) {
        // Got the barcode. Set the text in the UI and break out of the loop.

        dispatch_sync(dispatch_get_main_queue(), ^{
          [self.captureSession stopRunning];
          NSURL *url = [NSURL URLWithString:capturedBarcodeText];
          Token *token = [[Token alloc] initWithURI:url];
          TokenStore *store = [[TokenStore alloc] init];
          [store add:token];
          [self dismissViewControllerAnimated:YES
                                   completion:^{

                                   }];
        });
        return;
      }
    }
  }
}

@end
