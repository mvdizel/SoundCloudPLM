//
//  LoginViewController.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNetworking.h"

@protocol LoginViewControllerDelegate <NSObject>
-(void)didSucceedWithResult:(AuthResult *)result;
-(void)didFail;
@end

@interface LoginViewController : UIViewController

@property (strong, nonatomic) SCNetworking *networkong;
@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end
