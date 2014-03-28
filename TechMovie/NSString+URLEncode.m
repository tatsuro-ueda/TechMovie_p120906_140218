//
//  NSString+URLEncode.m
//  TechMovie
//
//  Created by 達郎 植田 on 12/08/10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

/*
CFStringRef CFURLCreateStringByAddingPercentEscapes (
                                                     CFAllocatorRef   allocator,
                                                     CFStringRef      originalString,
                                                     CFStringRef      charactersToLeaveUnescaped,
                                                     CFStringRef      legalURLCharactersToBeEscaped,
                                                     CFStringEncoding encoding
                                                     );
 */
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    /*
     __bridge
     単純なキャストを行うときに使用します。
     オーナーシップ権は移行しませんので、
     キャスト元の変数（self）が破棄された（スコープ外に出るなど）あとでの、
     キャスト先の変数（originalString）の使用は非常に危険です。
     */
    CFStringRef originalString = (__bridge CFStringRef)self;
    CFStringRef legalURLCharactersToBeEscaped = (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ";
    CFStringEncoding cfEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
    CFStringRef s =
    CFURLCreateStringByAddingPercentEscapes(
                                            NULL,
                                            originalString,
                                            NULL,
                                            legalURLCharactersToBeEscaped,
                                            cfEncoding
                                            );
    /*
     __bridge_transfer
     オーナーシップ権が移行されます。
     キャストと同時に、キャスト元の変数はreleaseされ、キャスト先の変数がretainされると考えればよいでしょう。
     __bridge_transferは、
     Core FoundationオブジェクトをObjective-Cオブジェクトにキャストするときによく利用されると思います。
     */
    NSString *ns = (__bridge_transfer NSString *)s;
    return ns;
}

/*
 キャストのタイプを決めるときは、
 - キャスト元、先のどちらがARC対象でどちらがARC非対象か
 - ARC対象外のオブジェクトのreleaseは誰がすべきか
 - それぞれのオブジェクトの生存範囲はどこか（ARCの場合スコープ外に出れば破棄される）
 あたりをポイントに考えると分かりやすいと思います。
 */
@end
