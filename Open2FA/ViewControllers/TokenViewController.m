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

@interface TokenViewController ()
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) TokenStore *store;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    [self.store syncToWatch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - IBActionns
- (IBAction)addButtonClicked:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    ScanViewController *vc = (ScanViewController *)[sb instantiateViewControllerWithIdentifier:@"scanView"];
    
    // show controller modally
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:nil];
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

# pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"tokenCell";
    TokenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
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
    return 90.0f;
}

// EDITING STUFF

- (BOOL)      tableView:(UITableView *)tableView
  canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)   tableView:(UITableView *)tableView
  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
   forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Delete 2FA Password" message:@"Are you sure you want to delete this item? This action can not be undone." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelBtn = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action) {
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        UIAlertAction* delBtn = [UIAlertAction
                                   actionWithTitle:@"Delete"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * action) {
                                       // Annimate out, remove from store
                                       [self.tableView beginUpdates];
                                       [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                                       [self.store del:indexPath.row];
                                       [self.store syncToWatch];
                                       [self.tableView endUpdates];
                                       [self.tableView reloadData];
                                   }];

        [alert addAction:cancelBtn];
        [alert addAction:delBtn];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
@end
