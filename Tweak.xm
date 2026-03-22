#import <UIKit/UIKit.h>

/*
 * MonsterMod v2.1: Fix Apple Sign In Protocol
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

// --- Apple Sign In Protocol ---
@protocol ASAuthorizationControllerDelegate <NSObject>
@optional
- (void)authorizationController:(id)controller didCompleteWithAuthorization:(id)authorization;
- (void)authorizationController:(id)controller didCompleteWithError:(id)error;
@end

@interface ASAuthorizationController : NSObject
- (id)delegate;
@end

// --- Hook Apple Sign In Bypass ---
%hook ASAuthorizationController
- (void)performRequests {
    // Attempt to bypass by calling delegate success immediately
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
