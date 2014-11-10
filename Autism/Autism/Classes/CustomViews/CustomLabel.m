//
//  CustomLabel.m
//  Autism
//
//  Created by Neuron-iPhone on 2/12/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
       
        
    }
    return self;
}


- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0,5,0,0};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}



@end
