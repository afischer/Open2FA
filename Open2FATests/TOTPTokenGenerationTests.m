//
//  TOTPTokenGenerationTests.m
//  Open2FATests
//
//  Created by Andrew Fischer on 5/14/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Token.h"

static NSString *kSHA1Key = @"12345678901234567890";
static NSString *kSHA256Key = @"12345678901234567890123456789012";
static NSString *kSHA512Key = @"1234567890123456789012345678901234567890123456"
                              "789012345678901234";

@interface TOTPTokenGenerationTests : XCTestCase

@end

static NSDate *d1;
static NSDate *d2;
static NSDate *d3;
static NSDate *d4;
static NSDate *d5;
static NSDate *d6;

Token *token;


@implementation TOTPTokenGenerationTests

- (void)setUp {
  [super setUp];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  for (NSString * key in [[defaults dictionaryRepresentation] allKeys]) {
    [defaults removeObjectForKey:key];
  }
  
  d1 = [NSDate dateWithTimeIntervalSince1970:59];
  d2 = [NSDate dateWithTimeIntervalSince1970:1111111109];
  d3 = [NSDate dateWithTimeIntervalSince1970:1111111111];
  d4 = [NSDate dateWithTimeIntervalSince1970:1234567890];
  d5 = [NSDate dateWithTimeIntervalSince1970:2000000000];
  d6 = [NSDate dateWithTimeIntervalSince1970:20000000000];
}

// Tests from https://tools.ietf.org/html/rfc6238#appendix-B
//+-------------+--------------+------------------+----------+--------+
//|  Time (sec) |   UTC Time   | Value of T (hex) |   TOTP   |  Mode  |
//+-------------+--------------+------------------+----------+--------+
//1      59     |  1970-01-01  | 0000000000000001 | 94287082 |  SHA1  |
//|             |   00:00:59   |                  |          |        |
//|      59     |  1970-01-01  | 0000000000000001 | 46119246 | SHA256 |
//|             |   00:00:59   |                  |          |        |
//|      59     |  1970-01-01  | 0000000000000001 | 90693936 | SHA512 |
//|             |   00:00:59   |                  |          |        |
//2  1111111109 |  2005-03-18  | 00000000023523EC | 07081804 |  SHA1  |
//|             |   01:58:29   |                  |          |        |
//|  1111111109 |  2005-03-18  | 00000000023523EC | 68084774 | SHA256 |
//|             |   01:58:29   |                  |          |        |
//|  1111111109 |  2005-03-18  | 00000000023523EC | 25091201 | SHA512 |
//|             |   01:58:29   |                  |          |        |
//3  1111111111 |  2005-03-18  | 00000000023523ED | 14050471 |  SHA1  |
//|             |   01:58:31   |                  |          |        |
//|  1111111111 |  2005-03-18  | 00000000023523ED | 67062674 | SHA256 |
//|             |   01:58:31   |                  |          |        |
//|  1111111111 |  2005-03-18  | 00000000023523ED | 99943326 | SHA512 |
//|             |   01:58:31   |                  |          |        |
//4  1234567890 |  2009-02-13  | 000000000273EF07 | 89005924 |  SHA1  |
//|             |   23:31:30   |                  |          |        |
//|  1234567890 |  2009-02-13  | 000000000273EF07 | 91819424 | SHA256 |
//|             |   23:31:30   |                  |          |        |
//|  1234567890 |  2009-02-13  | 000000000273EF07 | 93441116 | SHA512 |
//|             |   23:31:30   |                  |          |        |
//5  2000000000 |  2033-05-18  | 0000000003F940AA | 69279037 |  SHA1  |
//|             |   03:33:20   |                  |          |        |
//|  2000000000 |  2033-05-18  | 0000000003F940AA | 90698825 | SHA256 |
//|             |   03:33:20   |                  |          |        |
//|  2000000000 |  2033-05-18  | 0000000003F940AA | 38618901 | SHA512 |
//|             |   03:33:20   |                  |          |        |
//6 20000000000 |  2603-10-11  | 0000000027BC86AA | 65353130 |  SHA1  |
//|             |   11:33:20   |                  |          |        |
//| 20000000000 |  2603-10-11  | 0000000027BC86AA | 77737706 | SHA256 |
//|             |   11:33:20   |                  |          |        |
//| 20000000000 |  2603-10-11  | 0000000027BC86AA | 47863826 | SHA512 |
//|             |   11:33:20   |                  |          |        |
//+-------------+--------------+------------------+----------+--------+

- (void)testTOTPSHA1 {
  token = [[Token alloc] initWithType:@"totp"
                               Issuer:@"TEST"
                              Account:@"TEST@TEST"
                               Secret:[kSHA1Key base32String]];

  XCTAssertTrue([[token getOTPForDate:d1] isEqualToString:@"287082"]);
  XCTAssertTrue([[token getOTPForDate:d2] isEqualToString:@"081804"]);
  XCTAssertTrue([[token getOTPForDate:d3] isEqualToString:@"050471"]);
  XCTAssertTrue([[token getOTPForDate:d4] isEqualToString:@"005924"]);
  XCTAssertTrue([[token getOTPForDate:d5] isEqualToString:@"279037"]);
  XCTAssertTrue([[token getOTPForDate:d6] isEqualToString:@"353130"]);
  XCTAssertFalse([[token getOTPForDate:d6] isEqualToString:@"111111"]);
}

- (void)testTOTPSHA18Digits {
  token = [[Token alloc] initWithType:@"totp"
                               Issuer:@"TEST"
                              Account:@"TEST@TEST"
                               Secret:[kSHA1Key base32String]];

  token.digits = 8;
  XCTAssertTrue([[token getOTPForDate:d1] isEqualToString:@"94287082"]);
  XCTAssertTrue([[token getOTPForDate:d2] isEqualToString:@"07081804"]);
  XCTAssertTrue([[token getOTPForDate:d3] isEqualToString:@"14050471"]);
  XCTAssertTrue([[token getOTPForDate:d4] isEqualToString:@"89005924"]);
  XCTAssertTrue([[token getOTPForDate:d5] isEqualToString:@"69279037"]);
  XCTAssertTrue([[token getOTPForDate:d6] isEqualToString:@"65353130"]);
}

- (void)testTOTP256 {
  // Keys SHOULD be of the length of the HMAC output
  token = [[Token alloc] initWithType:@"totp"
                               Issuer:@"TEST"
                              Account:@"TEST@TEST"
                               Secret:[kSHA256Key base32String]];
  token.algorithm = kCCHmacAlgSHA256;
  token.digits = 8;
  XCTAssertEqual(token.algorithm, kCCHmacAlgSHA256);
  XCTAssertEqualObjects([token getOTPForDate:d1], @"46119246");
  XCTAssertEqualObjects([token getOTPForDate:d2], @"68084774");
  XCTAssertEqualObjects([token getOTPForDate:d3], @"67062674");
  XCTAssertEqualObjects([token getOTPForDate:d4], @"91819424");
  XCTAssertEqualObjects([token getOTPForDate:d5], @"90698825");
  XCTAssertEqualObjects([token getOTPForDate:d6], @"77737706");
}

- (void)testTOTP512 {
  // Keys SHOULD be of the length of the HMAC output
  token = [[Token alloc] initWithType:@"totp"
                               Issuer:@"TEST"
                              Account:@"TEST@TEST"
                               Secret:[kSHA512Key base32String]];
  token.digits = 8;
  token.algorithm = kCCHmacAlgSHA512;
  NSLog(@"THE TOKEN IS %@", [token getOTPForDate:d1]);
  XCTAssertTrue([[token getOTPForDate:d1] isEqualToString:@"90693936"]);
  XCTAssertTrue([[token getOTPForDate:d2] isEqualToString:@"25091201"]);
  XCTAssertTrue([[token getOTPForDate:d3] isEqualToString:@"99943326"]);
  XCTAssertTrue([[token getOTPForDate:d4] isEqualToString:@"93441116"]);
  XCTAssertTrue([[token getOTPForDate:d5] isEqualToString:@"38618901"]);
  XCTAssertTrue([[token getOTPForDate:d6] isEqualToString:@"47863826"]);
}
@end
