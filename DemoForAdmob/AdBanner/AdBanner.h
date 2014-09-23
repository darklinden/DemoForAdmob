//
//  AdBanner.h
//  DemoForAdmob
//
//  Created by darklinden on 14-9-23.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerView.h"
#import <iAd/iAd.h>

typedef enum {
    AdBannerADTypeIAD,
    AdBannerADTypeAdMobAds
} AdBannerADType;

typedef enum {
    
    /* length is the distance between adbanner and parent top
     ************************
     *          |           *
     *       length         *
     *          |           *
     ************************
     *         iad          *
     ************************
     *         ...          *
     ************************
     */
    AdBannerPositionTop,
    
    /* length is the distance between adbanner and parent bottom
     ************************
     *         ...          *
     ************************
     *         iad          *
     ************************
     *          |           *
     *       length         *
     *          |           *
     ************************
     */
    AdBannerPositionBottom
} AdBannerPosition;

//for content frame adjustment
#define AdBannerDidReciveAD    @"AdBannerDidReciveAD"

@interface AdBanner : GADBannerView
@property (unsafe_unretained, nonatomic, readonly)  AdBannerADType    currentADType;

//set auid
+ (void)setupAUID:(NSString *)auid testDevices:(NSArray *)devices;

//get current adbanner
+ (id)sharedBanner;

- (void)showInView:(UIView *)parentView
          position:(AdBannerPosition)position
            length:(CGFloat)length;

//temporarily remove adbanner, like hidden, still static retained
+ (void)removeADBanner;

//remove adbanner and release all static objects, as if purchased "remove Ads"
+ (void)clearADBanner;

@end
