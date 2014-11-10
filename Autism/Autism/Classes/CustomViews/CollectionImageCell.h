//
//  CollectionImageCell.h
//  Autism
//
//  Created by Neuron-iPhone on 6/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"

@interface CollectionImageCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet MyImageView *imag;
- (IBAction)clickToLargeImage:(id)sender;


@end
