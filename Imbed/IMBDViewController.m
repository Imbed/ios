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

@implementation IMBDViewController

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
        
    }
}

- (void)loadPage:(UIWebView*)webView {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
