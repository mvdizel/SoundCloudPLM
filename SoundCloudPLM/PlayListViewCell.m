//
//  PlayListViewCell.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListViewCell.h"

@implementation PlayListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateImageWithUrl:(NSURL *)url
{
    if (!self.imageView.image) {
        [self.spinner startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.imageView setImage:downloadedImage];
                [self.spinner stopAnimating];
            });
        });
    }
}

@end
