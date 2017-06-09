#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MagicPieLayer.h"
#import "NSMutableArray+pieEx.h"
#import "PieElement.h"
#import "PieLayer.h"

FOUNDATION_EXPORT double MagicPieVersionNumber;
FOUNDATION_EXPORT const unsigned char MagicPieVersionString[];

