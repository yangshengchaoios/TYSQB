//
//  DetailViewController.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaobaoKeItem.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface DetailViewController : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>{
    TaobaoKeItem *taobaokeitem;
}

@property (retain, nonatomic) IBOutlet UIImageView *imgDetail;//大图
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;//商品名
@property (retain, nonatomic) IBOutlet UILabel *lblPrice;//价格
@property (retain, nonatomic) IBOutlet UILabel *lblRate;//信用
@property (retain, nonatomic) IBOutlet UILabel *lblVolume;//月销量
@property (retain, nonatomic) IBOutlet UILabel *lblNick;//商家昵称
@property (retain, nonatomic) IBOutlet UILabel *lblLocation;//所在地

- (IBAction)shareTo:(id)sender;
- (IBAction)goBack:(id)sender;
@end
