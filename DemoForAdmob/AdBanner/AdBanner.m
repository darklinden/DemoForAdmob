//
//  AdBanner.m
//  DemoForAdmob
//
//  Created by darklinden on 14-9-23.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import "AdBanner.h"

__strong static NSMutableDictionary     *staticOption = nil;
__strong static AdBanner                *staticAdBanner = nil;

const NSString *kAUID    = @"kAUID";
const NSString *kDevices = @"kDevices";

@interface AdBanner () <GADBannerViewDelegate>
@property (unsafe_unretained) AdBannerPosition      ePosition;
@property (unsafe_unretained) CGFloat               fLength;
@property (unsafe_unretained) BOOL                  boolHasGetAD;

@end

@implementation AdBanner

+ (void)setupAUID:(NSString *)auid testDevices:(NSArray *)devices
{
    if (!staticOption) {
        staticOption = [NSMutableDictionary dictionary];
    }
    
    if (auid) {
        [staticOption setObject:[auid copy] forKey:kAUID];
    }
    
    if (devices) {
        [staticOption setObject:[devices copy] forKey:kDevices];
    }
}

+ (GADAdSize)orientationSize:(UIInterfaceOrientation)orientation
{
    GADAdSize size = kGADAdSizeBanner;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            size = kGADAdSizeSmartBannerPortrait;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            size = kGADAdSizeSmartBannerLandscape;
            break;
        default:
            break;
    }
    return size;
}

+ (GADAdSize)smartSize
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return [self orientationSize:orientation];
}

+ (id)sharedBanner
{
    if (!staticOption || !staticOption[kAUID]) {
        [NSException raise:@"AdBanner didn't setup AUID exception." format:nil];
    }
    
    if (!staticAdBanner) {
        staticAdBanner = [[AdBanner alloc] initWithAdSize:[self smartSize]];
        staticAdBanner.adUnitID = staticOption[kAUID];
        staticAdBanner.rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        staticAdBanner.translatesAutoresizingMaskIntoConstraints = NO;
        [staticAdBanner loadRequest:[staticAdBanner createRequest]];
    }
    return staticAdBanner;
}

- (GADRequest *)createRequest
{
    GADRequest *request = [GADRequest request];
    
    if (staticOption[kDevices]) {
        request.testDevices = staticOption[kDevices];
    }
    
    return request;
}

- (void)showInView:(UIView *)parentView position:(AdBannerPosition)position length:(CGFloat)length
{
    if (self.superview) {
        if ([self.superview isEqual:parentView]) {
            if (_ePosition == position
                && _fLength == length) {
                //every thing is the same, no need to change
                return;
            }
            else {
                //the same view different position, reset related constraint
                for (NSLayoutConstraint *cn in self.superview.constraints) {
                    if ([cn.firstItem isEqual:self]
                        || [cn.secondItem isEqual:self]) {
                        [self.superview removeConstraint:cn];
                    }
                }
            }
        }
        else {
            // change superView, remove and add
            [[self class] removeADBanner];
            [parentView addSubview:self];
        }
    }
    else {
        //no superView, add sub view
        [parentView addSubview:self];
    }
    
    // change size and constraint
    self.adSize = [[self class] smartSize];
    
    _ePosition = position;
    _fLength = length;
    
    //layout X center
    [parentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:parentView
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
    
    //layout Y
    switch (position) {
        case AdBannerPositionTop:
            [parentView addConstraint:
             [NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:parentView
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:_fLength]];
            break;
        case AdBannerPositionBottom:
            [parentView addConstraint:
             [NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:parentView
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:-_fLength]];
            break;
    }
}

+ (void)removeADBanner
{
    //remove all related constraint
    for (NSLayoutConstraint *cn in staticAdBanner.superview.constraints) {
        if ([cn.firstItem isEqual:staticAdBanner]
            || [cn.secondItem isEqual:staticAdBanner]) {
            [staticAdBanner.superview removeConstraint:cn];
        }
    }
    
    //remove view
    [staticAdBanner removeFromSuperview];
}

+ (void)clearADBanner
{
    [staticAdBanner removeFromSuperview];
    staticAdBanner.delegate = nil;
    staticAdBanner = nil;
}

- (AdBannerADType)currentADType
{
    BOOL boolGetIAD = NO;
    
    for (UIView *pV in self.subviews) {
        if ([pV isKindOfClass:[ADBannerView class]]) {
            boolGetIAD = YES;
            break;
        }
    }
    
    if (boolGetIAD) {
        return AdBannerADTypeIAD;
    }
    else {
        return AdBannerADTypeAdMobAds;
    }
}

- (id)initWithAdSize:(GADAdSize)size{
    self = [super initWithAdSize:size];
    if (self) {
        self.delegate = self;
        self.hidden = YES;
        self.boolHasGetAD = NO;
    }
    return self;
}

- (void)willRotate:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    NSNumber *ornum = info[UIApplicationStatusBarOrientationUserInfoKey];
    UIInterfaceOrientation orientation = ornum.integerValue;
    self.adSize = [[self class] orientationSize:orientation];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.superview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    self.boolHasGetAD = YES;
    self.hidden = NO;
    
#if DEBUG
    NSLog(@"adViewDidReceiveAdClassName %@", self.adNetworkClassName);
#endif
    
    switch (self.currentADType) {
        case AdBannerADTypeIAD:
#if DEBUG
            NSLog(@"adViewDidReceiveAd iAd");
#endif
            break;
        case AdBannerADTypeAdMobAds:
#if DEBUG
            NSLog(@"adViewDidReceiveAd AdMob");
#endif
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AdBannerDidReciveAD object:nil];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
#if DEBUG
    NSLog(@"adViewdidFailToReceiveAdWithError %@", error.localizedDescription);
#endif
}

@end


