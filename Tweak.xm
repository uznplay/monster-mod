#import <UIKit/UIKit.h>

/*
 * Fixed Mod: Instant Reward for Monsters Must Die
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
    // Skipping orig
    
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

// --- Hook AdMob (GAD) ---
@interface GADRewardedAd : NSObject
@end

%hook GADRewardedAd
- (void)presentFromRootViewController:(id)viewController userDidEarnRewardHandler:(void (^)(id reward))handler {
    if (handler) {
        handler(nil);
    }
}
%end
