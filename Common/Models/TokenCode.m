//
//  TokenCode.m
//  Open2FA
//
//  Created by Andrew Fischer on 4/12/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//

#import "TokenCode.h"

static uint64_t currentTimeMillis() {
  struct timeval t;
  if (gettimeofday(&t, NULL) != 0)
    return 0;

  return t.tv_sec * 1000 + t.tv_usec / 1000;
}

@implementation TokenCode {
  TokenCode *nextCode;
  NSString *codeText;
  uint64_t startTime;
  uint64_t endTime;
}

- (id)initWithCode:(NSString *)code
         startTime:(time_t)start
           endTime:(time_t)end {
  codeText = code;
  startTime = start * 1000;
  endTime = end * 1000;
  nextCode = nil;
  return self;
}

- (id)initWithCode:(NSString *)code
         startTime:(time_t)start
           endTime:(time_t)end
     nextTokenCode:(TokenCode *)next {
  self = [self initWithCode:code startTime:start endTime:end];
  nextCode = next;
  return self;
}

- (NSString *)currentCode {
  uint64_t now = currentTimeMillis();
  NSString *code = [[NSString alloc] init];
  if (now < startTime)
    code = nil;
  
  if (now < endTime)
    code = codeText;
  
  if (nextCode != nil)
    code = [nextCode currentCode];

  // add space in center of string easy reading
  return [NSString stringWithFormat:@"%@ %@",
          [code substringWithRange:NSMakeRange(0, code.length / 2)],
          [code substringWithRange:NSMakeRange(code.length / 2, code.length - code.length / 2)]];
}

- (float)currentProgress {
  uint64_t now = currentTimeMillis();

  if (now < startTime)
    return 0.0;

  if (now < endTime) {
    float totalTime = (float)(endTime - startTime);
    return 1.0 - (now - startTime) / totalTime;
  }

  if (nextCode != nil)
    return [nextCode currentProgress];

  return 0.0;
}

@end
