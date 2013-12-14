//
//  WeiboAuthViewController.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeiboAuthViewController : UIViewController<UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorProcessing;

- (IBAction)cancelOauth:(id)sender;
@end
