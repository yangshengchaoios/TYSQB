//
//  SendWBViewController.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SendWBViewController.h"
#import "Singleton.h"
#import "ShareWeiBo.h"
#import "DataBaseAccess.h"

@interface SendWBViewController ()

@end

@implementation SendWBViewController
@synthesize tv_sendtext;
@synthesize lbl_remain;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([AppSession.wbType isEqualToString:@"sina"]) {
        NSString *shortUrl=[DataBaseAccess getSinaWeiboShortUrl:AppSession.wbLongUrl withKey:[AppSession.dicConfigTxt objectForKey:@"sinaKey"]];//获得sina短网址
        if (shortUrl.length<2) {
            [AppSession removeSinaRestore];
        }
        MyNSLog(@"长链接：%@", AppSession.wbLongUrl);
        MyNSLog(@"短链接：%@", shortUrl);
        tv_sendtext.text=[NSString stringWithFormat:@"我喜欢商品【%@】",shortUrl];
    }else {
        tv_sendtext.text=AppSession.wbText;
    }
    lbl_remain.text=[NSString stringWithFormat:@"%d",140-tv_sendtext.text.length];
}

- (void)viewDidUnload
{
    [self setTv_sendtext:nil];
    [self setLbl_remain:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendWeiBo:(id)sender {
    if ([AppSession.wbType isEqualToString:@"sina"]) {
        [[ShareWeiBo mainShare] sendSinaText:tv_sendtext.text];
    }else {
        [[ShareWeiBo mainShare] sendTxText:tv_sendtext.text];
         
    }
}
- (IBAction)goBack:(id)sender{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -2)] animated:YES];
}
- (IBAction)logoutWB:(id)sender{
    [AppSession removeSinaRestore];
    [AppSession removeTxRestore];
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"退出成功！" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
    [alert release];
}
- (void)dealloc {
    [tv_sendtext release];
    [lbl_remain release];
    [super dealloc];
}

#pragma mark - textfield delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    lbl_remain.text=[NSString stringWithFormat:@"%d",140-tv_sendtext.text.length];
//    if (140-tv_sendtext.text.length<=0) {
//        return NO;
//    }
    return YES;
}
@end
