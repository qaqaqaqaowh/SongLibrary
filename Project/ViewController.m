//
//  ViewController.m
//  Project
//
//  Created by NEXTAcademy on 11/27/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "YTPlayerView.h"
#import <AFNetworking.h>
#import "Overlay.h"

@interface ViewController ()<YTPlayerViewDelegate, ResumeVideoDelegate>
    
    @property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
    @property (weak, nonatomic) IBOutlet UIButton *playButton;
    @property (weak, nonatomic) IBOutlet UIButton *pauseButton;
    @property (weak, nonatomic) IBOutlet UITextView *lyricsText;
    @property (strong, nonatomic) NSMutableString *lyrics;
    @property (weak, nonatomic) Overlay *overlay;
    @property (strong, nonatomic) AVAudioSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manualPause = false;
    AppDelegate *appController = [(AppDelegate *)[UIApplication sharedApplication] delegate];
    appController.delegate = self;
    self.session = [AVAudioSession sharedInstance];
    self.playerView.delegate = self;
    self.playerView.userInteractionEnabled = false;
    NSDictionary *playerVars = @{@"playsinline":@1,@"controls":@0,@"autoplay":@1,@"origin" : @"http://localhost",@"modestbranding":@1};
    NSString *videoID = [[NSString alloc] initWithString:[self.selectedVideo.url componentsSeparatedByString:@"v="][1]];
    [self.playerView loadWithVideoId:videoID playerVars:playerVars];
    self.playButton.enabled = false;
    self.pauseButton.enabled = false;
    self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
    [self.overlay setFrame:self.view.frame];
    [self.view addSubview:self.overlay];
    // Do any additional setup after loading the view, typically from a nib.
}
    
-(void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    NSError *setStateError = nil;
    switch (state) {
        case kYTPlayerStatePlaying:
        [self.session setActive:true error:&setStateError];
        self.playButton.enabled = false;
        self.pauseButton.enabled = true;
        self.manualPause = false;
        break;
        
        case kYTPlayerStatePaused:
        [self.session setActive:false error:&setStateError];
        self.playButton.enabled = true;
        self.pauseButton.enabled = false;
        break;
            
        case kYTPlayerStateEnded:
        [self.session setActive:false error:&setStateError];
        [self.navigationController popViewControllerAnimated:true];
        break;
        
        default:
        break;
    }
}

-(void)resumeVideo {
    if (!self.manualPause) {
        [self.playerView playVideo];
    }
}
    
-(void)getSongTitle {
    NSString *urlString = [self.playerView.videoUrl absoluteString];
    NSString *songID = [[urlString componentsSeparatedByString:@"v="] lastObject];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?key=AIzaSyA0pCGmMFkCSswwgh1rHpM2KorjSVvLKYM&part=snippet&id=%@", songID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(error.localizedDescription);
        } else {
            NSString *title = responseObject[@"items"][0][@"snippet"][@"title"];
            NSData *data = [title dataUsingEncoding:NSUTF8StringEncoding];
            NSURL *mmURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.musixmatch.com/ws/1.1/matcher.track.get?apikey=ec15caad1db888b03f2e758a7136eea5&format=json&callback=callback&q_track=%@", [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
            NSURLRequest *mmRequest = [NSURLRequest requestWithURL:mmURL];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSURLSessionDataTask *mmDataTask = [manager dataTaskWithRequest:mmRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (error) {
                    NSLog(error.localizedDescription);
                } else {
                    self.lyrics = @"No lyrics found.";
                    NSError *error = nil;
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONWritingPrettyPrinted error:&error];
                    NSNumber *statusCode = dictionary[@"message"][@"header"][@"status_code"];
                    if (![statusCode isEqualToNumber:[[NSNumber alloc] initWithInt:404]]) {
                        NSNumber *trackID = dictionary[@"message"][@"body"][@"track"][@"track_id"];
                        NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=%@&apikey=ec15caad1db888b03f2e758a7136eea5&callback=callback&format=json", trackID]];
                        NSURLRequest *trackRequest = [NSURLRequest requestWithURL:trackURL];
                        NSURLSessionDataTask *trackTask = [manager dataTaskWithRequest:trackRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                            if (error) {
                                NSLog(error.localizedDescription);
                            } else {
                                NSDictionary *lyricsDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONWritingPrettyPrinted error:&error];
                                NSNumber *someInt = lyricsDictionary[@"message"][@"header"][@"status_code"];
                                if (![someInt isEqualToNumber:[[NSNumber alloc] initWithInt:404]]) {
                                    self.lyrics = lyricsDictionary[@"message"][@"body"][@"lyrics"][@"lyrics_body"];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.lyricsText.text = self.lyrics;
                                    });
                                }
                            }
                        }];
                        [trackTask resume];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.playerView playVideo];
                        [self.overlay removeFromSuperview];
                        self.lyricsText.text = self.lyrics;
                    });
                }
            }];
            [mmDataTask resume];
        }
    }];
    [dataTask resume];
}
    
-(void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self getSongTitle];
}

- (IBAction)playButton:(id)sender {
    [self.playerView playVideo];
}
    
- (IBAction)pauseButton:(id)sender {
    [self.playerView pauseVideo];
    self.manualPause = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
