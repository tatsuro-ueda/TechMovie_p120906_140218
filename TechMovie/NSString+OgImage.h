//
//  NSString+OgImage.h
//  TechMovie
//
//  Created by Tatsuro Ueda on 2012/09/21.
//  Copyright (c) 2012年 Tatsuro Ueda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OgImage)

+ (NSString *)ogImageURLWithVimeoDescription:(NSString *)str;
+ (NSString *)ogImageURLWithNicoDescription:(NSString *)str;

@end
