//
//  Open2FATests.m
//  Open2FATests
//
//  Created by Andrew Fischer on 4/3/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Token.h"

@interface Open2FATests : XCTestCase

@end

@implementation Open2FATests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHOTPSHA1 {
    // https://tools.ietf.org/html/rfc4226#appendix-D
  Token *token = [[Token alloc] initWithType:@"hotp"
                                      Issuer:@"TEST"
                                     Account:@"TEST@TEST"
                                      Secret:@"12345678901234567890"];
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

- (void)testTOTPSHA1 {
  // https://tools.ietf.org/html/rfc6238#appendix-B
  Token *token = [[Token alloc] initWithType:@"totp"
                                      Issuer:@"TEST"
                                     Account:@"TEST@TEST"
                                      Secret:@"12345678901234567890"];
  XCTAssertTrue([[token getOTPForDate:[NSDate dateWithTimeIntervalSince1970:59]] isEqualToString:@"287082"]);
  
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
