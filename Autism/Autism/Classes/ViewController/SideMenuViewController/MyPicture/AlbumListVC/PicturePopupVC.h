//
//  PicturePopupVC.h
//  Autism
//
//  Created by Neuron-iPhone on 9/11/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PicturePopupVCDelegate<NSObject>
- (void)didReloadMyPictureAlbum;
@end

@interface PicturePopupVC : UIViewController

@property (weak, nonatomic) id<PicturePopupVCDelegate>delegate;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
- (IBAction)tapGestureEvent:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *baseView;

@property (strong, nonatomic) NSString *pictureId;
@property (strong, nonatomic) NSString *pictureCaption;
@property (strong, nonatomic) NSString *isAlbumCover;
@property (strong, nonatomic) NSString *albumId;


@end
