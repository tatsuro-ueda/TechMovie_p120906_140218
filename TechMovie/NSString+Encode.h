//
//  NSString+Encode.h
//  GetOgImage
//
//  Created by 達郎 植田 on 12/08/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/*
 UML図の「NSString+Encodeカテゴリのアクティビティ図」を参照してください
 */

#import <Foundation/Foundation.h>

@interface NSString (Encode)

+ (NSString *)encodedStringWithContentsOfURL:(NSURL *)url;

@end
