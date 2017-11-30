//
//  SearchViewController.m
//  Project
//
//  Created by NEXTAcademy on 11/30/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "SearchViewController.h"
#import "ViewController.h"
#import "Video.h"
#import "Overlay.h"
#import <AFNetworking.h>

@interface SearchViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) NSMutableArray<Video *> *videos;
@property (weak, nonatomic) Overlay *overlay;

@end

@implementation SearchViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videos = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Video *currentVideo = self.videos[indexPath.row];
    CGFloat hue = 0;
    CGFloat saturation = 0;
    CGFloat brightness = 0;
    [self.tableView.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    brightness = brightness + (indexPath.row * 0.05);
    cell.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    cell.imageView.image = currentVideo.thumbnail;
    cell.textLabel.text = currentVideo.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.selectedVideo = self.videos[indexPath.row];
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)searchButton:(id)sender {
    self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
    [self.overlay setFrame:self.view.frame];
    [self.view addSubview:self.overlay];
    NSString *search = [NSString stringWithFormat:@"%@", [self.searchBar.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?key=AIzaSyA0pCGmMFkCSswwgh1rHpM2KorjSVvLKYM&part=snippet&q=%@&type=video",search]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(error.localizedDescription);
            [self.overlay removeFromSuperview];
        } else {
            NSArray *queryVideo = responseObject[@"items"];
            for (int i = 0; i < queryVideo.count; i++) {
                NSURL *thumbURL = [NSURL URLWithString:queryVideo[i][@"snippet"][@"thumbnails"][@"maxres"][@"url"]];
                NSString *title = queryVideo[i][@"snippet"][@"title"];
                NSString *vidID = queryVideo[i][@"id"][@"videoId"];
                NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", vidID];
                if (!thumbURL) {
                    thumbURL = [NSURL URLWithString:queryVideo[i][@"snippet"][@"thumbnails"][@"default"][@"url"]];
                }
                NSURLSession *manager = [NSURLSession sharedSession];
                NSURLSessionDataTask *dataTask = [manager dataTaskWithURL:thumbURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error) {
                        NSLog(error.localizedDescription);
                        [self.overlay removeFromSuperview];
                    } else {
                        UIImage *image = [UIImage imageWithData:data];
                        Video *newVideo = [[Video alloc] initWithTitle:title withThumbnail:image withURL:url withUID:@"UID"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.videos addObject:newVideo];
//                            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.videos.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                            [self.tableView reloadData];
                            [self.overlay removeFromSuperview];
                        });
                    }
                }];
                [dataTask resume];
            }
        }
    }];
    [dataTask resume];
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
