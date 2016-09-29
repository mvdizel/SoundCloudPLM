//
//  PlayListsViewCell.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListsViewCell.h"

@interface PlayListsViewCell ()
//@property (strong, nonatomic) NSURL *currentURL;
@end

@implementation PlayListsViewCell

-(void)setupCellWithPlaylist:(Playlist *)pl
{
    self.titleLabel.text = pl.title;
    [self.imageView setImage:nil];
    [self.spinner startAnimating];
    if (!pl.downloadedImage) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:pl.image];
            dispatch_sync(dispatch_get_main_queue(), ^{
                pl.downloadedImage = imageData;
                [self setTrackImage:imageData];
            });
        });
    } else {
        [self setTrackImage:pl.downloadedImage];
    }
}

-(void)setTrackImage:(NSData *)imageData
{
    UIImage *downloadedImage = [UIImage imageWithData:imageData];
    [self.spinner stopAnimating];
    [self.imageView setImage:downloadedImage];
    [self setNeedsLayout];
}

@end
