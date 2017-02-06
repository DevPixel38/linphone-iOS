//
//  LoginwithAntworkViewController.h
//  linphone
//
//  Created by dev pixel38 on 2/1/17.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MBProgressHUD.h"

@interface LoginwithAntworkViewController : UIViewController <WKScriptMessageHandler, NSURLConnectionDelegate>
- (void) prepareWebView;
- (void) checkAccessStatus:(NSString *)AntworkUserId AntworkUserToken:(NSString *) AntowkrUserToken;
- (NSDictionary *) decodeJSON:(NSString *)JsonString;
@end
