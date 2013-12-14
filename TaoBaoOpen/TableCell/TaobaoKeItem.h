//
//  TaobaoKeItem.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaobaoKeItem : NSObject
@property (nonatomic, retain) NSString * imgSmallPath;//小图片本地相对路径
@property (nonatomic, retain) NSString * imgSmallUrl;//小图网络路径
@property (nonatomic, retain) NSString * imgBigPath;//大图片本地相对路径
@property (nonatomic, retain) NSString * imgBigUrl;//大图网络路径
@property (nonatomic, retain) NSDictionary * jsonObject;//原始json对象
@end
