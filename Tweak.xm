#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/*
 * MonsterMod v3.1: Instant Rewards + Skip Login
 */

// ============ UTILITY: C function to force-show all hidden buttons ============
static void forceShowButtons(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.hidden = NO;
            subview.alpha = 1.0;
        }
        forceShowButtons(subview);
    }
}

// ============ REWARD ADS BYPASS ============
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

// ============ ADMOB ADS BYPASS ============
@interface GADRewardedAd : NSObject
@end

%hook GADRewardedAd
- (void)presentFromRootViewController:(id)viewController userDidEarnRewardHandler:(void (^)(id reward))handler {
    if (handler) {
        handler(nil);
    }
}
%end

// ============ SKIP LOGIN BUTTON FORCE SHOW ============
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    NSString *vcName = NSStringFromClass([self class]);
    if ([vcName containsString:@"Login"] || 
        [vcName containsString:@"Account"] || 
        [vcName containsString:@"Sign"] ||
        [vcName containsString:@"Scene"]) {
        // Use the C function to show hidden skip/close buttons
        forceShowButtons(self.view);
    }
}
%end
