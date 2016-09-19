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

@end

@implementation TrackDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
