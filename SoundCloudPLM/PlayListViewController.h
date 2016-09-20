//
//  PlayListViewController.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNetworking.h"

@interface PlayListViewController : UITableViewController
@property (strong, nonatomic) Playlist *playlist;
@end
