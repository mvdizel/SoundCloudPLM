//
//  SearchTracksViewController.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 19.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNetworking.h"

@interface SearchTracksViewController : UITableViewController
@property (strong, nonatomic) SCNetworking *networkong;
@property (weak, nonatomic) Playlist *playlist;
@end
