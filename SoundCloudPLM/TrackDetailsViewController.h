//
//  TrackDetailsViewController.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 19.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNetworking.h"

@interface TrackDetailsViewController : UIViewController
@property (strong, nonatomic) SCNetworking *networkong;
@property (strong, nonatomic) Track *track;
@end
