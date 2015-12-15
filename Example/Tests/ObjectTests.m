//
//  ObjectTests.m
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/30/15.
//  Copyright © 2015 URBN. All rights reserved.
//

#import <XCTest/XCTest.h>
@import URBNValidator;

@interface TestObject: NSObject <Validateable>
@property (nonatomic, copy) NSString *requiredString;
@property (nonatomic, copy) NSArray *requiredList;
@end
@implementation TestObject

- (NSDictionary<NSString *,NSArray<id<ValidationRule>> *> *)validationMap {
    return @{
             @"requiredString": [[ValidatingValue alloc] init:self.requiredString rules:@[URBNVRequired]],
             @"requiredList": [[ValidatingValue alloc] init:self.requiredList rules:@[URBNVRequired, [[URBNMinLengthRule alloc] initWithMinLength:3 inclusive:YES]]]
             };
}

@end


@interface ObjectTests : XCTestCase
@property (nonatomic, strong) URBNValidator *vd;
@end

@implementation ObjectTests

- (void)setUp {
    [super setUp];
    self.vd = [URBNValidator new];
}

- (void)testSimpleModelValidaion {
    
    TestObject *obj = [TestObject new];
    obj.requiredList = @[@1, @2, @3];
    
    NSError *error = nil;
    BOOL success = [self.vd validate:obj stopOnFirstError:YES error:&error];
    XCTAssertFalse(success, @"Should not be success");
    XCTAssertEqualObjects(error.domain, ValidationErrorDomain, @"Error domain should be the invalid one");
    XCTAssertEqual(error.code, ValidationErrorFieldInvalid, @"Single field error here");
    XCTAssertFalse([error isMultiError], @"We should not get a multi-error if we use stopOnFirst");
    XCTAssertEqualObjects(error.localizedDescription, @"requiredString is required.");
}

- (void)testMutlipleErrorValidation {
    TestObject *obj = [TestObject new];
    
    NSError *error = nil;
    BOOL success = [self.vd validate:obj stopOnFirstError:NO error:&error];
    XCTAssertFalse(success, @"Should not be success");
    XCTAssertEqualObjects(error.domain, ValidationErrorDomain, @"Error domain should be the invalid one");
    XCTAssertEqual(error.code, ValidationErrorMultiFieldInvalid, @"Multiple field error here");
    XCTAssertTrue([error isMultiError], @"We should get a multi-error if stopOnFirst is NO");
    XCTAssertEqual([error underlyingErrors].count, 3, @"We should have 1 error for every invalid rule (3 in this case)");
}

@end