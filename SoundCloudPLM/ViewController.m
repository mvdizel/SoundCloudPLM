//
//  ViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "PlayListsViewController.h"

@interface ViewController () <LoginViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [[SCNetworking alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        LoginViewController *loginCont = segue.destinationViewController;
        loginCont.delegate = self;
        loginCont.networkong = self.networkong;
    }
    if ([segue.identifier isEqualToString:@"PlayListsSegue"]) {
        UINavigationController *navC = segue.destinationViewController;
        PlayListsViewController *plCont = (PlayListsViewController *)[navC topViewController];
        plCont.networkong = self.networkong;
    }
}

#pragma mark - LoginVC Delegate

-(void)didSucceedWithResult:(AuthResult *)result {
    NSLog(@"Success");
    [self performSegueWithIdentifier:@"PlayListsSegue" sender:self];
}

-(void)didFail {
    NSLog(@"Fail");
}

@end
