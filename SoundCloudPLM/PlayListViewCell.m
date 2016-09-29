//
//  PlayListViewCell.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListViewCell.h"

@implementation PlayListViewCell

-(void)setupCellWithTrack:(Track *)track
{
    self.titleLabel.text = track.title;
    self.artistLabel.text = track.artist;
    [self.imageView setImage:nil];
    if (!track.downloadedImage) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:track.image];
            track.downloadedImage = imageData;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self setTrackImage:imageData];
            });
        });
    } else {
        [self setTrackImage:track.downloadedImage];
    }
}

-(void)setTrackImage:(NSData *)imageData
{
    UIImage *downloadedImage = [UIImage imageWithData:imageData];
    [self.imageView setImage:downloadedImage];
    [self setNeedsLayout];
}

@end
