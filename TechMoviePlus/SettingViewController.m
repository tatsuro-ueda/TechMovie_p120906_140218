//
//  SettingViewController.m
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "FeedsTableViewController.h"
#import "GANTracker.h"
#import "Const.h"

@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize tagFieldJapanese;
@synthesize tagFieldEnglish;
@synthesize tagStringJapanese;
@synthesize tagStringEnglish;
@synthesize pickerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Custom initialization
    // 保存されているキーワードペア配列をロードする
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    userFilePath = [directory stringByAppendingPathComponent:UserKeywordPairsDat];
    userKeywordPairs = [NSKeyedUnarchiver unarchiveObjectWithFile:userFilePath];
    NSString *presetFilePath = [directory stringByAppendingPathComponent:PresetKeywordPairsDat];
    presetKeywordPairs = [NSKeyedUnarchiver unarchiveObjectWithFile:presetFilePath];
    allKeywordPairs = [NSMutableArray array];
    [allKeywordPairs addObjectsFromArray:presetKeywordPairs];
    [allKeywordPairs addObjectsFromArray:userKeywordPairs];
    
    // 現在記録されているキーワードペアを取り出す
    NSString *keyword0 = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyword0"];
    NSString *keyword1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyword1"];

    // 普段は設定画面に入った時に選んでいるキーワードを記録する（起動初回は記録せず、「決定」を押すと必ず読み込む）
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numAct"] != 1) {
        oldKeywordPair = [NSArray array];
        oldKeywordPair = @[keyword0, keyword1];
    }

    // 同じペアがあれば、ピッカーはそのペアを指す
    for (NSInteger i = 0; i < allKeywordPairs.count; i++) {
        if ([keyword0 isEqualToString:[[allKeywordPairs objectAtIndex:i] objectForKey:@"Japanese"]] && [keyword1 isEqualToString:[[allKeywordPairs objectAtIndex:i] objectForKey:@"English"]]) {
            [pickerView selectRow:i inComponent:0 animated:YES];
            return;
        }
    }
}

- (void)viewDidUnload
{
    [self setTagFieldJapanese:nil];
    [self setTagFieldEnglish:nil];
    [self setPickerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)add:(id)sender {
    
    // キーワードをキーワードペア配列に追加する
    keywordJapaneseAndEnglish = @{ @"Japanese" : tagFieldJapanese.text , @"English": tagFieldEnglish.text};
    [userKeywordPairs addObject:keywordJapaneseAndEnglish];
    [self initAllKeywordsPairs];

    // キーワードを保存する
    BOOL successful = [NSKeyedArchiver archiveRootObject:userKeywordPairs toFile:userFilePath];
    if (successful) {
        NSLog(@"%@", @"データの保存に成功しました。");
    }

    [self.tagFieldJapanese resignFirstResponder];
    [self.tagFieldEnglish resignFirstResponder];

    [pickerView reloadAllComponents];
    [pickerView selectRow:(allKeywordPairs.count - 1) inComponent:0 animated:YES];
}

- (IBAction)ok:(id)sender {

    // pickerの文字列をNSUserDefaultsに格納する
    NSString *keywordJapanese = [[allKeywordPairs objectAtIndex:[pickerView selectedRowInComponent:0]]objectForKey:@"Japanese"];
    NSString *keywordEnglish = [[allKeywordPairs objectAtIndex:[pickerView selectedRowInComponent:0]]objectForKey:@"English"];
    NSArray *newKeywordPair = [NSArray array];
    newKeywordPair = @[keywordJapanese, keywordEnglish];
    [[NSUserDefaults standardUserDefaults] setObject:keywordJapanese forKey:@"keyword0"];
    [[NSUserDefaults standardUserDefaults] setObject:keywordEnglish forKey:@"keyword1"];

    // 設定画面に来た時のキーワードペアと比較する
    if (![oldKeywordPair isEqualToArray:newKeywordPair]) {

        // 異なっていたら・・・
        // 通知を作成する
        NSString *requestTableData = [NSString stringWithFormat:@"requestTableData"];
        NSNotification *n = [NSNotification notificationWithName:requestTableData object:self];
        
        // 通知実行！
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)delete:(id)sender {
    
    // プリセットキーワードペアの場合は「あらかじめ設定されたキーワードを削除することはできません」と表示する。
    if ([pickerView selectedRowInComponent:0] < presetKeywordPairs.count) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = [NSString stringWithFormat:@"お知らせ"];
        alert.message = @"あらかじめ登録されたキーワードを削除することはできません";
        alert.delegate = self;
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
    
    // 選択中のペアを配列から除去する
    // 例えばユーザーキーワードの3番目を消すには、
    // 現在の列番号(プリセットキーワード数 - 1 + 3) - プリセットキーワードペア数
    // ということで、index:2（3番目）を消すことができる
    [userKeywordPairs removeObjectAtIndex:([pickerView selectedRowInComponent:0] - presetKeywordPairs.count)];
    [self initAllKeywordsPairs];
    [pickerView reloadAllComponents];
    
    // キーワードを保存する
    BOOL successful = [NSKeyedArchiver archiveRootObject:userKeywordPairs toFile:userFilePath];
    if (successful) {
        NSLog(@"%@", @"データの保存に成功しました。");
    }

    // 「キーワードを削除しました」
    if ([pickerView selectedRowInComponent:0] < presetKeywordPairs.count) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = [NSString stringWithFormat:@"お知らせ"];
        alert.message = @"キーワードを削除しました";
        alert.delegate = self;
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    [self initAllKeywordsPairs];
    return allKeywordPairs.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    [self initAllKeywordsPairs];

    NSString *keywordEnglish = [[allKeywordPairs objectAtIndex:row] objectForKey:@"English"];
    if ([keywordEnglish isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%@",[[allKeywordPairs objectAtIndex:row] objectForKey:@"Japanese"]];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ / %@",[[allKeywordPairs objectAtIndex:row] objectForKey:@"Japanese"],[[allKeywordPairs objectAtIndex:row] objectForKey:@"English"]];
    }
}

- (void)initAllKeywordsPairs
{
    allKeywordPairs = [NSMutableArray array];
    [allKeywordPairs addObjectsFromArray:presetKeywordPairs];
    [allKeywordPairs addObjectsFromArray:userKeywordPairs];
}
@end
