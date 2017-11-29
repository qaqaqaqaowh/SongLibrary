//
//  LibraryTableViewCell.m
//  Project
//
//  Created by NEXTAcademy on 11/29/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "LibraryTableViewCell.h"
@import FirebaseAuth;

@implementation LibraryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.ref = [[FIRDatabase database] reference];
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressAction:)];
    press.minimumPressDuration = 1;
    press.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:press];
    // Initialization code
}

-(void)pressAction:(UILongPressGestureRecognizer *) gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate removeVideoUID:self.video.uid VideoTitle:self.video.title];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
