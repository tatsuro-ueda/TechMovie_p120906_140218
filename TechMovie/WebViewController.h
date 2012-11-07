//
//  WebViewController.h
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface WebViewController : UIViewController<UIWebViewDelegate, ADBannerViewDelegate>
{
    UIAlertView     *_alert;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property NSURL *URLForSegue;
@property (strong, nonatomic) IBOutlet UIView *actIndicatorBack;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *banner;

- (IBAction)jumpToPaidApp:(id)sender;

@end
