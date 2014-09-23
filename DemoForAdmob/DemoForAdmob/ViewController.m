//
//  ViewController.m
//  DemoForAdmob
//
//  Created by darklinden on 14-9-23.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import "ViewController.h"
#import "AdBanner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //you can run this function every time appear, the banner won't be recreated
    [[AdBanner sharedBanner] showInView:self.view position:AdBannerPositionBottom length:50.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
