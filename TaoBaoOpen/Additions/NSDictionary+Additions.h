//
//  NSDictionary+Additions.h
//  
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
-(id)findAtPath:(NSString*)aPath;

-(BOOL)getBoolValAtPath:(NSString*)aPath;
-(NSString*)getStringValueAtPath:(NSString*)aPath;
@end
