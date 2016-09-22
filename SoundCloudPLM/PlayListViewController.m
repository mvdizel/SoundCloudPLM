//
//  PlayListViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListViewController.h"
#import "PlayListViewCell.h"
#import "TrackDetailsViewController.h"
#import "SearchTracksViewController.h"

@interface PlayListViewController () <SCNetworkingDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *playlistImage;
@property (strong, nonatomic) SCNetworking *networkong;
@end

@implementation PlayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [SCNetworking sharedInstance];
    self.networkong.delegate = self;
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.networkong.delegate = self;
    [self.tableView reloadData];
}

-(void)setup
{
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.playlist.image500]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.playlistImage setImage:downloadedImage];
        });
    });
}

- (IBAction)savePlaylistTapped:(UIBarButtonItem *)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.networkong savePlaylist:self.playlist];
}

-(void)dataUpdateSuccess:(BOOL)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (success) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't save playlist"
                                                                           message:@"Try again later"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlist.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    
    Track *tr = self.playlist.tracks[indexPath.row];
    cell.titleLabel.text = tr.title;
    cell.artistLabel.text = tr.artist;
    [cell updateImageWithUrl:tr.image andTrack:tr];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.playlist delTrackAtIndex:(long)indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TracksDetailsSegue"]) {
        TrackDetailsViewController *cont = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        cont.track = self.playlist.tracks[indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"SearchSegue"]) {
        SearchTracksViewController *cont = segue.destinationViewController;
        cont.playlist = self.playlist;
    }
}

@end
