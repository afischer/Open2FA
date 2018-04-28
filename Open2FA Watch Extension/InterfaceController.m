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

@interface InterfaceController () <WCSessionDelegate>
@property (strong, nonatomic) IBOutlet WKInterfaceTable *table;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
//        NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    NSLog(@"GOT CONTEXT");
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    for (NSString *key in [applicationContext allKeys]) {
        NSLog(@"KEY: %@", key);
        [store setValue:[applicationContext objectForKey:key] forKey:key];
    }
    [store synchronize];
    
    TokenStore *tstore = [[TokenStore alloc] init];
    [self.table setNumberOfRows:[tstore count] withRowType:@"tokenRow"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        TokenWatchRow* row = [self.table rowControllerAtIndex:i];
        Token *token = [tstore get:(long)i];
        [row setToken:token];
    }
    [self.table setNumberOfRows:self.table.numberOfRows withRowType:@"tokenRow"];
}


- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    NSLog(@"Finished activation");
}



- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



