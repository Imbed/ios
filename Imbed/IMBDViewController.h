//
//  IMBDViewController.h
//  Imbed
//
//  Created by Miles Matthias on 10/23/13.
//  Copyright (c) 2013 dojo4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"

@interface IMBDViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

- (void)loadPage:(UIWebView*)webView;
- (void)registerHandlers;

@end
