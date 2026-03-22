#import <UIKit/UIKit.h>

/*
 * MOD: Instant Reward for Monsters Must Die (iOS)
 * Targeted App: com.openew.monster
 * Description: Bypasses Reward Video Ads for Instant Rewards
 */

// --- Hook IronSource ---
%hook ISRewardedVideoManager
- (void)showRewardedVideoWithViewController:(id)viewController placementName:(NSString *)placementName {
    // Skip showing
    
    // Simulate reward
    id delegate = [self delegate];
    if (delegate && [delegate respondsToSelector:@selector(rewardedVideoHasBeenEarned:)]) {
        [delegate rewardedVideoHasBeenEarned:nil]; 
    }
    
    // Simulate close
    if (delegate && [delegate respondsToSelector:@selector(rewardedVideoDidClose:)]) {
        [delegate rewardedVideoDidClose:nil];
    }
}

- (BOOL)isRewardedVideoAvailable {
    return YES;
}
%end

// --- Hook AdMob (GAD) ---
%hook GADRewardedAd
- (void)presentFromRootViewController:(id)viewController userDidEarnRewardHandler:(void (^)(id reward))handler {
    if (handler) {
        handler(nil);
    }
}
%end

// --- Hook AppLovin MAX ---
%hook MAIncentivizedAd
- (void)showAd {
    // Most developers use delegate to catch reward
}
%end

// --- Hook UnityAds (Common in Cocos) ---
%hook UnityAds
+ (void)show:(NSString *)placementId {
}
%end
