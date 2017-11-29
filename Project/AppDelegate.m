//
//  AppDelegate.m
//  Project
//
//  Created by NEXTAcademy on 11/27/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "AppDelegate.h"
#import "LibraryViewController.h"
#import "SignInViewController.h"
@import Firebase;
@import FirebaseAuth;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([[FIRAuth auth] currentUser]) {
        LibraryViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LibraryViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.window setRootViewController:nav];
    } else {
        SignInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.window setRootViewController:nav];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [self.delegate resumeVideo];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.delegate resumeVideo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
