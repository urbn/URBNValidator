//
//  ObjectTests.m
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/30/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
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
             @"requiredString": [[ValidatingValue alloc] init:self.requiredString rules:@[[URBNRequiredRule new]]],
             @"requiredList": [[ValidatingValue alloc] init:self.requiredList rules:@[[URBNRequiredRule new], [[URBNMinLengthRule alloc] initWithMinLength:3]]]
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
    
    NSError *error = nil;
    BOOL success = [self.vd validate:obj stopOnFirstError:YES error:&error];
    XCTAssertFalse(success, @"Should not be success");
    XCTAssertNotNil(error, @"We should have an error here");
    XCTAssertFalse([error isMultiError], @"We should not get a multi-error if we use stopOnFirst");
    XCTAssertEqualObjects(error.domain, @"ValidationError");
    XCTAssertEqualObjects(error.localizedDescription, @"\"requiredString\" is required");
}

@end
