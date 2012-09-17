//
//  FeedsTableViewController.m
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedsTableViewController.h"
#import "RSSParser.h"
#import "RSSEntry.h"
#import "WebViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "UIImage+GIF.h"
#import "GANTracker.h"
#import "Const.h"

#define TEST

const NSString *kStrURLPipesWith2Keywords = @"http://p120908-new-movies-server.herokuapp.com/new_movie?";
const NSString *kStrURLPipesWith1Keyword = @"http://p120908-new-movies-server.herokuapp.com/new_movie?";

// リストアイテムのソート用関数
// 日付の降順ソートで使用する
static NSInteger dateDescending(id item1, id item2, void *context)
{
    // ここでは比較対象が必ず「RSSListTableDataSource」クラスの
    // 「_listItemsArray」の要素となる（それ以外の場所から呼び出さないため）
    
    NSDate *date1 = [item1 date];
    NSDate *date2 = [item2 date];
    
    return [date2 compare:date1];
}

@interface FeedsTableViewController ()

@end

@implementation FeedsTableViewController
@synthesize itemsArray = _itemsArray;
@synthesize tableView = _tableView;
@synthesize adView = _adView;
@synthesize weakOperation;

// Storyboardファイルからインスタンスが作成されたときに
// 使われるイニシャライザメソッド
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // インスタンス変数の初期化
        _itemsArray = nil;
        _ogImages = [NSMutableArray array];
        _bkmImages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];

    // デフォルトの通知センターを取得する
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // 通知センターに通知要求を登録する
    // この例だと、通知センターに"requestTableData"という名前の通知がされた時に、
    // requestTableDataメソッドを呼び出すという通知要求の登録を行っている。
    NSString *requestTableData = [NSString stringWithFormat:@"requestTableData"];
    [nc addObserver:self selector:@selector(requestTableData) name:requestTableData object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setItemsArray:nil];
    [self setAdView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewWillAppear:animated];
    
    // ユーザーデフォルトからキーワードを読み込む
    NSString *keywordPlainString0 = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyword0"];
    
    // ナビゲーションバーの表示を変更する
    [self reloadNavBarTitleWithString:keywordPlainString0];
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"/tableView/%@", keywordPlainString0];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)requestTableData
{
    // URLの配列を作成するためユーザーデフォルトからキーワードを読み込む
    NSString *keywordPlainString0 = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyword0"];
    NSString *keywordPlainString1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyword1"];

    // ナビゲーションバーの表示を変更する
    [self reloadNavBarTitleWithString:keywordPlainString0];
    
    // 「読込中」のアラートビューを表示する
    _progressAlertView = [[UIAlertView alloc] initWithTitle:@"読み込んでいます"
                                                        message:@"\n\n"
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                              otherButtonTitles:nil];
    _progressView = [[UIProgressView alloc]
                     initWithFrame:CGRectMake(30.0f, 60.0f, 225.0f, 90.0f)];
    [_progressAlertView addSubview:_progressView];
    [_progressView setProgressViewStyle: UIProgressViewStyleBar];
    _timerIncrease = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                      target:self
                                                    selector:@selector(increaseProgressBar)
                                                    userInfo:nil
                                                     repeats:YES];
    [_progressAlertView show];
    
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    weakOperation = operation;
    [operation addExecutionBlock:^{
        /*
         * Yahoo Pipesに問い合わせるURLをつくる
         */
        NSString *escapedUrlString0 = [keywordPlainString0
                                       stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *escapedUrlString1 = @"";
        NSString *myPipeURLString;
        if ([keywordPlainString1 isEqualToString:@""]) {
            myPipeURLString =
            [NSString stringWithFormat:@"%@&tag1=%@", kStrURLPipesWith1Keyword, escapedUrlString0];
        }
        else{
            escapedUrlString1 = [keywordPlainString1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            myPipeURLString =
            [NSString stringWithFormat:@"%@&tag1=%@&tag2=%@", kStrURLPipesWith2Keywords, escapedUrlString0, escapedUrlString1];
        }
#ifdef TEST
        NSLog(@"%@", myPipeURLString);
#endif
        
        // urlArrayをつくる
        NSArray *urls = [NSArray arrayWithObject:myPipeURLString];
        NSMutableArray *urlArray = [NSMutableArray array];
        for (NSString *str in urls) {
            NSURL *url = [NSURL URLWithString:str];
            if (url) {
                [urlArray addObject:url];
            }
        }
        
        // 「URLエスケープした文字列0__URLエスケープした文字列1.dat」に保存する
        NSString *fileName = [NSString stringWithFormat:@"%@__%@.dat", escapedUrlString0, escapedUrlString1];
        
        // 「キャンセル」されたら止める
        if(weakOperation.isCancelled){
            return;
        }

        // RSSファイルを読み込む
        [self reloadFromContentsOfURLsFromArray:urlArray fileName:fileName performer:self];
        
        // 「キャンセル」されたら止める
        if(weakOperation.isCancelled){
            return;
        }

        /*
         * 検索結果を保存する
         */
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        BOOL successful = [NSKeyedArchiver archiveRootObject:self.itemsArray toFile:filePath];
        if (successful) {
            NSLog(@"%@", @"データの保存に成功しました。");
        }
        
        // メインスレッドに戻す
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            
            /*
             * 検索結果を整えて表示する
             */
            // テーブル更新
            [_timerIncrease invalidate];
            [_progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
            [self.tableView reloadData];
            
            // テーブルの一番上へ
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            
            // 新着動画の件数を表示する
            NSInteger numNewEntry = 0;
            for (RSSEntry *entry in self.itemsArray) {
                if (entry.isNewEntry) {
                    numNewEntry++;
                }
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] init];
            if (numNewEntry > 0) {
                alertView.title = [NSString stringWithFormat:@"%d 件の新着動画があります",numNewEntry];
            }
            else {
                alertView.title = @"新着動画はありません";
            }
            alertView.message = nil;
            alertView.delegate = self;
            [alertView addButtonWithTitle:@"OK"];
            [alertView show];
            
            // Google Analytics
            NSString *trackPageTitle = [NSString stringWithFormat:@"/alertView/%@:%d", keywordPlainString0, numNewEntry];
            NSError *error;
            if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
                // エラーハンドリング
            }
        }];
    }];
    
    // 別スレッドを立てる
    _queue = [[NSOperationQueue alloc] init];
    [_queue addOperation:operation];
        
}

#pragma mark - Table view data source

// リストテーブルのアイテム数を返すメソッド
// 「UITableViewDataSource」プロトコルの必須メソッド
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArray.count;
}

// リストテーブルに表示するセルを返すメソッド
// 「UITableViewDataSource」プロトコルの必須メソッド
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    // 範囲チェックを行う
    if (indexPath.row < self.itemsArray.count) {
        
        // セルを作成する
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        // og:imageのビュー
        UIImageView *imageViewOgImage = (UIImageView *)[cell viewWithTag:5];
        NSURL *ogImageURL = [[self.itemsArray objectAtIndex:indexPath.row] ogImageURL];

        if (ogImageURL != nil) {
            UIImage* li = [UIImage animatedGIFNamed:@"loading3"];
            [imageViewOgImage setImageWithURL:ogImageURL
                             placeholderImage:li];
        }
        else {
            UIImage *noImage = [UIImage imageNamed:@"noImage2.png"];
            imageViewOgImage.image = noImage;
        }
        
        // 文字列を設定する
        UILabel *labelTitle = (UILabel*)[cell viewWithTag:1];
        UILabel *labelDate = (UILabel*)[cell viewWithTag:2];
        UILabel *labelDetail = (UILabel*)[cell viewWithTag:3];
        UILabel *labelHatebuNumber = (UILabel*)[cell viewWithTag:4];
        UILabel *labelNew = (UILabel*)[cell viewWithTag:6];
        
        // タイトルラベル
        labelTitle.text = [[NSString alloc] initWithString:
                       [[self.itemsArray objectAtIndex:indexPath.row] title]];
        
        // 「N日前」というラベル
        NSDate *datePub = [[self.itemsArray objectAtIndex:indexPath.row] date];
        NSTimeInterval t = [datePub timeIntervalSinceNow];
        NSInteger intervalDays = - t / (60 * 60 * 12);
        labelDate.text = [[NSString alloc] initWithFormat:@"%d 日前", intervalDays];
        
        // 「NEW」ラベル
        if ([[self.itemsArray objectAtIndex:indexPath.row] isNewEntry]) {
            labelNew.text = @"NEW";
        }
        else {
            labelNew.text = nil;
        }

        // 詳細ラベル
        // nilチェックしないとクラッシュする
        NSString *s = [[self.itemsArray objectAtIndex:indexPath.row] text];
        if (s == nil) {
            labelDetail.text = @"";
        }
        else {
            labelDetail.text = [[NSString alloc] initWithString:s];
        }
        
        // はてブ数初期化
        labelHatebuNumber.text = @"";
        
        // はてなに問い合わせるURLをつくる
        NSString *urlStringHatena = @"http://b.hatena.ne.jp/entry/jsonlite/?url=";
        NSString *urlStringTarget = 
        [NSString stringWithFormat:@"%@", [[self.itemsArray objectAtIndex:indexPath.row] url]];
        NSString *urlStringWhole = [NSString stringWithFormat:@"%@%@", urlStringHatena, urlStringTarget];
        NSURL *url = [NSURL URLWithString:urlStringWhole];
        
        // リクエストを送り、返ってきたJSONを解析してはてブ数を見つけ出す
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSInteger count = [[JSON valueForKeyPath:@"count"] integerValue];
            
            // はてブ数を表示させる
            labelHatebuNumber.text = [NSString stringWithFormat:@"%d users", count];
        } failure:nil];
        [operation start];
    }
    return cell;
}

// URLの配列を受け取り、「_listItemsArray」の内容を設定するメソッド
// 配列の各要素は「NSURL」クラスのインスタンスとする
- (void)reloadFromContentsOfURLsFromArray:(NSArray *)urlsArray fileName:(NSString *)fileName performer:(id)performer
{
    NSMutableArray *entryArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSURL *url in urlsArray) {
        @autoreleasepool {
            
            // URLから読み込む
            NSArray *itemsArray = [self itemsArrayFromContentsOfURL:url fileName:fileName performer:performer];
            
            // 配列に追加する
            [entryArray addObjectsFromArray:itemsArray];
        }
    }
    
    /*
     * ソートする
     */
    // まずNEWエントリとそれ以外のエントリを分ける
    NSMutableArray *newArray = [NSMutableArray array];
    NSMutableArray *oldArray = [NSMutableArray array];
    for (id entry in entryArray) {
        NSLog(@"%@", entry);
        if ([entry isNewEntry]) {
            [newArray addObject:entry];
        }
        else
        {
            [oldArray addObject:entry];
        }
    }
    // まずNEWエントリを、日付をキーにして、降順ソートする
    [newArray sortUsingFunction:dateDescending context:NULL];
    // 次にそれ以外のエントリを、日付をキーにして、降順ソートする
    [oldArray sortUsingFunction:dateDescending context:NULL];
    // newArrayのうしろにoldArrayを付ける
    [newArray addObjectsFromArray:oldArray];
    
    // データメンバーに設定する
    self.itemsArray = newArray;
}

// URLからファイルを読み込み、アイテムの配列を返すメソッド
- (NSArray *)itemsArrayFromContentsOfURL:(NSURL *)url fileName:(NSString *)fileName performer:(id)performer
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    _parser = [[RSSParser alloc] init];
    
    // URLから読み込む
    if ([_parser parseContentsOfURL:url progressView:_progressView fileName:fileName performer:performer]) {
        
        // 記事を読み込む
        [newArray addObjectsFromArray:[_parser entries]];
    }
    
    return newArray;
}

// 記事のURLを取得する
- (NSURL *)urlAtIndex:(NSInteger)index
{
    NSURL *url = nil;
    
    // 範囲チェック
    if (index < self.itemsArray.count) {
        
        url = [[self.itemsArray objectAtIndex:index] url];
    }
    return url;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    // データソースからURLを取得する
    NSURL *url;
    url = [self urlAtIndex:indexPath.row];
    
    // WebViewを開く
    [self performSegueWithIdentifier:@"showWebView" sender:url];
}

#pragma warning

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWebView"]) {
        WebViewController *controller = segue.destinationViewController;
        NSLog(@"sender = %@", sender);
        controller.URLForSegue = (NSURL *)sender;
        controller.hidesBottomBarWhenPushed = YES;
    }
//    else if ([segue.identifier isEqualToString:@"showSetting"]) {
//    }
}

- (IBAction)showSetting:(id)sender {
    [self performSegueWithIdentifier:@"showSetting" sender:self];
}

- (IBAction)refresh:(id)sender {
    [self requestTableData];
}

- (IBAction)showInfo:(id)sender {
    _infoAlertView = [[UIAlertView alloc] init];
    _infoAlertView.title = [NSString stringWithFormat:@"ご案内"];
    _infoAlertView.message = InfoPayed;
    _infoAlertView.delegate = self;
    [_infoAlertView addButtonWithTitle:@"アプリを見る"];
    [_infoAlertView addButtonWithTitle:@"キャンセル"];
    [_infoAlertView show];

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
    if (alertView == _progressAlertView) {
        [weakOperation cancel];
    }
    else if (alertView == _infoAlertView && buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:URLPayed]];
    }
}

- (void)reloadNavBarTitleWithString:(NSString *)title
{
    // タブバーのタイトルを変える
    self.navigationController.title = title;
    
    // ナビゲーションアイテムのタイトルを変える
    self.navigationItem.title = [NSString stringWithFormat:@"「%@」の新着動画", title];
}

-(void)increaseProgressBar
{
    float progress = _progressView.progress;
    if (progress < 0.9) {
        _progressView.progress += 0.001;
    }
    else
    {
        [_timerIncrease invalidate];
        // 90%になったら、サーバーからの返答の有無を10秒後に判断する
        [self performSelector:@selector(judgeServerAlive) withObject:nil afterDelay:20.0];
    }
}

- (void)judgeServerAlive
{
    // もしまったく応答がなければあきらめる
    if (_parser.realProgress == 0) {
        _progressView.progress = 0.0;
        [_timerDecrease invalidate];
        [_progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] init];
        alertView.title = @"ネットワークに問題があります。場所を変えるなどして再度お試しください。";
        alertView.message = nil;
        alertView.delegate = self;
        [alertView addButtonWithTitle:@"了解"];
        [alertView show];

        [weakOperation cancel];
    }
    // さもなくば残りの情報を待つ
}
@end
