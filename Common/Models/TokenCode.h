//
//  TokenCode.h
//  Open2FA
//
//  Created by Andrew Fischer on 4/12/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//
//  Thanks to Nathaniel McCallum <npmccallum@redhat.com> and OpenOTP
//

#import <Foundation/Foundation.h>
#import <sys/time.h>

@interface TokenCode : NSObject
- (id)initWithCode:(NSString*)code startTime:(time_t)start endTime:(time_t)end;
- (id)initWithCode:(NSString*)code
         startTime:(time_t)start
           endTime:(time_t)end
     nextTokenCode:(TokenCode*)next;
- (NSString*)currentCode;
- (float)currentProgress;
@end
