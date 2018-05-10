//
//  TokenStore.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/10/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//

#define ORDER_KEY @"2FATokenOrder"

#import "TokenStore.h"

static NSMutableArray* getOrder(NSUserDefaults* store) {
    NSMutableArray* order = [NSMutableArray arrayWithArray:
                             [store objectForKey:ORDER_KEY]];
    if (order == nil) {
        order = [[NSMutableArray alloc] init];
        [store setObject:order forKey:ORDER_KEY];
        [store synchronize];
    }
    return order;
}

@interface TokenStore ()
@end

@implementation TokenStore {
    NSUserDefaults* store;
}

- (id)init {
    self = [super init];
    
    store = [NSUserDefaults standardUserDefaults];
    if (store == nil)
        return nil;
  
    return self;
}

- (NSUInteger)count {
    NSMutableArray* order = getOrder(store);
    return order.count;
}

- (void)add:(Token*)token {
    [self add:token atIndex:0];
}

- (void)add:(Token*)token atIndex:(NSUInteger)index {
    if ([store stringForKey:token.uid] != nil)
        return;

    NSMutableArray* order = getOrder(store);
    [order insertObject:token.uid atIndex:index];
    [store setObject:order forKey:ORDER_KEY];
    [store setObject:token.tokenURI forKey:token.uid];
    [store synchronize];
}



- (Token*)get:(NSUInteger)index {
    NSMutableArray* order = getOrder(store);
    NSLog(@"%@", order);
    if ([order count] < 1)
        return nil;

    NSString* key = [order objectAtIndex:(long)index];
    if (key == nil)
        return nil;
    
    NSLog(@"object for key %@: %@", key, [store objectForKey:key]);
    NSURL *tokenURI = [[NSURL alloc] initWithString:[store objectForKey:key]];
    NSLog(@"%@, bad", tokenURI);
    return [[Token alloc] initWithURI:tokenURI];
}

- (void)del:(NSUInteger)index {
    NSMutableArray* order = getOrder(store);
    NSLog(@"%@", order);
    NSString* key = [order objectAtIndex:index];
    if (key == nil)
        return;
    
    [order removeObjectAtIndex:index];
    [store setObject:order forKey:ORDER_KEY];
    [store removeObjectForKey:key];
    [store synchronize];
}
/*

- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    NSLog(@"Finished activation on phone");
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    NSLog(@"CONTEXT: %@", [applicationContext allKeys]);
}

//# ifdef TARGET_OS_IOS
- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {
    NSLog(@"Session became inactive");
}

- (void)sessionDidDeactivate:(nonnull WCSession *)session {
    NSLog(@"Session deactivated");
}
//# endifr
*/
@end
