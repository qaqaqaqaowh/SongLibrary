//
//  ViewController.h
//  Project
//
//  Created by NEXTAcademy on 11/27/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Video.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) Video *selectedVideo;
@property (assign, nonatomic) Boolean manualPause;

@end

