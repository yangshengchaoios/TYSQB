//
//  TopUnSDKUtil.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopUnSDKUtil : NSObject
+(NSDictionary *)Post:(NSString *)appKey secret:(NSString *)appSecret params:(NSMutableDictionary *)params;
@end
