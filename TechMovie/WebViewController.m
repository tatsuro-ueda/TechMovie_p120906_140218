//
//  WebViewController.m
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webView;
@synthesize URLForSegue;
@synthesize actIndicatorBack;
@synthesize actIndicator;
@synthesize adView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    @try {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URLForSegue]];
    }
    @catch (NSException *exception) {
        _alert = [[UIAlertView alloc] init];
        _alert.title = [NSString stringWithFormat:@"エラー"];
        _alert.message = [NSString stringWithFormat:@"%@", exception.description];
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"OK"];
        [_alert show];
    }
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"%@", self.URLForSegue];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActIndicatorBack:nil];
    [self setActIndicator:nil];
    [self setAdView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // 動画なので回転に対応するが上下反対はアウト
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    else {
        self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [actIndicator startAnimating];
    actIndicatorBack.hidden = NO;
    self.navigationController.navigationBar.topItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [actIndicator stopAnimating];
    actIndicatorBack.hidden = YES;
    self.navigationController.navigationBar.topItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.adView.hidden) {
        self.adView.hidden = NO;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.adView.hidden == NO) {
        self.adView.hidden = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alert)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
