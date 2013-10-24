//
//  IMBDViewController.m
//  Imbed
//
//  Created by Miles Matthias on 10/23/13.
//  Copyright (c) 2013 dojo4. All rights reserved.
//

#import "IMBDViewController.h"

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

@end
