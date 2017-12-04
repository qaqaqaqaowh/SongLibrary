//
//  LibraryViewController.m
//  Project
//
//  Created by NEXTAcademy on 11/28/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "LibraryViewController.h"
#import "SignInViewController.h"
#import "LibraryTableViewCell.h"
#import "SearchViewController.h"
#import "ViewController.h"
#import "Overlay.h"
#import "Video.h"
#import <AFNetworking.h>
#import "DataHelper.h"
#import "VidURL+CoreDataClass.h"
@import CoreData;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface LibraryViewController () <UITableViewDelegate, UITableViewDataSource, RemoveVideoDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) Overlay *overlay;

@property (strong, nonatomic) NSMutableArray<Video *> *videos;

@end

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videos = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
    self.ref = [[FIRDatabase database] reference];
    [self.overlay setFrame:self.view.frame];
    [self.view addSubview:self.overlay];
    [self fetchDatabase];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = true;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:true];
    [self.videos sortUsingDescriptors:@[sort]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchDatabase {
    [[[[self.ref child:@"users"] child:[[[FIRAuth auth] currentUser] uid]] queryOrderedByChild:@"title"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dictionary = snapshot.value;
        NSURL *url = [[NSURL alloc] initWithString:dictionary[@"thumbnail"]];
        NSURLSession *manager = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(error.localizedDescription);
            } else {
                UIImage *image = [[UIImage alloc] initWithData:data];
                Video *newVideo = [[Video alloc] initWithTitle:dictionary[@"title"] withThumbnail:image withURL:dictionary[@"url"] withUID:snapshot.key];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.videos addObject:newVideo];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.videos.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [self.overlay removeFromSuperview];
                    NSEntityDescription *desc = [NSEntityDescription entityForName:@"VidURL" inManagedObjectContext:[[DataHelper shared] managedObjectContext]];
                    VidURL *newURL = [[VidURL alloc] initWithEntity:desc insertIntoManagedObjectContext:[[DataHelper shared] managedObjectContext]];
                    newURL.string = newVideo.url;
                    [[DataHelper shared] saveContext];
                });
            }
        }];
        [dataTask resume];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Video *selectedVideo = self.videos[indexPath.row];
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.selectedVideo = selectedVideo;
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)logoutButton:(id)sender {
    NSError *error = nil;
    [[FIRAuth auth] signOut:&error];
    SignInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
    self.navigationController.viewControllers = @[vc];
    [[[DataHelper shared] managedObjectContext] deletedObjects];
    [[DataHelper shared] saveContext];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LibraryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    CGFloat hue = 0;
    CGFloat saturation = 0;
    CGFloat brightness = 0;
    [self.tableView.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    brightness = brightness + (indexPath.row * 0.005);
    UIColor *background = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    Video *selectedVideo = self.videos[indexPath.row];
    cell.textLabel.text = selectedVideo.title;
    cell.imageView.image = selectedVideo.thumbnail;
    cell.video = selectedVideo;
    cell.delegate = self;
    cell.backgroundColor = background;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addVideo:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Video" message:@"Paste YT link here\n(Note that it must end with a \"v=\" parameter)" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"https://www.youtube.com/watch?v=xxx";
    }];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = alert.textFields[0].text;
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"VidURL" inManagedObjectContext:[[DataHelper shared] managedObjectContext]];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        NSArray<VidURL *> *fetchedObjects = [[[DataHelper shared] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if (![text isEqualToString:@""]) {
            for (int i = 0; i < fetchedObjects.count; i++) {
                if ([fetchedObjects[i].string isEqualToString:text]) {
                    return;
                }
            }
            self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
            [self.overlay setFrame:self.view.frame];
            [self.view addSubview:self.overlay];
            NSString *urlString = alert.textFields.firstObject.text;
            NSString *songID = [[urlString componentsSeparatedByString:@"v="] lastObject];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?key=AIzaSyA0pCGmMFkCSswwgh1rHpM2KorjSVvLKYM&part=snippet&id=%@", songID]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (error) {
                    NSLog(error.localizedDescription);
                } else {
                    NSString *thumbURL = responseObject[@"items"][0][@"snippet"][@"thumbnails"][@"maxres"][@"url"];
                    NSString *title = responseObject[@"items"][0][@"snippet"][@"title"];
                    NSString *url = alert.textFields.firstObject.text;
                    if (!thumbURL) {
                        thumbURL = responseObject[@"items"][0][@"snippet"][@"thumbnails"][@"default"][@"url"];
                    }
                    FIRDatabaseReference *key = [[[self.ref child:@"users"] child:[[[FIRAuth auth] currentUser] uid]] childByAutoId];
                    [key setValue:@{@"thumbnail":thumbURL, @"title":title, @"url":url}];
                }
            }];
            [dataTask resume];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:save];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)removeVideoUID:(NSString *)uid VideoTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Video" message:[NSString stringWithFormat:@"Delete %@ ?", title] preferredStyle:alert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
        [self.overlay setFrame:self.view.frame];
        [self.view addSubview:self.overlay];
        for (int i = 0; i < self.videos.count; i++) {
            if ([self.videos[i].uid isEqualToString:uid]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[[self.ref child:@"users"] child:[[[FIRAuth auth] currentUser] uid]] child:uid] setValue:nil];	
                    [self.videos removeObjectAtIndex:i];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [self.overlay removeFromSuperview];
                });
                 break;
            }
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)searchButton:(id)sender {
    SearchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

@end
