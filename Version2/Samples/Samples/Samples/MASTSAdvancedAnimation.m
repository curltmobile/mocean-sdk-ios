//
//  MASTSAdvancedAnimation.m
//  AdMobileSamples
//
//  Created by Jason Dickert on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSAdvancedAnimation.h"

@interface MASTSAdvancedAnimation ()

@end

@implementation MASTSAdvancedAnimation

- (void)loadView
{
    [super loadView];
    
    super.adView.showPreviousAdOnError = NO;
    super.adView.logMode = AdLogModeErrorsOnly;
    super.adView.delegate = self;
    super.adView.autoCollapse = NO;
    
    // Take the simple configuration frame (top banner) and move it off screen
    // until an ad is displayed then move/animate it on screen.
    CGRect frame = self.adView.frame;
    frame.origin.y -= frame.size.height;
    self.adView.frame = frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 88269;
    
    super.adView.site = site;
    super.adView.zone = zone;
    
    super.adConfigController.site = site;
    super.adConfigController.zone = zone;
}

#pragma mark - animations

- (void)animateHideAd
{
    CGRect frame = self.adView.frame;
    frame.origin.y = 0 - frame.size.height;
    self.adView.frame = frame;
}

- (void)animateShowAd
{
    [UIView animateWithDuration:.5
                     animations:^
     {
         CGRect frame = self.adView.frame;
         frame.origin.y = 0;
         self.adView.frame = frame;
     }];
}

#pragma mark - MASTAdViewDelegate

- (void)willReceiveAd:(id)sender
{
    NSLog(@"willReceiveAd");
}

- (void)didReceiveAd:(id)sender
{
    NSLog(@"didReceiveAd");

    [self performSelectorOnMainThread:@selector(animateShowAd) withObject:nil waitUntilDone:NO];
}

- (void)didFailToReceiveAd:(id)sender withError:(NSError *)error
{
    NSLog(@"didFailToReceiveAd");
    
    [self performSelectorOnMainThread:@selector(animateHideAd) withObject:nil waitUntilDone:NO];
}

#pragma mark

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self animateHideAd];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)updateAdWithConfig:(MASTSAdConfigController *)configController
{
    [self animateHideAd];
    [super updateAdWithConfig:configController];
}
@end
