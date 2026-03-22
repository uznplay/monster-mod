#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/*
 * MonsterMod v3: Instant Rewards + Skip Login
 * Key finding: game has 'updateCloseButtonSkipStyle' method which controls
 * the skip/close button visibility on the login screen.
 * We hook it to force-show the skip button.
 */

// ========== REWARD ADS BYPASS ==========
@interface ISRewardedVideoManager : NSObject
- (id)delegate;
@end

@protocol ISRewardedVideoDelegate <NSObject>
@optional
- (void)rewardedVideoHasBeenEarned:(id)placementInfo;
- (void)rewardedVideoDidClose:(id)placementInfo;
@end

%hook ISRewardedVideoManager
- (void)showRewardedVideoWithViewController:(id)viewController placementName:(id)placementName {
    // Skip ad, grant reward immediately
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

// ========== ADMOB ADS BYPASS ==========
@interface GADRewardedAd : NSObject
@end

%hook GADRewardedAd
- (void)presentFromRootViewController:(id)viewController userDidEarnRewardHandler:(void (^)(id reward))handler {
    if (handler) {
        handler(nil);
    }
}
%end

// ========== SKIP LOGIN BUTTON FORCE SHOW ==========
// The game has a method 'updateCloseButtonSkipStyle' which controls the login skip button.
// We will use runtime hooking to make it always show.
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    // Find close/skip buttons in the login screen and make them visible
    NSString *vcName = NSStringFromClass([self class]);
    if ([vcName containsString:@"Login"] || [vcName containsString:@"Account"] || [vcName containsString:@"Sign"]) {
        // Look for hidden close/skip button in view hierarchy
        [self forceShowSkipInView:self.view];
    }
}

%new
- (void)forceShowSkipInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        // Show any hidden button
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.hidden = NO;
            subview.alpha = 1.0;
        }
        [self forceShowSkipInView:subview];
    }
}

%end
