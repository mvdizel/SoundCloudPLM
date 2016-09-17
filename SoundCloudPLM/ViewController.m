//
//  ViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"

@interface ViewController () <LoginViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        LoginViewController *loginCont = segue.destinationViewController;
        loginCont.delegate = self;
    }
}

#pragma mark - LoginVC Delegate

-(void)didSucceedWithResult:(AuthResult *)result {
    NSLog(@"Success");
}

-(void)didFail {
    NSLog(@"Fail");
}

@end
