//
//  MPAdDestinationDisplayAgent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdDestinationDisplayAgent.h"
#import "UIViewController+MPAdditions.h"
#import "MPCoreInstanceProvider.h"
#import "MPLastResortDelegate.h"
#import "NSURL+MPAdditions.h"

@interface MPAdDestinationDisplayAgent ()

@property (nonatomic, strong) MPURLResolver *resolver;
@property (nonatomic, strong) MPProgressOverlayView *overlayView;
@property (nonatomic, assign) BOOL isLoadingDestination;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
@property (nonatomic, strong) SKStoreProductViewController *storeKitController;
#endif

@property (nonatomic, strong) MPAdBrowserController *browserController;
@property (nonatomic, strong) MPTelephoneConfirmationController *telephoneConfirmationController;

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL;
- (void)hideOverlay;
- (void)hideModalAndNotifyDelegate;
- (void)dismissAllModalContent;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdDestinationDisplayAgent

@synthesize delegate = _delegate;
@synthesize resolver = _resolver;
@synthesize isLoadingDestination = _isLoadingDestination;

+ (MPAdDestinationDisplayAgent *)agentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    MPAdDestinationDisplayAgent *agent = [[MPAdDestinationDisplayAgent alloc] init];
    agent.delegate = delegate;
    agent.resolver = [[MPCoreInstanceProvider sharedProvider] buildMPURLResolver];
    agent.overlayView = [[MPProgressOverlayView alloc] initWithDelegate:agent];
    return agent;
}

- (void)dealloc
{
    [self dismissAllModalContent];

    self.overlayView.delegate = nil;
    self.resolver.delegate = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    // XXX: If this display agent is deallocated while a StoreKit controller is still on-screen,
    // nil-ing out the controller's delegate would leave us with no way to dismiss the controller
    // in the future. Therefore, we change the controller's delegate to a singleton object which
    // implements SKStoreProductViewControllerDelegate and is always around.
    self.storeKitController.delegate = [MPLastResortDelegate sharedDelegate];
#endif
    self.browserController.delegate = nil;

}

- (void)dismissAllModalContent
{
    [self.overlayView hide];
}

- (void)displayDestinationForURL:(NSURL *)URL
{
    if (self.isLoadingDestination) return;
    self.isLoadingDestination = YES;

    [self.delegate displayAgentWillPresentModal];
    [self.overlayView show];

    [self.resolver startResolvingWithURL:URL delegate:self];
}

- (void)cancel
{
    if (self.isLoadingDestination) {
        self.isLoadingDestination = NO;
        [self.resolver cancel];
        [self hideOverlay];
        [self.delegate displayAgentDidDismissModal];
    }
}

#pragma mark - <MPURLResolverDelegate>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    [self hideOverlay];

    self.browserController = [[MPAdBrowserController alloc] initWithURL:URL
                                                              HTMLString:HTMLString
                                                                delegate:self];
    self.browserController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:self.browserController
                                                                               animated:MP_ANIMATED];
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    if ([MPStoreKitProvider deviceHasStoreKit]) {
        [self presentStoreKitControllerWithItemIdentifier:parameter fallbackURL:URL];
    } else {
        [self openURLInApplication:URL];
    }
}

- (void)openURLInApplication:(NSURL *)URL
{
    [self hideOverlay];

    if ([URL mp_hasTelephoneScheme] || [URL mp_hasTelephonePromptScheme]) {
        [self interceptTelephoneURL:URL];
    } else {
        [self.delegate displayAgentWillLeaveApplication];
        [[UIApplication sharedApplication] openURL:URL];
        self.isLoadingDestination = NO;
    }
}

- (void)interceptTelephoneURL:(NSURL *)URL
{
    __weak MPAdDestinationDisplayAgent *weakSelf = self;
    self.telephoneConfirmationController = [[MPTelephoneConfirmationController alloc] initWithURL:URL clickHandler:^(NSURL *targetTelephoneURL, BOOL confirmed) {
        MPAdDestinationDisplayAgent *strongSelf = weakSelf;
        if (strongSelf) {
            if (confirmed) {
                [strongSelf.delegate displayAgentWillLeaveApplication];
                [[UIApplication sharedApplication] openURL:targetTelephoneURL];
            }
            strongSelf.isLoadingDestination = NO;
            [strongSelf.delegate displayAgentDidDismissModal];
        }
    }];

    [self.telephoneConfirmationController show];
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    self.isLoadingDestination = NO;
    [self hideOverlay];
    [self.delegate displayAgentDidDismissModal];
}

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    self.storeKitController = [MPStoreKitProvider buildController];
    self.storeKitController.delegate = self;

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:identifier
                                                           forKey:SKStoreProductParameterITunesItemIdentifier];
    [self.storeKitController loadProductWithParameters:parameters completionBlock:nil];

    [self hideOverlay];
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:self.storeKitController
                                                                               animated:MP_ANIMATED];
#endif
}

#pragma mark - <MPSKStoreProductViewControllerDelegate>
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <MPAdBrowserControllerDelegate>
- (void)dismissBrowserController:(MPAdBrowserController *)browserController animated:(BOOL)animated
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <MPProgressOverlayViewDelegate>
- (void)overlayCancelButtonPressed
{
    [self cancel];
}

#pragma mark - Convenience Methods
- (void)hideModalAndNotifyDelegate
{
    [[self.delegate viewControllerForPresentingModalView] mp_dismissModalViewControllerAnimated:MP_ANIMATED];
    [self.delegate displayAgentDidDismissModal];
}

- (void)hideOverlay
{
    [self.overlayView hide];
}

@end
