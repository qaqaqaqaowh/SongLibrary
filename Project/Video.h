//
//  Video.h
//  Project
//
//  Created by NEXTAcademy on 11/28/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Video : NSObject

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) UIImage *thumbnail;

@property (strong, nonatomic) NSString *uid;

- (instancetype)initWithTitle:(NSString *) title withThumbnail:(UIImage *)thumbnail withURL:(NSString *)url withUID:(NSString *)uid;

@end
