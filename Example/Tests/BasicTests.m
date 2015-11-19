//
//  BasicTests.m
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/19/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import <XCTest/XCTest.h>
@import URBNValidator;


/**
 The purpose of these tests are to validate the individual rules.   
 This is also to validate our obj-c interoperability
 */
@interface BasicTests : XCTestCase @end

@implementation BasicTests

- (void)testSampleCall {
    
    URBNRequiredRule *requiredRule = [URBNRequiredRule new];
    
    XCTAssertFalse([requiredRule validateValue:nil], @"Should not validate nil");
    XCTAssertTrue([requiredRule validateValue:@"yo"], @"Should validate non-nil");
}

@end
