/*
 
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 
 * Unpublished Copyright (c) 2006-2014 PubMatic, All Rights Reserved.
 
 *
 
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
 
 * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 
 * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
 
 * Confidentiality and Non-disclosure agreements explicitly covering such access.
 
 *
 
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
 
 * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
 
 * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
 
 * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 
 */

//
//  MASTSSimpleInterstitialDirect.m
//  Samples
//
//  Created on 9/25/12.

//

#import "MASTSSimpleInterstitialDirect.h"

@interface MASTSSimpleInterstitialDirect ()
@property (nonatomic, retain) MASTAdView* interstitialAdView;
@end

@implementation MASTSSimpleInterstitialDirect

@synthesize interstitialAdView;

- (void)dealloc
{
    [self.interstitialAdView setDelegate:nil];
    [self.interstitialAdView reset];
    self.interstitialAdView = nil;
    
    [super dealloc];
}

- (void)refresh:(id)sender
{
    MASTSAdConfigPrompt* prompt = [[[MASTSAdConfigPrompt alloc] initWithDelegate:self
                                                                            zone:self.interstitialAdView.zone] autorelease];
    [prompt show];
}

- (void)loadView
{
    [super loadView];
    
    // Remove the banner ad from the view form the Simple base class.
    [self.adView removeFromSuperview];
    [self.adView reset];
    
    // This method for interstitial doesn't require developers to place
    // and manage the interstitial view itself.  Instead it can display
    // the interstitial directly on the mainScreen with it's show and
    // close interstitial methods.  In this implementation the interstitial
    // is created on first view load and re-used when the user presses
    // the show button.  After an update and an ad is received the ad is
    // presented with showInterstitial.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.interstitialAdView == nil)
    {
        self.interstitialAdView = [[[MASTAdView alloc] initInterstitial] autorelease];
        
        self.interstitialAdView.zone = 88269;
        
        self.interstitialAdView.logLevel = MASTAdViewLogEventTypeDebug;
        self.interstitialAdView.delegate = self;
        [self.interstitialAdView showCloseButton:YES afterDelay:3];
        
        [self.interstitialAdView update];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark -

- (void)configPrompt:(MASTSAdConfigPrompt *)prompt refreshWithZone:(NSInteger)zone
{
    self.interstitialAdView.zone = zone;
    
    // Since the UIAlertView seems to nil out the keyWindow used by the SDK, must "wait" for the
    // alert view to finish and hide itself before attempting to update the ad.  Else if the update
    // happens too quickly the showInterstitial may occur before the dialog is dismissed and without
    // providing the MASTAdViewPresentingViewController to return one it won't be able to show.
    //
    // Applications should generally not have to deal with this since most interstitials will be
    // sourced by view transitions.  This is here simply becuase Samples uses a UIAlertView to
    // manually refresh ads for sample purposes.
    //
    //[self.interstitialAdView performSelector:@selector(update) withObject:nil afterDelay:1];
    
    // The above would be necessary prior to MAST SDK 3.1.  It may still be possible on some
    // applications to get into the same situation so it's preserved in comments for reference.
    [self.interstitialAdView update];
}

#pragma mark -

- (void)MASTAdView:(MASTAdView *)adView didFailToReceiveAdWithError:(NSError *)error
{
    
}

- (void)MASTAdViewDidRecieveAd:(MASTAdView *)adView
{
    [adView showInterstitial];
}

- (void)MASTAdViewCloseButtonPressed:(MASTAdView *)adView
{
    [adView closeInterstitial];
}

@end
