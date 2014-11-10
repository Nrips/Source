//
//  Q+ACustomViewCell.h
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Q_ACustomViewCell : UITableViewCell

@property(strong,nonatomic)IBOutlet UIImageView *profilePicture;

@property(strong,nonatomic)IBOutlet UILabel *lblBaseView;
@property(strong,nonatomic)IBOutlet UILabel *lblBaseView1;
@property(strong,nonatomic)IBOutlet UILabel *lblBaseView2;
@property(strong,nonatomic)IBOutlet UILabel *lblHelpful;
@property(strong,nonatomic)IBOutlet UILabel *lblReplies;

@property(strong,nonatomic)IBOutlet UIButton *btnHelpful;
@property(strong,nonatomic)IBOutlet UIButton *btnReply;

-(IBAction)helpfulAction:(id)sender;
-(IBAction)replyAction:(id)sender;
@end
