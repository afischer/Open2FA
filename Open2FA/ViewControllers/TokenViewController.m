//
//  TokenViewController.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/5/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "TokenViewController.h"
#import "TokenStore.h"
#import "TokenTableViewCell.h"
#import "ScanViewController.h"
#import "AddViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface TokenViewController () <WCSessionDelegate>
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property(strong, nonatomic) TokenStore *store;
@property(strong, nonatomic) WCSession *wcSession;
@end

@implementation TokenViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView setDelegate:self];
  [self.tableView setDataSource:self];
  [self.tableView setAllowsMultipleSelectionDuringEditing:NO];
  [self.tableView setAllowsSelectionDuringEditing:YES];
  //    self.navigationController.navigationBar.prefersLargeTitles = YES;
  self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
  self.store = [[TokenStore alloc] init];
  if ([WCSession isSupported])
    [self syncToWatch];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.tableView reloadData];
  [super viewWillAppear:animated];
  if ([WCSession isSupported])
    [self syncToWatch];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - IBActionns
- (IBAction)addButtonClicked:(id)sender {
  BOOL hasCamera = [UIImagePickerController
      isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
  if (hasCamera) {
    [self presentScanView];
  } else {
    [self presentManualEntryView];
  }
}

- (IBAction)digitToggle:(id)sender {
}

- (void)presentScanView {
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;

  ScanViewController *vc = (ScanViewController *)[sb
      instantiateViewControllerWithIdentifier:@"scanView"];

  // show controller modally
  UINavigationController *nc =
      [[UINavigationController alloc] initWithRootViewController:vc];
  nc.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:nc animated:YES completion:nil];
}

- (void)presentManualEntryView {
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

  AddViewController *vc = (AddViewController *)[sb
      instantiateViewControllerWithIdentifier:@"manualEntryView"];

  vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC)];

  vc.didDismiss = ^() {
    [self.tableView reloadData];
  };

  
  UINavigationController *nc =
      [[UINavigationController alloc] initWithRootViewController:vc];
  nc.modalPresentationStyle = UIModalPresentationFormSheet;
  
  [self presentViewController:nc animated:YES completion:nil];
}

- (void) dismissVC {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonnClicked:(id)sender {
  BOOL isEditing = [self.tableView isEditing];
  for (TokenTableViewCell *cell in self.tableView.visibleCells) {
    [cell setProgressVisibility:isEditing];
  }
  if (isEditing) {
    self.editButton.title = @"Edit";
    self.editButton.style = UIBarButtonSystemItemDone;
  } else {
    self.editButton.title = @"Done";
    self.editButton.style = UIBarButtonSystemItemEdit;
  }
  [self.tableView setEditing:![self.tableView isEditing] animated:YES];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellID = @"tokenCell";
  TokenTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil)
    cell = [[TokenTableViewCell alloc] init];
  // Bind token to token table cell
  Token *token = [self.store get:(long)indexPath.row];
  [cell setToken:token];
  [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.store.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 75.0f;
}

// EDITING STUFF

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Delete 2FA Password"
                         message:@"Are you sure you want to delete this item? "
                                 @"This action can not be undone."
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelBtn = [UIAlertAction
        actionWithTitle:@"Cancel"
                  style:UIAlertActionStyleCancel
                handler:^(UIAlertAction *action) {
                  [self dismissViewControllerAnimated:YES completion:nil];
                }];

    UIAlertAction *delBtn = [UIAlertAction
        actionWithTitle:@"Delete"
                  style:UIAlertActionStyleDestructive
                handler:^(UIAlertAction *action) {
                  // Annimate out, remove from store
                  [self.tableView beginUpdates];
                  [self.tableView
                      deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
                  [self.store del:indexPath.row];
                  [self syncToWatch];
                  [self.tableView endUpdates];
                  [self.tableView reloadData];
                }];

    [alert addAction:cancelBtn];
    [alert addAction:delBtn];

    [self presentViewController:alert animated:YES completion:nil];
  }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TokenTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  if ([self.tableView isEditing]) {
    NSLog(@"hi");
  } else {
    // copy token text to pasteboard
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = cell.tokenText.text;
    NSLog(@"COPIED %@ TO PASTEBOARD", cell.tokenText.text);
    [cell setSelected:NO];
  }
}

// SYNCING STUFF
- (void)syncToWatch {
  if (!self.wcSession) {
    NSLog(@"CREATING WCSESSION");
    self.wcSession = [WCSession defaultSession];
    self.wcSession.delegate = self;
    [self.wcSession activateSession];
  }

  NSLog(@"Synncinng to watch");
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  // TODO: Err handling
  [self.wcSession updateApplicationContext:[ud dictionaryRepresentation]
                                     error:nil];
}

- (void)session:(WCSession *)session
    didReceiveMessage:(NSDictionary<NSString *, id> *)message {
  NSLog(@"GOT MESSAGE %@", message);

//  if ([[message valueForKey:@"payload"] isEqualToString:@"update"])
    [self syncToWatch];
}

- (void)session:(nonnull WCSession *)session
    activationDidCompleteWithState:(WCSessionActivationState)activationState
                             error:(nullable NSError *)error {
  NSLog(@"Finished activation on phone");
}

- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {
  NSLog(@"Session became inactive");
}

- (void)sessionDidDeactivate:(nonnull WCSession *)session {
  NSLog(@"Session deactivated");
}

@end

