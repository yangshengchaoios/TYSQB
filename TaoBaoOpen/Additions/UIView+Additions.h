//
//  UIView+Additions.h
//  
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)
-(void)setPosition:(CGPoint)aPostion;
-(void)setSize:(CGSize)aSize;
-(UIViewController *)viewController;
-(UIPopoverController *)popController;
@end