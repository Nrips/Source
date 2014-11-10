//
//  MessageDetailCell.h
//  Autism
//
//  Created by Neuron-iPhone on 6/9/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "InboxDetailMessage.h"

@interface MessageDetailCell : UITableViewCell

<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *arrayImages ;
}

- (void)configureCell:(InboxDetailMessage *)detail detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblDetail;
@property (strong, nonatomic) IBOutlet MyImageView *imagUser;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *messageId;

@property (nonatomic, strong)IBOutlet MyImageView *imageAttachLink;
@property (strong, nonatomic) IBOutlet UILabel *lblWebsite;
@property (strong, nonatomic) IBOutlet UITextView *txtViewAttachLink;
@property (strong, nonatomic) IBOutlet UIButton *btnAttachImage;
@property (strong, nonatomic) NSString *activityAttachLinkSting;

@end



