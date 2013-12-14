//
//  TaobaoKeItem.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TaobaoKeItem.h"

@implementation TaobaoKeItem
@synthesize imgSmallPath,imgSmallUrl;
@synthesize imgBigPath,imgBigUrl;
@synthesize jsonObject;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc{
    [imgSmallPath release];
    imgSmallPath = nil;
    [imgSmallUrl release];
    imgSmallUrl = nil;
    [imgBigPath release];
    imgBigPath = nil;
    [imgBigUrl release];
    imgBigUrl = nil;
    [jsonObject release];
    jsonObject = nil;
    
    [super dealloc];
}
@end
