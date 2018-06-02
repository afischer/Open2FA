//
//  URITests.m
//  Open2FATests
//
//  Created by Andrew Fischer on 6/2/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Token.h"

@interface URITests : XCTestCase
@end

@implementation URITests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testMinimumParams {
  NSString *uriStr = @"otpauth://hotp/foo:bar?secret=GEZDGNBV";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNotNil(token);
  XCTAssertEqual(token.period, 30);
  XCTAssertEqual(token.digits, 6);
  XCTAssertEqual(token.algorithm, kCCHmacAlgSHA1);
}

- (void) testBadScheme {
  NSString *uriStr = @"https://hotp/foo:bar?algorithm=sha1";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNil(token);
}

- (void) testUnsupportedType {
  NSString *uriStr = @"otpauth://futureOTP/foo:bar?algorithm=sha1";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNil(token);
}

- (void) testNoPath {
  NSString *uriStr = @"otpauth://hotp";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNil(token);
}

- (void) testEmptyPath {
  NSString *uriStr = @"otpauth://hotp/?algorithm=sha1?secret=GEZDGNBV";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNil(token);
}

- (void) testOnlyAccount {
  NSString *uriStr = @"otpauth://hotp/foo?secret=GEZDGNBV";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNotNil(token);
  XCTAssertEqualObjects(token.account, @"foo");
  XCTAssertNil(token.issuer);
}

- (void) testNilSecret {
  NSString *uriStr = @"otpauth://hotp/foo:bar?algorithm=sha1";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNil(token);
}

- (void) testCustomPeriod {
  NSString *uriStr = @"otpauth://hotp/foo:bar?secret=GEZDGNBV&period=42";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNotNil(token);
  XCTAssertEqual(token.period, 42);
  XCTAssertEqual(token.digits, 6);
  XCTAssertEqual(token.algorithm, kCCHmacAlgSHA1);
}


- (void) testCustomDigits {
  NSString *uriStr = @"otpauth://hotp/foo:bar?secret=GEZDGNBV&digits=8";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNotNil(token);
  XCTAssertEqual(token.period, 30);
  XCTAssertEqual(token.digits, 8);
  XCTAssertEqual(token.algorithm, kCCHmacAlgSHA1);
}


- (void) testCustomCoutner {
  NSString *uriStr = @"otpauth://hotp/foo:bar?secret=GEZDGNBV&counter=42";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  XCTAssertNotNil(token);
  XCTAssertEqual(token.period, 30);
  XCTAssertEqual(token.digits, 6);
  XCTAssertEqual(token.algorithm, kCCHmacAlgSHA1);
  XCTAssertEqual(token.counter, 42);
}

- (void) testWrapperInit {
  Token *token = [[Token alloc] initWithType:@"hotp"
                                      Issuer:@"foo"
                                     Account:@"bar"
                                      Secret:@"GEZDGNBV"];
  XCTAssertNotNil(token);
  XCTAssertEqual(token.period, 30);
  XCTAssertEqual(token.digits, 6);
  XCTAssertEqual(token.algorithm, kCCHmacAlgSHA1);
  XCTAssertEqual(token.counter, 0);
  XCTAssertEqualObjects(token.issuer, @"foo");
  XCTAssertEqualObjects(token.account, @"bar");
}

- (void) testReturnURI {
  NSString *uriStr = @"otpauth://hotp/foo:bar?secret=GEZDGNBV&counter=42";
  NSURL *uri = [NSURL URLWithString:uriStr];
  Token *token = [[Token alloc] initWithURI:uri];
  NSString *newURI = [token tokenURI];
  XCTAssertEqualObjects(newURI, @"otpauth://hotp/foo:bar?algorithm=sha1&digits=6&secret=GEZDGNBV&issuer=foo&period=30&counter=42");
}

@end
