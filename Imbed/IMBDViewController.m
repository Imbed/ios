//
//  IMBDViewController.m
//  Imbed
//
//  Created by Miles Matthias on 10/23/13.
//  Copyright (c) 2013 dojo4. All rights reserved.
//

#import "IMBDViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

@interface IMBDViewController ()

@end

@implementation IMBDViewController  {
    WVJBResponseCallback _jsCallback;
}

@synthesize webView = _webView;
@synthesize javascriptBridge = _bridge;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize WebViewJavascriptBridge and the app's UIWebView
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [self registerHandlers];
    [self loadPage:_webView];
}

- (void)registerHandlers {
    if (_bridge) {
        
        // Testflight logging
        [_bridge registerHandler:@"testflightLog" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog([NSString stringWithFormat:@"[From JS]: %@", data]);
        }];
        
        // Use a UIAlertView to show the user a message instead of using the web's alert
        [_bridge registerHandler:@"alert" handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data) {
                NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appName message:data delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            } else {
                NSLog(@"No data passed to alert handler, so not alerting anything to the user.");
            }
        }];
        
        // Use a UIAlertView to ask the user to confirm instead of using the web's alert
        [_bridge registerHandler:@"confirm" handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data) {
                _jsCallback = responseCallback;
                NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appName message:data delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alert show];
            } else {
                NSLog(@"No data passed to confirm handler, so not alerting anything to the user.");
            }
        }];
        
        // Return the device name if the JS wants it
        [_bridge registerHandler:@"getDeviceName" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSString *deviceName = [[UIDevice currentDevice] name];
            NSLog(@"Returning getDeviceName handler call with name = %@", deviceName);
            responseCallback(deviceName);
        }];
        
        // FACEBOOK SHARE
        // ** For this to work, you need to finish Facebook SDK setup for your specific app (https://developers.facebook.com/docs/ios/getting-started/)
        [_bridge registerHandler:@"facebook_share" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"facebook_share called: %@", data);
            
            void (^fbHandler)(FBAppCall *call, NSDictionary *results, NSError *error) = ^(FBAppCall *call, NSDictionary *results, NSError *error) {
                if (!error) {
                    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:appName message:@"Facebook sharing failed. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [errorAlert show];
                    responseCallback([NSString stringWithFormat:@"facebook failed with error: ", [error description]]);
                } else {
                    responseCallback(@"share successful on facebook");
                }
            };
            
            FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:data] handler:fbHandler];
            
            if (!appCall) {
                FBOSIntegratedShareDialogHandler fbHandler = ^(FBOSIntegratedShareDialogResult result, NSError *error) {
                    responseCallback(@"share successful on facebook");
                };
                // Next try to post using Facebook's iOS6 integration
                BOOL displayedNativeDialog = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                                                      initialText:nil
                                                                                            image:nil
                                                                                              url:[NSURL URLWithString:data]
                                                                                          handler:fbHandler];
            }
        }];
        
        // TWITTER SHARE
        [_bridge registerHandler:@"twitter_share" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"twitter_share called: %@", data);
            
            // if Social Accounts (iOS6) is available, use it
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [twitter setInitialText:@"I'm sending tweets from JS code through native iOS twitter sharing, because I'm a boss."];
                [twitter addURL:[NSURL URLWithString:data]];
                twitter.completionHandler = ^(SLComposeViewControllerResult result) {
                    responseCallback(@"share successful on twitter");
                    [twitter dismissViewControllerAnimated:NO completion:nil];
                };
                [self presentViewController:twitter animated:YES completion:nil];
            } else {
                // iOS5
                TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
                [twitter setInitialText:@"I'm sending tweets from JS code through native iOS twitter sharing, because I'm a boss."];
                [twitter addURL:[NSURL URLWithString:@"http://www.dojo4.com"]];
                twitter.completionHandler = ^(SLComposeViewControllerResult result) {
                    responseCallback(@"share successful on twitter");
                    [twitter dismissViewControllerAnimated:NO completion:nil];
                };
                [self presentViewController:twitter animated:YES completion:nil];
            }
        }];
        
        // Send an email
        [_bridge registerHandler:@"sendEmail" handler:^(id data, WVJBResponseCallback responseCallback) {
            // data is a string of the email
            if (data) {
                NSLog(@"About to send an email to %@", data);
                // stuff we need
                MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init];
                NSDictionary *mainInfoDict = [[NSBundle mainBundle] infoDictionary];
                
                // set email composer's delegate to self so that we can dismiss it...
                emailComposer.mailComposeDelegate = self;
                
                // set to recipients
                NSArray *toRecipients = [NSArray arrayWithObjects:data, nil];
                [emailComposer setToRecipients:toRecipients];
                
                // set subject line
                NSString *appName = [mainInfoDict objectForKey:@"CFBundleDisplayName"];
                [emailComposer setSubject:[NSString stringWithFormat:@"Feedback on %@", appName]];
                
                // set body to template with app and device info
                NSString *appVersion = [mainInfoDict objectForKey:@"CFBundleShortVersionString"];
                NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
                NSString *body = [NSString stringWithFormat:@"\n\n\n\n\n\n\n--------\nApp Version = %@\niOS Version = %@", appVersion, iosVersion];
                [emailComposer setMessageBody:body isHTML:NO];
                
                [self presentModalViewController:emailComposer animated:YES];
            }
        }];
    }
}

# pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"didDismissWithButtonIndex with buttonIndex = %i", buttonIndex);
    if (!_jsCallback) {
        NSLog(@"No callback to call after confirm was dismissed.");
    } else {
        if (buttonIndex == 0) {
            _jsCallback(@"undefined");
        } else {
            _jsCallback(@"true");
        }
    }
}

# pragma mark - UIWebView management

- (void)loadPage:(UIWebView*)webView {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

# pragma mark - Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
