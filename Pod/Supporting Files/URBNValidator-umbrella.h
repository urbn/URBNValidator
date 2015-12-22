#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double URBNValidatorVersionNumber;
FOUNDATION_EXPORT const unsigned char URBNValidatorVersionString[];

#define URBNVRequired [[URBNCompatRequiredRule alloc] initWithLocalizationKey: nil]
#define URBNVNotRequired [[URBNCompatNotRequiredRule alloc] initWithLocalizationKey: nil]


#import "URBNVObjCShim.h"