#import "GGLContext.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

/**
 * This category extends |GGLContext| with the mobile ads service.
 *
 * @see GGLContext
 */
@interface GGLContext (AdMob)

/**
 * @property
 * Provides an AdUnitID to use the banner view. This value can be updated by changing the
 * AD_UNIT_ID_FOR_BANNER_TEST in GoogleService-Info.plist.
 */
@property(nonatomic, readonly, strong) NSString *adUnitIDForBannerTest;

/**
 * @property
 * Provides an AdUnitID to use the interstitial view. This value can be updated by changing
 * the AD_UNIT_ID_FOR_INTERSTITIAL_TEST in GoogleService-Info.plist.
 */
@property(nonatomic, readonly, strong) NSString *adUnitIDForInterstitialTest;

/**
 * @property
 * Provides a bannerView configured using adUnitIDForBannerTest.
 */
@property(nonatomic, strong) GADBannerView *bannerView;

/**
 * @property
 * Provides an interstitialView configured using adUnitIDForInterstitialTest.
 */
@property(nonatomic, strong) GADInterstitial *interstitialView;

@end
