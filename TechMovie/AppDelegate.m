//
//  AppDelegate.m
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GANTracker.h"
#import "Const.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"keyword0"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"猫" forKey:@"keyword0"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"keyword1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"cat" forKey:@"keyword1"];
    }
    
    // Google Analytics
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-34212098-1"
                                           dispatchPeriod:10
                                                 delegate:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"/appWillResignActive"];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"/appDidEnterBackground"];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"/appWillEnterForeground"];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 起動回数を見る
    NSInteger numAct = [[NSUserDefaults standardUserDefaults]integerForKey:@"numAct"];
    if (!numAct) {
        
        // 初期値を設定する
        numAct = 0;
        
        UIAlertView *alertView = [[UIAlertView alloc] init];
        alertView.title = [NSString stringWithFormat:@"ようこそ"];
        alertView.message = FirstAlertFree;
        alertView.delegate = self;
        [alertView addButtonWithTitle:@"OK"];
        [alertView show];
        
        
        // キーワードペア配列を保存する
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *fileName = PresetKeywordPairsDat;
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        
        NSMutableArray *keywordPairs = [NSMutableArray array];
        NSDictionary *keywordJapaneseAndEnglish;
        
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"猫" , @"English": @"cat"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"料理" , @"English": @"recipe"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"サッカー" , @"English": @"soccer"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"プロ野球" , @"English": @"baseball"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"自然" , @"English": @"nature"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"宇宙" , @"English": @"universe"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"技術" , @"English": @"technology"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"軍事" , @"English": @"military"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"鉄道" , @"English": @"railway"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"政治" , @"English": @"politics"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"ネタ" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"おもしろ" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"これはすごい" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"これはひどい" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"歌ってみた" , @"English": @"song"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"演奏してみた" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"作ってみた" , @"English": @"diy"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"踊ってみた" , @"English": @"dance"};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"実況プレイ" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"作業用BGM" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"アニメ" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"男性声優" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"女性声優" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"コスプレ" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"東方" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"MMD" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        keywordJapaneseAndEnglish = @{ @"Japanese" : @"VOCALOID" , @"English": @""};
        [keywordPairs addObject:keywordJapaneseAndEnglish];
        
        BOOL successful = [NSKeyedArchiver archiveRootObject:keywordPairs toFile:filePath];
        if (successful) {
            NSLog(@"%@", @"データの保存に成功しました。");
        }
        
        // ターゲット固有
        [[NSUserDefaults standardUserDefaults] setObject:@"猫" forKey:@"keyword0"];
        [[NSUserDefaults standardUserDefaults] setObject:@"cat" forKey:@"keyword1"];
        
        // ユーザーキーワードペア配列を準備する
        fileName = UserKeywordPairsDat;
        filePath = [directory stringByAppendingPathComponent:fileName];
        
        keywordPairs = [NSMutableArray array];
        
        successful = [NSKeyedArchiver archiveRootObject:keywordPairs toFile:filePath];
        if (successful) {
            NSLog(@"%@", @"データの保存に成功しました。");
        }
    }
    // 5回目なら・・・
    else if (numAct == 5) {
        _alert = [[UIAlertView alloc] init];
        _alert.title = [NSString stringWithFormat:@"ご案内"];
        _alert.message = InfoPayed;
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"アプリを見る"];
        [_alert addButtonWithTitle:@"キャンセル"];
        [_alert show];
    }
    
    // 起動回数を1増やす
    [[NSUserDefaults standardUserDefaults]setInteger:numAct + 1 forKey:@"numAct"];
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"/appDidBecomeActive"];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Google Analytics
    NSString *trackPageTitle = [NSString stringWithFormat:@"/appWillTerminate"];
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:trackPageTitle withError:&error]) {
        // エラーハンドリング
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alert && buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:URLPayed]];
    }
}

@end
