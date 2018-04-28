//
//  Base32Tests.m
//  Open2FATests
//
//  Created by Andrew Fischer on 4/28/18.
//  Copyright © 2018 Andrew Fischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Base32.h"

@interface Base32Tests : XCTestCase
@end

@implementation Base32Tests
// Cases from the RFC: https://www.ietf.org/rfc/rfc4648.txt

- (void)testEncode {
    XCTAssertEqualObjects([@"f" base32String], @"MY======");
    XCTAssertEqualObjects([@"fo" base32String], @"MZXQ====");
    XCTAssertEqualObjects([@"foo" base32String], @"MZXW6===");
    XCTAssertEqualObjects([@"foob" base32String], @"MZXW6YQ=");
    XCTAssertEqualObjects([@"fooba" base32String], @"MZXW6YTB");
    XCTAssertEqualObjects([@"foobar" base32String], @"MZXW6YTBOI======");
}

- (void)testDecode {
    XCTAssertEqualObjects(@"f", [NSString stringFromBase32String:@"MY======"]);
    XCTAssertEqualObjects(@"fo", [NSString stringFromBase32String:@"MZXQ===="]);
    XCTAssertEqualObjects(@"foo", [NSString stringFromBase32String:@"MZXW6==="]);
    XCTAssertEqualObjects(@"foob", [NSString stringFromBase32String:@"MZXW6YQ="]);
    XCTAssertEqualObjects(@"fooba", [NSString stringFromBase32String:@"MZXW6YTB"]);
    XCTAssertEqualObjects(@"foobar", [NSString stringFromBase32String:@"MZXW6YTBOI======"]);
}
@end
