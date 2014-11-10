//
//  CustomTextField.m
//  Autism
//
//  Created by Vikrant Jain on 1/31/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.backgroundColor =[UIColor whiteColor];
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self setBackground:[UIImage imageNamed:@"blank-input.png"]];
        self.font = [UIFont systemFontOfSize:15];
        
        
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
