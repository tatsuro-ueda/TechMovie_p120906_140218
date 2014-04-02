//
//  FeedsTableViewController.h
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <LBGIFImage/UIImage+GIF.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "MyUtility.h"

@class RSSParser;

@interface FeedsTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    NSMutableArray  *ogImages;
    NSMutableArray  *bkmImages;
    UIProgressView  *progressView;
    UIAlertView     *progressAlertView;
    NSOperationQueue *queue;
    UIAlertView     *alertViewInvitation;
    NSTimer         *timerIncrease;
    NSTimer         *timerDecrease;
    UIAlertView     *infoAlertView;
}
// リストに表示するアイテムを格納する配列
// 各要素は「RSSEntry」クラスのインスタンスとする

@property RSSParser *parser;
@property NSArray *itemsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
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
