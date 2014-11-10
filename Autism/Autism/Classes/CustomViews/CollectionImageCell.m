//
//  CollectionImageCell.m
//  Autism
//
//  Created by Neuron-iPhone on 6/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "CollectionImageCell.h"
#import "EXPhotoViewer.h"

@implementation CollectionImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay]; // force drawRect:
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
