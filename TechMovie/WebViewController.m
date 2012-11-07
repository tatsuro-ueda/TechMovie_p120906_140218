//
//  WebViewController.m
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "Const.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webView;
@synthesize URLForSegue;
@synthesize actIndicatorBack;
@synthesize actIndicator;

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
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"html"];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    
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
    [self setBanner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSInteger numAct = [[NSUserDefaults standardUserDefaults] integerForKey:@"numAct"];
    if (numAct < 5) {
        _banner.hidden = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // 動画なので回転に対応するが上下反対はアウト
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alert)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)jumpToPaidApp:(id)sender {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:URLPayed]];
}

@end