#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double URBNValidatorVersionNumber;
FOUNDATION_EXPORT const unsigned char URBNValidatorVersionString[];

#import "URBNValidator-Swift.h"

#define URBNVOverloadable static inline __attribute__((overloadable))
#define URBNVRequired [URBNRequiredRule new]
#define URBNVNotRequired [URBNNotRequiredRule new]



#pragma mark - Greater Than
URBNVOverloadable id __nonnull URBNVGreaterThan(NSInteger minValue) {
    return [[URBNMinLengthRule alloc] initWithMinLength: minValue];
}

URBNVOverloadable id __nonnull URBNVGreaterThan(NSInteger minValue, NSString * __nullable localizeString) {
    URBNMinLengthRule *r = [[URBNMinLengthRule alloc] initWithMinLength: minValue];
    if ([localizeString length] > 0) {
        r.localizationKey = localizeString;
    }
    return r;
}

URBNVOverloadable id __nonnull URBNVGreaterThanOrEqual(NSInteger minValue) {
    return [[URBNMinLengthRule alloc] initWithMinLength: minValue inclusive: YES];
}

#pragma mark - Less than
URBNVOverloadable id __nonnull URBNVLessThan(NSInteger minValue) {
    return [[URBNMaxLengthRule alloc] initWithMaxLength: minValue];
}

URBNVOverloadable id __nonnull URBNVLessThan(NSInteger minValue, NSString * __nullable localizeString) {
    URBNMaxLengthRule *r = [[URBNMaxLengthRule alloc] initWithMaxLength: minValue];
    if ([localizeString length] > 0) {
        r.localizationKey = localizeString;
    }
    return r;
}

URBNVOverloadable id __nonnull URBNVLessThanOrEqual(NSInteger minValue) {
    return [[URBNMaxLengthRule alloc] initWithMaxLength: minValue inclusive: YES];
}

#pragma mark - Matching
URBNVOverloadable id __nonnull URBNVMatch(NSString * __nonnull pattern) {
    return [[URBNRegexRule alloc] initWithPattern: pattern];
}

URBNVOverloadable id __nonnull URBNVMatch(NSString * __nonnull pattern, NSString * __nullable localizeString) {
    URBNRegexRule *r = [[URBNRegexRule alloc] initWithPattern: pattern];
    if ([localizeString length] > 0) {
        r.localizationKey = localizeString;
    }
    return r;
}

#pragma mark - Blocks
URBNVOverloadable id __nonnull URBNVBlock(BOOL (^ __nonnull checker)(id __nullable val)) {
    return [[URBNBlockRule alloc] initWithValidator:checker];
}

URBNVOverloadable id __nonnull URBNVBlock(NSString * __nullable localizeString, BOOL (^ __nonnull checker)(id __nullable val)) {
    URBNBlockRule *r = [[URBNBlockRule alloc] initWithValidator:checker];
    if ([localizeString length] > 0) {
        r.localizationKey = localizeString;
    }
    return r;
}