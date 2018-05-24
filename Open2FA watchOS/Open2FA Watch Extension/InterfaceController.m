//
//  InterfaceController.m
//  Open2FA Watch Extension
//
//  Created by Andrew Fischer on 4/25/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import "InterfaceController.h"
#import "TokenWatchRow.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "TokenStore.h"

@interface InterfaceController ()<WCSessionDelegate>
@property(strong, nonatomic) IBOutlet WKInterfaceTable *table;
@property(strong, nonatomic) WCSession *wcSession;
@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  if ([WCSession isSupported]) {
    if ([self.wcSession activationState] != WCSessionActivationStateActivated) {
      self.wcSession = [WCSession defaultSession];
      self.wcSession.delegate = self;
      [self.wcSession activateSession];
    }
    [self requestSync];
  }
  [self refreshTableView];
}

- (void)willActivate {
  [super willActivate];
  [self refreshTableView];
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:
  (NSDictionary<NSString *, id> *)applicationContext {
  
  TokenStore *tstore = [[TokenStore alloc] init];
  [tstore clear];

  for (NSString *key in [applicationContext allKeys]) {
    if ([key containsString:storePrefix]) {
      NSURL *uri = [NSURL URLWithString:[applicationContext valueForKey:key]];
      Token *token = [[Token alloc] initWithURI:uri];
      [tstore add:token];
    }
  }
  
  [self refreshTableView];
}

- (void)refreshTableView {
  TokenStore *tstore = [[TokenStore alloc] init];
  [self.table setNumberOfRows:[tstore count] withRowType:@"tokenRow"];
  for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
    TokenWatchRow *row = [self.table rowControllerAtIndex:i];
    Token *token = [tstore get:(int)i];
    [row setToken:token];
  }
}

- (void)session:(nonnull WCSession *)session
    activationDidCompleteWithState:(WCSessionActivationState)activationState
                             error:(nullable NSError *)error {
  [self requestSync];
}


- (void)requestSync {
  // TODO: Error handling
  [self.wcSession sendMessage:@{@"type" : @"sync"}
                 replyHandler:nil
                 errorHandler:nil];
}

@end