#import <UIKit/UIKit.h>

/*
 * MonsterMod v2: Instant Rewards + Login Bypass
 */

@interface ISRewardedVideoManager : NSObject
- (id)delegate;
@end

@protocol ISRewardedVideoDelegate <NSObject>
@optional
- (void)rewardedVideoHasBeenEarned:(id)placementInfo;
- (void)rewardedVideoDidClose:(id)placementInfo;
@end

// --- Hook IronSource ---
%hook ISRewardedVideoManager
- (void)showRewardedVideoWithViewController:(id)viewController placementName:(id)placementName {
    id delegate = [self delegate];
    if (delegate && [delegate respondsToSelector:@selector(rewardedVideoHasBeenEarned:)]) {
        [delegate rewardedVideoHasBeenEarned:nil]; 
    }
    if (delegate && [delegate respondsToSelector:@selector(rewardedVideoDidClose:)]) {
        [delegate rewardedVideoDidClose:nil];
    }
}
- (BOOL)isRewardedVideoAvailable {
    return YES;
}
%end

// --- Hook Apple Sign In Bypass ---
@interface ASAuthorizationController : NSObject
- (id)delegate;
@end

%hook ASAuthorizationController
- (void)performRequests {
    // Attempt to bypass by calling delegate immediately
    id delegate = [self delegate];
    if (delegate && [delegate respondsToSelector:@selector(authorizationController:didCompleteWithAuthorization:)]) {
        [delegate authorizationController:self didCompleteWithAuthorization:nil];
    }
}
%end

// --- Hook GADRewardedAd ---
@interface GADRewardedAd : NSObject
@end

%hook GADRewardedAd
- (void)presentFromRootViewController:(id)viewController userDidEarnRewardHandler:(void (^)(id reward))handler {
    if (handler) {
        handler(nil);
    }
}
%end
