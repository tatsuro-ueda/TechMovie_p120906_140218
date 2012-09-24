//
//  NSString+OgImage.m
//  TechMovie
//
//  Created by Tatsuro Ueda on 2012/09/21.
//  Copyright (c) 2012年 Tatsuro Ueda. All rights reserved.
//

#import "NSString+OgImage.h"

@implementation NSString (OgImage)

// get URL of og:image by [NSURL ogImageWithURL:url]
+ (NSString *)ogImageURLWithVimeoDescription:(NSString *)str
{
    /*
     * og:image Check for Vimeo
     */
    // prepare regular expression to find text
    NSError *error   = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern: @"\"http://b.vimeocdn.com.+.jpg\"" options:0 error:&error];
    
    // エラーならば表示する
    if (error != nil) {
        NSLog(@"%@", error);
    }
    
    // find by regular expression
    NSTextCheckingResult *match =
    [regexp firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    
    // get the first result
    NSRange resultRange = [match rangeAtIndex:0];
    if (match) {
        
        // get the og:image URL from the find result
        if (resultRange.length == str.length) {
            return nil;
        }
        else
        {
            NSRange urlRange = NSMakeRange(resultRange.location + resultRange.length, str.length - resultRange.length - resultRange.location);
            
            // og:image URL
            //        NSLog(@"og:image URL.nico: %@",[str substringWithRange:urlRange]);
            NSLog(@"range1:%d", resultRange.length - 1);
            NSLog(@"range2:%d", str.length - 1);
            return [str substringWithRange:urlRange];
        }
    }
    
    return str;
}

// get URL of og:image by [NSURL ogImageWithURL:url]
+ (NSString *)ogImageURLWithNicoDescription:(NSString *)str
{
    /*
     * og:image Check for Vimeo
     */
    // prepare regular expression to find text
    NSError *error   = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\"http://.+\\.smilevideo\\.jp/smile\\?i=[0-9]{8}+\"" options:0 error:&error];
    //    NSLog(@"regexp.nico: %@", regexp);
    //    NSLog(@"str.nico: %@", str);
    
    // エラーならば表示する
    if (error != nil) {
        NSLog(@"%@", error);
    }
    
    // find by regular expression
    NSTextCheckingResult *match =
    [regexp firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    
    // get the first result
    NSRange resultRange = [match rangeAtIndex:0];
    //    NSLog(@"match.nico=%@", [str substringWithRange:resultRange]);
    if (match) {
        
        // get the og:image URL from the find result
        if (resultRange.length == str.length) {
            return nil;
        }
        else
        {
            NSRange urlRange = NSMakeRange(resultRange.location + resultRange.length, str.length - resultRange.length - resultRange.location);
        
            // og:image URL
            //        NSLog(@"og:image URL.nico: %@",[str substringWithRange:urlRange]);
            NSLog(@"range1:%d", resultRange.length - 1);
            NSLog(@"range2:%d", str.length - 1);
            return [str substringWithRange:urlRange];
        }
    }
    
    return str;
}

@end
