//
//  Video.m
//  Project
//
//  Created by NEXTAcademy on 11/28/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "Video.h"

@implementation Video

- (instancetype)initWithTitle:(NSString *) title withThumbnail:(UIImage *)thumbnail withURL:(NSString *)url withUID:(NSString *)uid {
    self = [super init];
    if (self) {
        self.title = title;
        self.thumbnail = thumbnail;
        self.url = url;
        self.uid = uid;
    }
    return self;
}

@end
