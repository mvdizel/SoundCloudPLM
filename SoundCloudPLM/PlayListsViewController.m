//
//  PlayListsViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListsViewController.h"
#import "PlayListsViewCell.h"
#import "PlayListViewController.h"

@interface PlayListsViewController () <SCNetworkingDelegate>
@property (strong, nonatomic) SCNetworking *networkong;
@end

@implementation PlayListsViewController

static NSString * const reuseIdentifier = @"CellPL";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [SCNetworking sharedInstance];
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.networkong.delegate = self;
    [self setup];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 2.f - 20.f;
    CGSize size = CGSizeMake(width, width * 1.2f);
    return size;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TracksSegue"]) {
        PlayListViewController *cont = segue.destinationViewController;
        if ([sender isKindOfClass:[Playlist class]]) {
            cont.playlist = sender;
        } else {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
            cont.playlist = self.networkong.playlists[indexPath.row];
        }
    }
}

#pragma mark - Private

-(void)updateData
{
    self.networkong.delegate = self;
    [self.networkong getPlaylists];
}

-(void)setup
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self updateData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.networkong.playlists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayListsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Playlist *pl = self.networkong.playlists[indexPath.row];
    
    cell.titleLabel.text = pl.title;
    [cell updateImageWithUrl:pl.image andPlaylist:pl];
    
    return cell;
}

- (IBAction)addNewPLTapped:(UIBarButtonItem *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Creating new playlist"
                                                                   message:@"You will need to to add some tracks to save playlist"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter playlist name";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action)
    {
        NSString *name = alert.textFields[0].text;
        [self.networkong createPlaylistNamed:name];
        [self performSegueWithIdentifier:@"TracksSegue" sender:self.networkong.tempPlaylist];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - SC Networking delegate

-(void)dataUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

@end
