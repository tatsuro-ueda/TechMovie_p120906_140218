//
//  FeedsTableViewController.h
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <AFNetworking/AFNetworking.h>
#import <LBGIFImage/UIImage+GIF.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@class RSSParser;

@interface FeedsTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate, UIAlertViewDelegate>
{
    NSArray         *_itemsArray;
    NSMutableArray  *_ogImages;
    NSMutableArray  *_bkmImages;
    UIProgressView  *_progressView;
    UIAlertView     *_progressAlertView;
    NSOperationQueue *_queue;
    UIAlertView     *_alertViewInvitation;
    NSTimer         *_timerIncrease;
    NSTimer         *_timerDecrease;
//    RSSParser       *_parser;
    UIAlertView     *_infoAlertView;
}
// リストに表示するアイテムを格納する配列
// 各要素は「RSSEntry」クラスのインスタンスとする

@property (strong) RSSParser *parser;
@property (strong) NSArray *itemsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ADBannerView *adView;
@property __weak NSBlockOperation *weakOperation;
@property (strong, nonatomic) IBOutlet UITableView *banner;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;

- (void)reloadFromContentsOfURLsFromArray:(NSArray *)urlsArray fileName:(NSString *)fileName performer:(id)performer;
- (NSArray *)itemsArrayFromContentsOfURL:(NSURL *)url fileName:(NSString *)fileName performer:(id)performer;
- (NSURL *)urlAtIndex:(NSInteger)index;
- (void)requestTableData;

- (IBAction)showSetting:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)jumpToPaidApp:(id)sender;
- (void)enableRefreshBotton;

@end
