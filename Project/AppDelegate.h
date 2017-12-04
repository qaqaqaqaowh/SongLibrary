//
//  AppDelegate.h
//  Project
//
//  Created by NEXTAcademy on 11/27/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@import CoreData;

@class AppDelegate;
@protocol ResumeVideoDelegate

-(void)resumeVideo;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) id <ResumeVideoDelegate> delegate;

@end

