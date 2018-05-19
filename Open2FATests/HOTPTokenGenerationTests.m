//
//  TokenGenerationTests.m
//  Open2FATests
//
//  Created by Andrew Fischer on 5/14/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Token.h"
#import "Base32.h"

@interface HOTPTokenGenerationTests : XCTestCase
@end

@implementation HOTPTokenGenerationTests

- (void)setUp {
  [super setUp];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  for (NSString * key in [[defaults dictionaryRepresentation] allKeys]) {
    [defaults removeObjectForKey:key];
  }
}

- (void)testHOTPSHA1 {
  // from https://tools.ietf.org/html/rfc4226#appendix-D
  Token *token = [[Token alloc] initWithType:@"hotp"
                                      Issuer:@"TEST"
                                     Account:@"TEST@TEST"
                                      Secret:[@"12345678901234567890" base32String]];
  XCTAssertEqual([token counter], 0);
  XCTAssertTrue([[token getOTP] isEqualToString:@"755224"]);
  XCTAssertEqual([token counter], 1);
  XCTAssertTrue([[token getOTP] isEqualToString:@"287082"]);
  XCTAssertEqual([token counter], 2);
  XCTAssertTrue([[token getOTP] isEqualToString:@"359152"]);
  XCTAssertEqual([token counter], 3);
  XCTAssertTrue([[token getOTP] isEqualToString:@"969429"]);
  XCTAssertEqual([token counter], 4);
  XCTAssertTrue([[token getOTP] isEqualToString:@"338314"]);
  XCTAssertEqual([token counter], 5);
  XCTAssertTrue([[token getOTP] isEqualToString:@"254676"]);
  XCTAssertEqual([token counter], 6);
  XCTAssertTrue([[token getOTP] isEqualToString:@"287922"]);
  XCTAssertEqual([token counter], 7);
  XCTAssertTrue([[token getOTP] isEqualToString:@"162583"]);
  XCTAssertEqual([token counter], 8);
  XCTAssertTrue([[token getOTP] isEqualToString:@"399871"]);
  XCTAssertEqual([token counter], 9);
  XCTAssertTrue([[token getOTP] isEqualToString:@"520489"]);
}

@end
