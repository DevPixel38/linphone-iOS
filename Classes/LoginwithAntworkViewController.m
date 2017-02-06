//
//  LoginwithAntworkViewController.m
//  linphone
//
//  Created by dev pixel38 on 2/1/17.
//
//

#import "LoginwithAntworkViewController.h"



@interface LoginwithAntworkViewController ()
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;

@end

@implementation LoginwithAntworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self prepareWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareWebView{
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc]
                                           init];
    [controller addScriptMessageHandler:self name:@"callbackHandler"];
    theConfiguration.userContentController = controller;
    WKUserScript *script = [[WKUserScript alloc] initWithSource:@"callNativeApp" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];
    [theConfiguration.userContentController addUserScript:script];
    
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.webViewContainer.bounds configuration:theConfiguration];
    
    NSURL *nsurl=[NSURL URLWithString:@"https://members.antwork.com/#/account/externalsignin?appId=NAAPP&appDomain=http://localhost/&devicePlatform=IOS&deviceToken=NAAPPbccb1599a022b97fcc95b932155e1d6f_iOS&openLocation=http://localhost/"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:nsrequest];
    NSLayoutConstraint *leftXConstraint = [NSLayoutConstraint
                                           constraintWithItem:webView attribute:NSLayoutAttributeLeft
                                           relatedBy:NSLayoutRelationEqual toItem:self.webViewContainer attribute:
                                           NSLayoutAttributeLeft multiplier:1.0 constant:0];
    /* Top space to superview Y*/
    NSLayoutConstraint *leftYConstraint = [NSLayoutConstraint
                                           constraintWithItem:webView attribute:NSLayoutAttributeTop
                                           relatedBy:NSLayoutRelationEqual toItem:self.webViewContainer attribute:
                                           NSLayoutAttributeTop multiplier:1.0f constant:0];
    
    NSLayoutConstraint *RightXConstraint = [NSLayoutConstraint
                                            constraintWithItem:webView attribute:NSLayoutAttributeBottom
                                            relatedBy:NSLayoutRelationEqual toItem:self.webViewContainer attribute:
                                            NSLayoutAttributeBottom multiplier:1.0 constant:0];
    /* Top space to superview Y*/
    NSLayoutConstraint *RightYConstraint = [NSLayoutConstraint
                                            constraintWithItem:webView attribute:NSLayoutAttributeRight
                                            relatedBy:NSLayoutRelationEqual toItem:self.webViewContainer attribute:
                                            NSLayoutAttributeRight multiplier:1.0f constant:0];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.webViewContainer addSubview:webView];
    [self.webViewContainer addConstraints:@[leftXConstraint, leftYConstraint, RightXConstraint, RightYConstraint]];
    
}


- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Log out the message received
    NSLog(@"Received event %@", message.body);
    NSDictionary *result = message.body;
    NSDictionary *authResponse = [result valueForKey:@"authResponse"];
    
    NSLog(@"%@", [result valueForKey:@"authResponse"]);
    [self checkAccessStatus:[authResponse valueForKey:@"userID"] AntworkUserToken:[authResponse valueForKey:@"accessToken"]];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (NSDictionary *) decodeJSON:(NSString *)JsonString{
    NSError *jsonError;
    NSData *objectData = [JsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return json;
}

- (void) checkAccessStatus:(NSString *)AntworkUserId AntworkUserToken:(NSString *)AntowkrUserToken{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"https://members.antwork.com/server/api/apiservice/GetUserDetails"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setValue: @"NAAPP" forHTTPHeaderField:@"EXTERNALAPPID"];
    [request setValue:@"k659Tf4R8105hLw" forHTTPHeaderField:@"EXTERNALAPPSECRET"];
    
    NSString *post = [NSString stringWithFormat:@"TOKEN=%@&DEVICETOKEN=%@",AntowkrUserToken,@"NAAPPbccb1599a022b97fcc95b932155e1d6f_iOS"];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu",
                       (unsigned long)[post length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response{
    NSLog(@"%@", response);
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   NSDictionary *result = [self decodeJSON: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    if ([result.allKeys containsObject:@"Data"]){
        NSDictionary *dataDictionary = [result valueForKey:@"Data"];
        BOOL isAllowed = [[dataDictionary valueForKey:@"CanAccess"] boolValue];
        if(isAllowed){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AntworkAllowed"];
            [[NSUserDefaults standardUserDefaults] setObject:[dataDictionary valueForKey:@"UserId"] forKey:@"AntworkId"];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Antowrk Phone" message:[NSString stringWithFormat:@"Hello %@", [dataDictionary valueForKey:@"DisplayName"]] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:true completion:nil];
            }];
            
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:true completion:nil];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AntworkAllowed"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"AntworkId"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Bad credentials, check your account settings", @"") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:true completion:nil];
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
