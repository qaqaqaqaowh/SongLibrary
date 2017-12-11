//
//  LibraryTableViewCell.h
//  Project
//
//  Created by NEXTAcademy on 11/29/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"
@import FirebaseDatabase;

@class LibraryTableViewCell;
@protocol RemoveVideoDelegate

-(void)removeVideoUID:(NSString *)uid VideoTitle:(NSString *)title;

@end

@interface LibraryTableViewCell : UITableViewCell

@property (nonatomic, assign) id <RemoveVideoDelegate> delegate;

@property (strong, nonatomic) Video *video;

@end
