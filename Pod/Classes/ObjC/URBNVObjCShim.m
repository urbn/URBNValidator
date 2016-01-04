//
//  URBNVObjCShim.m
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/15/15.
//
//

#import "URBNVObjCShim.h"

#import <URBNValidator/URBNValidator-Swift.h>

#pragma mark - Greater Than
URBNVOverloadable id __nonnull URBNVGreaterThan(NSInteger minValue) {
    return URBNVGreaterThan(minValue, nil);
}

URBNVOverloadable id __nonnull URBNVGreaterThan(NSInteger minValue, NSString * __nullable localizeString) {
    return [[URBNCompatMinLengthRule alloc] initWithMinLength:minValue inclusive:NO localizationKey:localizeString];
}

URBNVOverloadable id __nonnull URBNVGreaterThanOrEqual(NSInteger minValue) {
    return URBNVGreaterThanOrEqual(minValue, nil);
}

URBNVOverloadable id __nonnull URBNVGreaterThanOrEqual(NSInteger minValue, NSString * __nullable localizeString) {
    return [[URBNCompatMinLengthRule alloc] initWithMinLength:minValue inclusive:YES localizationKey:localizeString];
}

#pragma mark - Less than
URBNVOverloadable id __nonnull URBNVLessThan(NSInteger minValue) {
    return URBNVLessThan(minValue, nil);
}

URBNVOverloadable id __nonnull URBNVLessThan(NSInteger minValue, NSString * __nullable localizeString) {
    return [[URBNCompatMaxLengthRule alloc] initWithMaxLength:minValue inclusive:NO localizationKey:localizeString];
}

URBNVOverloadable id __nonnull URBNVLessThanOrEqual(NSInteger minValue) {
    return URBNVLessThanOrEqual(minValue, nil);
}

URBNVOverloadable id __nonnull URBNVLessThanOrEqual(NSInteger minValue, NSString * __nullable localizeString) {
    return [[URBNCompatMaxLengthRule alloc] initWithMaxLength:minValue inclusive:YES localizationKey:localizeString];
}

#pragma mark - Matching
URBNVOverloadable id __nonnull URBNVMatch(NSString * __nonnull pattern) {
    return URBNVMatch(pattern, nil);
}

URBNVOverloadable id __nonnull URBNVMatch(NSString * __nonnull pattern, NSString * __nullable localizeString) {
    return [[URBNCompatRegexRule alloc] initWithPattern: pattern localizationKey: localizeString];
}

#pragma mark - Blocks
URBNVOverloadable id __nonnull URBNVBlock(BOOL (^ __nonnull checker)(id __nullable val)) {
    return URBNVBlock(nil, checker);
}

URBNVOverloadable id __nonnull URBNVBlock(NSString * __nullable localizeString, BOOL (^ __nonnull checker)(id __nullable val)) {
    return [[URBNCompatBlockRule alloc] initWithValidator:checker localizationKey:localizeString];
}

#pragma mark - Dates
URBNVOverloadable id __nonnull URBNVDateIsFuture(NSString * __nullable localizeString) {
    return [[URBNCompatDateRule alloc] initWithComparisonType:URBNDateComparisionFuture localizationKey:localizeString];
}
