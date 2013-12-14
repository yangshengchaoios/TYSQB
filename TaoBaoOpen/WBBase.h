/*
 
    存放微博web参数
 
 */

#ifndef webViewDemo_WBBase_h
#define webViewDemo_WBBase_h

//新浪参数
//#define SINAAPPKEY @"806163856" //设置sina appkey
//#define SINAAPPSECRET @"32c5c2a9b88f8b478513967234b41d4e"

#define SINAOauthRequestBaseURL @"https://api.weibo.com/oauth2/"
#define SINAGETTOKEN @"authorize"
#define SINAGETACCESSTOKEN @"access_token"
#define SINASENDTEXT @"https://api.weibo.com/2/statuses/update.json"
//#define SinaCallBack_uri @"mohao://MYTEST.com"  //safari 回调参数
//重复发帖错误代码
#define SinaRepeatContentCode 20019

//腾讯参数
//#define TXAPPKEY @"801081693" //设置TX appkey
//#define TXAPPSECRET @"f4f50382e65ce0fec6de16b5488963fd"

#define oauthRequestBaseURL @"https://open.t.qq.com/cgi-bin/oauth2/"
#define authPrefix @"authorize"
#define TXSENDTEXT @"http://open.t.qq.com/api/t/add"
#define oauth2TokenKey @"access_token="
#define oauth2OpenidKey @"openid="
#define oauth2OpenkeyKey @"openkey="
#define oauth2ExpireInKey @"expire_in="
//#define TXRedirect_uri @"http://mohao.com"


//公共参数
#define MyPWDKey @"ILOVEYOUHY"             //密钥


#endif
