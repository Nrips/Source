//
//  AttachLinkViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 3/18/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol imageFromUrlDelegate <NSObject>

-(void) didSelectedImage:(UIImage *) selectedImage;

@end

@interface AttachLinkViewController : UIViewController
- (IBAction)dismissView:(id)sender;

- (IBAction)saveEvent:(id)sender;

@property (nonatomic,weak) id<imageFromUrlDelegate>delegate;

- (IBAction)goEvent:(id)sender;
//@property (strong, nonatomic) IBOutlet UIImageView *urlImageView;



@end
