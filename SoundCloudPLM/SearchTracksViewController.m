//
//  SearchTracksViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 19.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "SearchTracksViewController.h"
#import "PlayListViewCell.h"

@interface SearchTracksViewController () <UITableViewDelegate, UISearchBarDelegate, SCNetworkingDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) SCNetworking *networkong;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation SearchTracksViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [SCNetworking sharedInstance];
    self.networkong.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.frame = CGRectMake(0.0, 0.0, 10.0, 10.0);
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner bringSubviewToFront:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.networkong.delegate = self;
    if (self.networkong.searchText && self.networkong.searchText.length > 0) {
        self.searchBar.text = self.networkong.searchText;
    }
}

- (void) dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.networkong.findedTracks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    
    Track *tr = self.networkong.findedTracks[indexPath.row];
    [cell setupCellWithTrack:tr];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playlist addTrack:self.networkong.findedTracks[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearch delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchTracksWithQuery:searchBar.text];
    [self dismissKeyboard];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.networkong clearSearchResults];
    [self.tableView reloadData];
    [self dismissKeyboard];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchTracksWithQuery:searchText];
}

-(void)dataUpdateSuccess:(BOOL)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        [self.tableView reloadData];
    });
}

-(void)searchTracksWithQuery:(NSString *)query
{
    [self.spinner startAnimating];
    [self.networkong searchTracksWithQuery:query];
}

@end
