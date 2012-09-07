//
//  SettingViewController.h
//  TechMovie
//
//  Created by 達郎 植田 on 12/07/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray      *userKeywordPairs;
    NSMutableArray      *presetKeywordPairs;
    NSMutableArray      *allKeywordPairs;
    NSDictionary        *keywordJapaneseAndEnglish;
    NSArray             *oldKeywordPair;
    NSString            *userFilePath;
}
@property (strong, nonatomic) IBOutlet UITextField *tagFieldJapanese;
@property (strong, nonatomic) IBOutlet UITextField *tagFieldEnglish;
@property NSString *tagStringJapanese;
@property NSString *tagStringEnglish;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

- (IBAction)add:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)delete:(id)sender;
@end
