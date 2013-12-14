//
//  UIDevice+Additions.h
//  
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Additions)
//唯一序列号
@property (nonatomic, readonly) NSString *serialNumber;
/*
 * Available device memory in MB 
 */
@property(readonly) double availableMemory;

- (NSString *) uniqueDeviceIdentifier;
- (NSString *) uniqueGlobalDeviceIdentifier;
@end
