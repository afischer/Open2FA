//
//  TokenViewController.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/5/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TokenViewController : UITableViewController <UITableViewDelegate,
                                                        UITableViewDataSource>
- (IBAction)addButtonClicked:(id)sender;

@end
