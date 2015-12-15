#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double URBNValidatorVersionNumber;
FOUNDATION_EXPORT const unsigned char URBNValidatorVersionString[];

#define URBNVRequired [[URBNRequiredRule alloc] initWithLocalizationKey: nil]
#define URBNVNotRequired [[URBNNotRequiredRule alloc] initWithLocalizationKey: nil]


#import "URBNVObjCShim.h"