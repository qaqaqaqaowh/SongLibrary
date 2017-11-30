//
//  Overlay.m
//  Project
//
//  Created by NEXTAcademy on 11/28/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "Overlay.h"

@implementation Overlay

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)awakeFromNib {
    [super awakeFromNib];
    [self.loadView startAnimating];
    self.userInteractionEnabled = YES;
    self.loadView.userInteractionEnabled = YES;
}

@end
