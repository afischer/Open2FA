//
//  TokenStore.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/10/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//


#import "TokenStore.h"

NSString *const ORDER_KEY = @"2FATokenOrder";

static NSMutableArray *getOrder(NSUserDefaults *store) {
  NSMutableArray *order =
      [NSMutableArray arrayWithArray:[store objectForKey:ORDER_KEY]];
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
  NSUserDefaults *store;
}

- (id)init {
  self = [super init];

  store = [NSUserDefaults standardUserDefaults];
  if (store == nil)
    return nil;

  return self;
}

- (NSUInteger)count {
  NSMutableArray *order = getOrder(store);
  return order.count;
}

- (void)add:(Token *)token {
  [self add:token atIndex:0];
}

- (void)add:(Token *)token atIndex:(NSUInteger)index {
  if (!token)
    return;
  
//  if ([store stringForKey:token.uid] != nil)
//    return;

  NSMutableArray *order = getOrder(store);
  [order insertObject:token.uid atIndex:index];
  [store setObject:order forKey:ORDER_KEY];
  [store setObject:token.tokenURI forKey:token.uid];
  [store synchronize];
}

- (Token *)get:(NSUInteger)index {
  NSMutableArray *order = getOrder(store);
  if ([order count] < 1)
    return nil;

  NSString *key = [order objectAtIndex:(long)index];
  if (key == nil || ![store objectForKey:key])
    return nil;
  
  NSURL *tokenURI = [[NSURL alloc] initWithString:[store objectForKey:key]];
  return [[Token alloc] initWithURI:tokenURI];
}

- (void)deleteTokenAtIndex:(NSUInteger)index {
  NSMutableArray *order = getOrder(store);
  NSString *key = [order objectAtIndex:index];
  if (key == nil)
    return;

  [order removeObjectAtIndex:index];
  [store setObject:order forKey:ORDER_KEY];
  [store removeObjectForKey:key];
  [store synchronize];
}

- (void)deleteToken:(Token *)token {
  NSMutableArray *order = getOrder(store);
  NSUInteger index = [order indexOfObject:token.uid];
  if (index) {
    [self deleteTokenAtIndex:index];
  }
}

- (void) updateToken:(Token *)token {
  NSLog(@"UPDATING COUNTER TO BE %llu", [token counter]);
  [store setObject:token.tokenURI forKey:token.uid];
  [store synchronize];
}

- (void) moveFrom:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex {
  NSMutableArray* order = getOrder(store);
  NSString* key = [order objectAtIndex:sourceIndex];
  if (key == nil)
    return;
  
  [order removeObjectAtIndex:sourceIndex];
  [order insertObject:key atIndex:destinationIndex];
  
  [store setObject:order forKey:ORDER_KEY];
  [store synchronize];
}

- (void)clear {
  int i = (int)[getOrder(store) count] - 1;
  while (i >= 0) {
    [self deleteTokenAtIndex:i];
    i--;
  }
}
@end
