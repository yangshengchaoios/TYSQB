//
//  MainViewController.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SBTableAlert.h"

@interface MainViewController : UIViewController<MBProgressHUDDelegate,SBTableAlertDelegate, SBTableAlertDataSource>{
    MBProgressHUD *HUD;
}
@property (retain, nonatomic) IBOutlet UITextField *textFieldKeyword;

- (IBAction)doSearch:(id)sender;
- (IBAction)popHistorySearch:(id)sender;
@end
