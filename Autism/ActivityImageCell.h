//
//  ActivityImageCell.h
//  Autism
//
//  Created by Neuron Solutions on 8/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"

@interface ActivityImageCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet MyImageView *imag;
- (IBAction)clickToLargeImage:(id)sender;

@end
