//
//  MessageDetailCell.m
//  Autism
//
//  Created by Neuron-iPhone on 6/9/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MessageDetailCell.h"
#import "CollectionImageCell.h"
#import "Utility.h"

@implementation MessageDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.lblDetail.textAlignment =  NSTextAlignmentJustified;

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(InboxDetailMessage *)detail detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;
{
    
    [self.imagUser configureImageForUrl:detail.memberImageUrl];
    
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblDetail.frame;
    frame.size.height = labelHeight;
    self.lblDetail.frame = frame;

    CGRect collectionViewFrame;
    collectionViewFrame = self.collectionView.frame;
    collectionViewFrame.origin.y = self.lblDetail.frame.origin.y + labelHeight + CELL_CONTENT_MARGIN;
    
    DLog(@" text %@ collection images %@", detail.message,detail.imagesArray);
    
    if (detail.imagesArray.count > 0) {
        self.collectionView.hidden = NO;
        collectionViewFrame.size.height = INBOX_ATTACH_IMAGE_VIEW_HEIGHT;
        self.collectionView.frame = collectionViewFrame;
        arrayImages = detail.imagesArray;
        DLog(@"arry images count %d",arrayImages.count);
        DLog(@"Image  : %@",arrayImages);
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
        
    } else {

        collectionViewFrame.size.height = 0;
        self.collectionView.frame = collectionViewFrame;
        self.collectionView.hidden = YES;
    }
   
    

    CGRect attachFrame = self.txtViewAttachLink.frame;
    CGRect attachImageFrame = self.imageAttachLink.frame;
    
     DLog(@" %@",detail.attachLinkUrl);
     DLog(@" %@",detail.attachLinkImageUrl);
    
    if ([Utility getValidString:detail.attachLinkUrl].length > 0)
    {
        self.lblWebsite.hidden = NO;
        self.txtViewAttachLink.hidden = NO;
        CGRect frameWebsite = self.lblWebsite.frame;
        frameWebsite.origin.y = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + CELL_CONTENT_MARGIN;
        self.lblWebsite.frame = frameWebsite;
        
        attachFrame.origin.y = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + CELL_CONTENT_MARGIN - 6;
        attachFrame.size.height = INBOX_ATTACH_LINK_LABEL_HEIGHT;
        self.txtViewAttachLink.frame = attachFrame;
        
  if ([Utility getValidString:detail.attachLinkImageUrl].length > 0) {
      
      self.imageAttachLink.hidden = NO;
      self.btnAttachImage.hidden = NO;
      CGRect attachImageFrame = self.imageAttachLink.frame;
      attachImageFrame.origin.y = self.txtViewAttachLink.frame.origin.y + INBOX_ATTACH_LINK_LABEL_HEIGHT +CELL_CONTENT_MARGIN;
    
        attachImageFrame.size.height = INBOX_ATTACH_IMAGE_VIEW_HEIGHT;
        self.imageAttachLink.frame = attachImageFrame;
        
        CGRect attachImageButtonFrame = self.btnAttachImage.frame;
        attachImageButtonFrame.origin.y = self.txtViewAttachLink.frame.origin.y + INBOX_ATTACH_LINK_LABEL_HEIGHT +CELL_CONTENT_MARGIN ;
        attachImageButtonFrame.size.height = INBOX_ATTACH_IMAGE_VIEW_HEIGHT;
        self.btnAttachImage.frame = attachImageButtonFrame;
       }
        
  else{
          attachImageFrame.size.height = 0;
          self.imageAttachLink.hidden = YES;
          self.btnAttachImage.hidden = YES;
       }
   }
    else{
        
        attachFrame.size.height = 0;
        self.txtViewAttachLink.frame = attachFrame;
        self.txtViewAttachLink.hidden = YES;
        self.imageAttachLink.hidden = YES;
        self.lblWebsite.hidden = YES;
        self.btnAttachImage.hidden = YES;
     }
    
    
    [self.imageAttachLink configureImageForUrl:detail.attachLinkImageUrl];
    [self.txtViewAttachLink setText:detail.attachLinkUrl];
    [self.lblDetail setText:detail.message];
    [self.lblName setText:detail.name];
     self.messageId = detail.messageId;
    self.activityAttachLinkSting = detail.attachLinkUrl;
}

// Action method for click on attachimage by link

-(IBAction)attachImageAction:(id)sender
{   if ([Utility getValidString:self.activityAttachLinkSting].length > 0){
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.activityAttachLinkSting]];
   }
}



#pragma mark - collectionview delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrayImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionImageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionImageCell" forIndexPath:indexPath];
        cell.imag.image = [UIImage imageNamed:@"picture"];
    
            NSString *imageString = [NSString stringWithFormat:@"%@",[arrayImages objectAtIndex:indexPath.row]];
            [cell.imag configureImageForUrl:imageString];


    return cell;
}

@end
