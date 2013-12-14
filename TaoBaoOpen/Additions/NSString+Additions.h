//
//  NSString+Additions.h
//   
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
// 测试是否包含子字符串
- (BOOL)isContainString:(NSString *)searchKey;
// 字符串中替换子串
-(NSString *) replaceFrom:(NSString *)fromstr To:(NSString *)tostr;

//UTF8编码和解码
- (NSString *)UTF8EncodedString;
- (NSString *)UTF8DecodedString;

//MD5编码
- (NSString *) stringFromMD5;
@end
