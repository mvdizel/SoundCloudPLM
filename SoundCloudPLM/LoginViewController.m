//
//  LoginViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UIWebViewDelegate>
@property (strong, nonatomic) SCNetworking *networkong;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [[SCNetworking alloc] init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startAuthorization];
}

#pragma mark - Auth

-(void)startAuthorization
{
    NSURLRequest *request = [self.networkong makeAuthRequest];
    [(UIWebView *)self.view loadRequest:request];
}

#pragma mark - UIWebView Delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([self.networkong isOAuthResponse:url]) {
        [self dismissViewControllerAnimated:YES completion:^{
            AuthResult *r = [self.networkong resultFromAuthResponse:url];
            if (!r) {
                [self.delegate didFail];
            } else {
                [self.delegate didSucceedWithResult:r];
            }
        }];
    }
    return true;
}


@end
