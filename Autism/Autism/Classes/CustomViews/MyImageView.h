//
//  MyImageView.h
//  Autism
//
//  Created by Neuron-iPhone on 2/22/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyImageView : UIImageView

-(MyImageView *)initWithFrame:(CGRect)frame andImageUrl:(NSString *)url;

-(void) configureImageForUrl:(NSString *)url;

- (void)configureImageForUrlWithLoader:(NSString *)url;

@end
