//
//  MemebersListAutoCompleteCell.m
//  Autism
//
//  Created by Dipak on 7/14/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MemebersListAutoCompleteCell.h"
#import "MyImageView.h"

@interface MemebersListAutoCompleteCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet MyImageView *memberImageView;

@end

@implementation MemebersListAutoCompleteCell

/* override the setter to assign the subtitle label */
- (void)setAutoCompleteItem:(MJAutoCompleteItem *)autoCompleteItem
{
    // I bet you didn't know this was possible :p
    super.autoCompleteItem = autoCompleteItem;
    self.textLabel.hidden = YES;
    [self.memberImageView configureImageForUrl:autoCompleteItem.member.avatar];
    self.nameLabel.text = autoCompleteItem.member.name;
}

@end
