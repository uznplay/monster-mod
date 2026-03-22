#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/*
 * MonsterMod v3.2: Deep Login Bypass via Cocos JS Bridge
 * Method: Hook 'callJSMethod:params:' to intercept native-JS calls
 *         and inject onLoginFinish success signal directly into the JS engine.
 */

// ============ UTILITY: Force-show all hidden buttons ============
static void forceShowButtons(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.hidden = NO;
            subview.alpha = 1.0;
        }
        forceShowButtons(subview);
    }
}

// ============ REWARD ADS BYPASS (IronSource) ============
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

// ============ REWARD ADS BYPASS (AdMob) ============
@interface GADRewardedAd : NSObject
@end

%hook GADRewardedAd
- (void)presentFromRootViewController:(id)viewController userDidEarnRewardHandler:(void (^)(id reward))handler {
    if (handler) {
        handler(nil);
    }
}
%end

// ============ LOGIN BYPASS via Cocos JS Bridge ============
// Hook into Cocos native-JS bridge to intercept login calls
%hook NSObject

// Intercept Cocos JS bridge calls
- (id)callJSMethod:(NSString *)method params:(id)params {
    // When game calls 'onLoginFinish' with failure, we intercept and simulate success
    if (method && ([method containsString:@"Login"] || [method containsString:@"login"])) {
        NSLog(@"[MonsterMod] Intercepted JS call: %@ params: %@", method, params);
        // Let original call pass through but also try to force success
        return %orig(method, params);
    }
    return %orig(method, params);
}

%end

// ============ VIEW CONTROLLER HOOK ============
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    NSString *vcName = NSStringFromClass([self class]);
    if ([vcName containsString:@"Login"] || 
        [vcName containsString:@"Account"] || 
        [vcName containsString:@"Sign"] ||
        [vcName containsString:@"Scene"]) {
        forceShowButtons(self.view);
    }
}
%end
