//
//  BasicTests.m
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/19/15.
//  Copyright © 2015 URBN. All rights reserved.
//

#import <XCTest/XCTest.h>
@import URBNValidator;


/**
 The purpose of these tests are to validate the individual rules.   
 This is also to validate our obj-c interoperability
 */
@interface BasicCompatTests : XCTestCase @end

@implementation BasicCompatTests

- (void)testRequiredRule {
    
    URBNCompatRequiredRule *requiredRule = URBNVRequired;
    
    XCTAssertFalse([requiredRule validateValue:nil], @"Should not validate nil");
    XCTAssertTrue([requiredRule validateValue:@"yo"], @"Should validate non-nil");
}

- (void)testMinLengthRule {
    URBNCompatMinLengthRule *lengthRule = URBNVGreaterThanOrEqual(5);
    
    // String validations
    XCTAssertTrue([lengthRule validateValue:nil], @"Nil should validate by default");
    XCTAssertFalse([lengthRule validateValue:@"1324"], @"Should not validate anything < 5");
    XCTAssertTrue([lengthRule validateValue:@"12345"], @"Should validate anything >= 5");
    XCTAssertTrue([lengthRule validateValue:@"123456"], @"Should validate anything >= 5");
    
    // Array validations
    XCTAssertFalse([lengthRule validateValue:@[]], @"Should not validate array with count < 5");
    XCTAssertFalse([lengthRule validateValue:@[@1]], @"Should not validate array with count < 5");
    NSArray *a = @[@1,@2,@3,@4,@5];
    XCTAssertTrue([lengthRule validateValue:a], @"Should validate array with count == 5");
    XCTAssertTrue([lengthRule validateValue:[a arrayByAddingObject:@6]], @"Should validate array with count > 5");
    
    // Dictionary validations
    XCTAssertFalse([lengthRule validateValue:@{}], @"Should not validate dictionary with count < 5");
    XCTAssertFalse([lengthRule validateValue:@{@1: @"2"}], @"Should not validate dictionary with count < 5");
    NSDictionary *d = @{@"1": @1, @"2": @2, @"3": @3, @"4": @4, @"5": @5};
    XCTAssertTrue([lengthRule validateValue:d], @"Should validate dictionary with count == 5");
}

- (void)testMaxLengthRule {
    URBNCompatMaxLengthRule *lengthRule = URBNVLessThanOrEqual(5);
    
    // String validations
    XCTAssertTrue([lengthRule validateValue:nil], @"Nil should validate by default");
    XCTAssertFalse([lengthRule validateValue:@"132456"], @"Should not validate anything > 5");
    XCTAssertTrue([lengthRule validateValue:@"1234"], @"Should validate anything <= 5");
    XCTAssertTrue([lengthRule validateValue:@"12345"], @"Should validate anything <= 5");
    
    // Array validations
    NSArray *a = @[@1,@2,@3,@4,@5,@6];
    XCTAssertFalse([lengthRule validateValue:a], @"Should not validate array with count > 5");
    a = @[@1,@2,@3,@4,@5];
    XCTAssertTrue([lengthRule validateValue:a], @"Should validate array with count == 5");
    XCTAssertTrue([lengthRule validateValue:@[@1]], @"Should validate array with count < 5");
    
    // Dictionary validations
    NSDictionary *d = @{@"1": @1, @"2": @2, @"3": @3, @"4": @4, @"5": @5, @"6": @6};
    XCTAssertFalse([lengthRule validateValue:d], @"Should not validate dictionary with count > 5");
    d = @{@"1": @1, @"2": @2, @"3": @3, @"4": @4, @"5": @5};
    XCTAssertTrue([lengthRule validateValue:d], @"Should validate dictionary with count == 5");
    XCTAssertTrue([lengthRule validateValue:@{@"1": @1}], @"Should validate dictionary with count < 5");
}

- (void)testBlockRule {
    URBNCompatBlockRule *blockRule = URBNVBlock(^BOOL(id  _Nullable val) {
        return [val isKindOfClass:[NSArray  class]];
    });
    
    XCTAssertFalse([blockRule validateValue:nil], @"Should not validate nil since nil is not an array class");
    XCTAssertFalse([blockRule validateValue:@"2343"], @"Should not validate String since String is not an array class");
    XCTAssertTrue([blockRule validateValue:@[]], @"Should validate since we're passing an array");
}

- (void)testRegexRule {
    URBNCompatRegexRule *regexRule = URBNVMatch(@"\\d+");
    XCTAssertTrue([regexRule validateValue:nil], @"Null should be valid by default");
    XCTAssertFalse([regexRule validateValue:@"143k"], @"Anything but numbers should be considered failure");
    XCTAssertTrue([regexRule validateValue:@"123451880"], @"Numbers only should validate");
}

- (void)testLocalizationOverride {
    URBNCompatValidator *v = [URBNCompatValidator new];
    URBNCompatRequiredRule *r = URBNVRequired;
    r.localizationKey = @"URBNRequiredRule_Override";
    
    NSError *error = nil;
    [v validateKey:@"SomeKey" withValue:nil rule:r error:&error];
    XCTAssertEqual(error.isMultiError, NO);
    XCTAssertEqualObjects(error.localizedDescription, @"What the hell");
}

-(void)testDateRule {
    NSDate *currentDate = [NSDate date];
    XCTAssertTrue([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:currentDate]);
    XCTAssertTrue([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:currentDate key:@"current_test_key"]);

    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *futureDate = [cal dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentDate options:0];
    XCTAssertTrue([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:futureDate]);
    XCTAssertTrue([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:futureDate key:@"future_test_key"]);
    
    NSDate *pastDate = [cal dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentDate options:0];
    XCTAssertFalse([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:pastDate]);
    XCTAssertFalse([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:pastDate key:@"future_test_key"]);
    
    XCTAssertFalse([URBNVDateIsFuture(NSCalendarUnitMonth) validateValue:@"definitely not a date"]);
}

@end
