//
//  FamilyListCell.h
//  Autism
//
//  Created by Neuron-iPhone on 6/2/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberInFamily.h"
#import "MyImageView.h"
#import <QuartzCore/QuartzCore.h>

@protocol FamilyListCellDelegate <NSObject>
- (void)reportToAWMMemeberId :(NSString*)memberId;
- (void)reloadTableDataAfterDeletion;
@end

@interface FamilyListCell : UITableViewCell
{
    NSString *kidIdString;
    NSString *genderString;
    NSString *ageString;
    NSString *monthString;
    NSString *yearString;
    NSString *bdayString;
    NSString *diagnoseIdString;
    NSString *diagnoseTextrString;
    NSString *relationIdString;
    NSString *relationTextString;
    
    
    NSArray *beahvIdArray;
    NSArray *treatIdArray;
    NSArray *behaviourArray;
    NSArray *treatmentArray;
}

-(void)configureCell:(MemberInFamily *)member;
+ (FamilyListCell *)cellFromNibNamed:(NSString *)nibName;

@property (weak, nonatomic) id <FamilyListCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet MyImageView *imag;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblDetail;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteMember;

@property (nonatomic) BOOL isAlreadyReported;
@property (nonatomic) BOOL isMemberSelf;

@property(nonatomic,strong) NSString *otherMemberId;
@property(nonatomic,strong) NSString *profileType;

- (IBAction)editFamilyAction:(id)sender;
- (IBAction)deleteMember:(id)sender;


@end
