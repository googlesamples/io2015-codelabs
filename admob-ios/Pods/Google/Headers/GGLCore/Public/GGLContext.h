@import Foundation;

@class GGLConfiguration;
@class GGLIdentity;

/**
 * Main entry point for Google API core configuration. Developers should call
 * -[[GGLContext sharedInstance] configureWithError:] to configure the integrated services such as
 * AdMob, Analytics, AppInvite, CloudMessaging, SignIn, etc.
 *
 * If AdMob is integrated, developers should import GGLContext+AdMob.h. After calling
 * -[[GGLContext sharedInstance] configureWithError:],
 * | [GGLContext sharedInstance].adUnitIDForBannerTest |,
 * | [GGLContext sharedInstance].adUnitIDForInterstitialTest |,
 * | [GGLContext sharedInstance].bannerView | and | [GGLContext sharedInstance].interstitialView |
 * are ready for use.
 *
 * If Analytics is integrated, developers should import GGLContext+Analytics.h. [GAI sharedInstance]
 * and [[GAI sharedInstance] defaultTracker] should be ready to use after calling
 * -[[GGLContext sharedInstance] configureWithError:].
 *
 * If AppInvite is integrated, developers should import GGLContext+AppInvite.h.
 * [GIDSignIn sharedInstance], |[GGLContext sharedInstance].inviteDialog| and
 * |[GGLContext sharedInstance].targetApp| should be ready to use after calling
 * -[[GGLContext sharedInstance] configureWithError:].
 *
 * If CloudMessaging is integrated, developers should import GGLContext+CloudMessaging.h.
 * |[GGLContext sharedInstance].gcmSenderID| should be ready to use after calling
 * -[[GGLContext sharedInstance] configureWithError:]. Functions
 * -[fetchInstanceIDTokenWithAPNSToken:handler:], -[connectToGCMWithHandler:] and
 * -[disconnectFromGCM] can be used by importing GGLContext+CloudMessaging.h.
 *
 * If Google Sign In is integrated, developers should import GGLContext+SignIn.h.
 * [GIDSignIn sharedInstance] should be ready to use after calling
 * -[[GGLContext sharedInstance] configureWithError:].
 *
 * If Identity is integrated, developers should import GGLContext+Identity.h. A property of class 
 * |GGLIdentity| will be extended to this class. After calling
 * -[[GGLContext sharedInstance] configureWithError:], |[GGLContext sharedInstance].identity| will
 * be ready to use.
 *
 * @see GGLContext (Identity)
 * @see GGLContext (AdMob)
 * @see GGLContext (Analytics)
 * @see GGLContext (AppInvite)
 * @see GGLContext (CloudMessaging)
 * @see GGLContext (SignIn)
 */
@interface GGLContext : NSObject

/**
 * The configuration details for various Google APIs.
 */
@property(nonatomic, readonly, strong) GGLConfiguration *configuration;

/**
 * Get the shared instance of the Greenhouse main class.
 * @return the shared instance
 */
+ (instancetype)sharedInstance;

/**
 * Configures all the Google services integrated. This method should be called after the app is
 * launched and before using other Google services. The services will be available in categories
 * that extend this class. For example, the identity service can be used via -[GGLContext identity]
 * after calling this method.
 *
 * @param error Pointer to an NSError * that can be used an out param to report the status of this
 * operation. *error is nil of the operation is successful, otherwise it has an appropriate NSError
 * * value set. error cannot be nil.
 */
- (void)configureWithError:(NSError **)error;

@end
