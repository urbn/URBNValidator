#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double URBNValidatorVersionNumber;
FOUNDATION_EXPORT const unsigned char URBNValidatorVersionString[];


#define URBNVRequired [URBNRequiredRule new]
#define URBNVNotRequired [URBNNotRequiredRule new]

#define URBNVOverloadable static inline __attribute__((overloadable))