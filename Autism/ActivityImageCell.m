//
//  ActivityImageCell.m
//  Autism
//
//  Created by Neuron Solutions on 8/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ActivityImageCell.h"
#import "EXPhotoViewer.h"

@implementation ActivityImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)clickToLargeImage:(id)sender {
    
    [EXPhotoViewer showImageFrom:self.imag];
}

@end
