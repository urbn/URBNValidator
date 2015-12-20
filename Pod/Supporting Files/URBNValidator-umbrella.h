#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double URBNValidatorVersionNumber;
FOUNDATION_EXPORT const unsigned char URBNValidatorVersionString[];

#define URBNVRequired [[CompatRequiredRule alloc] initWithLocalizationKey: nil]
#define URBNVNotRequired [[CompatNotRequiredRule alloc] initWithLocalizationKey: nil]


#import "URBNVObjCShim.h"