//
//  Defines.h
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/15/15.
//
//

@import Foundation;

#define URBNVOverloadable extern __attribute__((overloadable))

URBNVOverloadable id __nonnull URBNVGreaterThan(NSInteger minValue);
URBNVOverloadable id __nonnull URBNVGreaterThan(NSInteger minValue, NSString * __nullable localizeString);
URBNVOverloadable id __nonnull URBNVGreaterThanOrEqual(NSInteger minValue);
URBNVOverloadable id __nonnull URBNVGreaterThanOrEqual(NSInteger minValue, NSString * __nullable localizeString);

URBNVOverloadable id __nonnull URBNVLessThan(NSInteger minValue);
URBNVOverloadable id __nonnull URBNVLessThan(NSInteger minValue, NSString * __nullable localizeString);
URBNVOverloadable id __nonnull URBNVLessThanOrEqual(NSInteger minValue);
URBNVOverloadable id __nonnull URBNVLessThanOrEqual(NSInteger minValue, NSString * __nullable localizeString);

URBNVOverloadable id __nonnull URBNVMatch(NSString * __nonnull pattern);
URBNVOverloadable id __nonnull URBNVMatch(NSString * __nonnull pattern, NSString * __nullable localizeString);


URBNVOverloadable id __nonnull URBNVBlock(BOOL (^ __nonnull checker)(id __nullable val));
URBNVOverloadable id __nonnull URBNVBlock(NSString * __nullable localizeString, BOOL (^ __nonnull checker)(id __nullable val));
