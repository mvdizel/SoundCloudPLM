//
//  TrackDetailsViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 19.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "TrackDetailsViewController.h"

@interface TrackDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *trackImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) SCNetworking *networkong;

@end

@implementation TrackDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [SCNetworking sharedInstance];
    [self setup];
}

-(void)setup
{
    self.titleLabel.text = self.track.title;
    self.artistLabel.text = self.track.artist;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.track.image500]];
            
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.trackImageView setImage:downloadedImage];
        });
    });
}

@end
