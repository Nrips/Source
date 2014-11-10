//
//  FamilyListCell.m
//  Autism
//
//  Created by Neuron-iPhone on 6/2/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "FamilyListCell.h"
#import "AddMemberViewController.h"
#import "Utility.h"

@interface FamilyListCell ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblnameTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblNameOther;
@property (weak, nonatomic) IBOutlet UILabel *lblAgeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAgeOther;
@property (weak, nonatomic) IBOutlet UILabel *lblGenderTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblGenderOther;


@property (weak, nonatomic) IBOutlet UIButton *repotToAWMButton;
- (IBAction)reportToAWMbuttonPressed:(id)sender;

@end

@implementation FamilyListCell

- (void)awakeFromNib
{
    // Initialization code
    self.btnEdit.layer.cornerRadius = 4.0f;
    self.btnEdit.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FamilyListCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    FamilyListCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[FamilyListCell class]]) {
            customCell = (FamilyListCell*)nibItem;
            break;
        }
    }
    return customCell;
}

-(void)configureCell:(MemberInFamily *)member
{
    //[self.imag configureImageForUrl:member.image];
    [self.lblName setText:member.name];
    [self.lblDetail setText:member.detail];
    
    kidIdString = member.kidId;
    ageString = member.age;
    genderString = member.gender;
    monthString = member.month;
    yearString = member.year ;
    bdayString = member.bdaydate;
    diagnoseIdString = [member.diagnosisArray valueForKey:@"diagnosis_id"];
    diagnoseTextrString = [member.diagnosisArray valueForKey:@"diagnosis_name"];
    relationIdString = [member.relationArray valueForKey:@"relation_id"];
    relationTextString = [member.relationArray valueForKey:@"relation_name"];
    self.isAlreadyReported = member.isAlreadyReported;
    self.isMemberSelf = member.isSelf;
    
    
    behaviourArray = [NSArray arrayWithArray:[member.behaviourArray valueForKeyPath:@"behav_name"]];
    beahvIdArray = [NSArray arrayWithArray:[member.behaviourArray valueForKeyPath:@"behav_id"]];
    
    treatmentArray = [NSArray arrayWithArray:[member.treatmentArray valueForKeyPath:@"treatment_name"]];
    treatIdArray = [NSArray arrayWithArray:[member.treatmentArray valueForKeyPath:@"treatment_id"]];
    
    if ([self.profileType isEqualToString:kProfileTypeOther])
    {
        self.btnDeleteMember.hidden = YES;
        self.btnEdit.hidden = YES;
        self.repotToAWMButton.hidden = NO;
        
        self.lblnameTitle.hidden = NO;
        self.lblNameOther.hidden = NO;
        self.lblAgeTitle.hidden = NO;
        self.lblAgeOther.hidden = NO;
        self.lblGenderTitle.hidden = NO;
        self.lblGenderOther.hidden = NO;
        
        self.lblName.hidden = YES;
        self.lblDetail.hidden = YES;
        
        self.lblNameOther.text = member.name;
        self.lblAgeOther.text = member.age;
        self.lblGenderOther.text = member.gender;
    }
    
    [self.imag configureImageForUrl:member.image];

}

- (IBAction)editFamilyAction:(id)sender {
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    AddMemberViewController *editMember = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AddMemberViewController"];
    NSInteger idValue = 1001;
    editMember.editFamilyId = idValue;
    editMember.kidIdPass = kidIdString;
    editMember.namePass = self.lblName.text;
    editMember.genderPassValue = genderString;
    editMember.imagMember = self.imag.image;
    editMember.relationIdPass = relationIdString;
    editMember.relationTextPass = relationTextString;
    editMember.diagnoseIdPass = diagnoseIdString;
    editMember.diagnoseTextPass = diagnoseTextrString;
    editMember.monthPass = monthString;
    editMember.yearPass = yearString;
    editMember.bdayPass = bdayString;
    editMember.beahvIdArray = beahvIdArray;
    editMember.behavArray = behaviourArray;
    editMember.treatIdArray = treatIdArray;
    editMember.treatArray = treatmentArray;
    editMember.callerView = kCallerEditFamily;
   
    [[appDelegate rootNavigationController] pushViewController:editMember animated:YES];
}

- (IBAction)deleteMember:(id)sender {
    
    DLog(@"%s",__FUNCTION__);
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"My Family"
                                                      message:@"Are you sure want to delete family member.?"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"No", @"Yes", nil];
    myAlert.tag = kTagDeleteActivityAlert;
    [myAlert show];
    
    
}

- (IBAction)reportToAWMbuttonPressed:(id)sender
{
    if (self.isAlreadyReported) {
        [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
        return;
    }
    if ([Utility getValidString:kidIdString].length < 1) {
        DLog(@"We can not report to AWM member id does not exist");
        return;
    }
    if ([self.delegate respondsToSelector:@selector(reportToAWMMemeberId:)]) {
        [self.delegate reportToAWMMemeberId:[Utility getValidString:kidIdString]];
    }
}

#pragma mark - Delete member service method
- (void)deleteKid
{
    NSDictionary *deleteParams = @{ @"kid_id" : ObjectOrNull(kidIdString),
                                    @"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]};
    
    NSString *deleteURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_DeleteFamilyMember];
    
    DLog(@"%s Performing DeleteFamilyMember %@ api \n with parameter:%@",__FUNCTION__,deleteURL,deleteParams);
    
    [serviceManager executeServiceWithURL:deleteURL andParameters:deleteParams forTask:kTaskDeleteFamilyMember completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s DeleteFamilyMember %@ Api \n with response :%@",__FUNCTION__,deleteURL,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate performSelector:@selector(reloadTableDataAfterDeletion)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utility showAlertMessage:@"Family member deleted successfully" withTitle:@"My Family"];
                        [self.delegate reloadTableDataAfterDeletion];
                    });
                }
                
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {

                    [appDelegate userAutismSessionExpire];
                }
            
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagDeleteActivityAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
    }
    else if (buttonIndex == 1)
    {
        [self deleteKid];
    }
}

@end
