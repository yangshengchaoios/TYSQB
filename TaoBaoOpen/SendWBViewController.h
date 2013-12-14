//
//  SendWBViewController.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendWBViewController : UIViewController<UITextViewDelegate>

- (IBAction)sendWeiBo:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)logoutWB:(id)sender;
@property (retain, nonatomic) IBOutlet UITextView *tv_sendtext;
@property (retain, nonatomic) IBOutlet UILabel *lbl_remain;
@end
