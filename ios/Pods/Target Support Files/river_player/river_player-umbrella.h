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

#import "BetterPlayer.h"
#import "BetterPlayerEzDrmAssetsLoaderDelegate.h"
#import "BetterPlayerTimeUtils.h"
#import "BetterPlayerView.h"
#import "RiverPlayerPlugin.h"

FOUNDATION_EXPORT double river_playerVersionNumber;
FOUNDATION_EXPORT const unsigned char river_playerVersionString[];

