//
//  UIView+Additions.m
//  X-Touch 2.0
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)
-(void)setPosition:(CGPoint)aPostion
{
	self.frame = CGRectMake(aPostion.x, aPostion.y, self.frame.size.width, self.frame.size.height);
}
-(void)setSize:(CGSize)aSize
{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width, aSize.height);
}
-(UIViewController *)viewController{
    //方法一
//    id nextResponder = [self nextResponder];
//    if ([nextResponder isKindOfClass:[UIViewController class]]) {
//        return nextResponder;
//    }else{
//        return nil;
//    }
    
    //方法二
    for (UIView *next=[self superview]; next; next=next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
-(UIPopoverController *)popController{
    for (UIView *next=[self superview]; next; next=next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIPopoverController class]]) {
            return (UIPopoverController *)nextResponder;
        }
    }
    return nil;
}
@end
