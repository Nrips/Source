//
//  AddMemberViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/13/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "AddMemberViewController.h"
#import "MyFamilyViewController.h"
#import "CustomTextField.h"
#import "BehaviourViewController.h"
#import "CustomTextView.h"
#import "NTMonthYearPicker.h"
#import "Utility.h"
#import "GzipCompression.h"
#import "PECropViewController.h"

typedef enum
{
    kPickerChildDiagnose,
    kPickerGender,
    kPickerMonth,
    kPickerRelationship
}picker;


@interface AddMemberViewController ()
<UIImagePickerControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate, BehaviourDelegate,PECropViewControllerDelegate>

{
    
    BOOL isChekMale;
    BOOL isChekFemale;
    
    CustomTextView *tvBehaviour;
    CustomTextView *tvTreatment;
    
    UIDatePicker *dtPicker;
    UIDatePicker *yearMonthPicker;
    UIActionSheet *pickerViewPopup;
    
    picker currentPicker;
    
    NTMonthYearPicker *yearNTPicker;
    NSDate *yearMonthForDiagnose;
    NSString *newDiagnoseDateMinimum;
    NSDate *bdayPassNSDate;
    
    NSMutableArray *arrChildDiagnose;
    NSMutableArray *arrChildDiagnoseIdArray;
    NSMutableArray *arrMonth;
    NSMutableArray *arrYears;
    NSMutableArray *arrMonthshow;
    
    NSMutableArray *arrRelationName;
    NSMutableArray *arrRelationId;
    
    NSArray *arrUnique;
    NSMutableArray *arrIntervtion;

    //Declare common string for post month and year from diagnose date and Birthdate
    NSString * monthStringPost;
    NSString * monthPostInt;
    NSString * YearStringPost;
    NSString * bdayPost;
    
    id objMonth;
    
    NSString  *dateString;
    NSString  *diagnosisIdString;
    NSString  *relationIdString;
    NSMutableString  *behaviourIdString;
    NSMutableString  *InterventionsIdString;
    
    
    UIImageView *imag;
    
     CustomTextField *txtBirthdate;
     CustomTextField *txtRelation;
     CustomTextField *txtDiagnoseYear;
     CustomTextField *txtDiagnoseMonth;
     CustomTextField *txtChildDiagnose;
     CustomTextField *txtChildName;
     CustomTextField *txtBehaviour;
     CustomTextField *txtTreatment;
     CustomTextField *txtSelectGender;
    
    UIButton *btnYear;
    UIButton *btnMaleSelect;
    UIButton *btnFemaleSelect;
    UIButton *btnRelation;
    UIButton *btnTreat;
    UIButton *btnBehaviour;
    
    NSData *gzipImageData;
    
    NSString *genderPass;
    
    
    //UIScrollView *scrollView;
}
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong) NSMutableArray *arrGender;
@property (nonatomic, strong) NSMutableArray *arrGenderCaps;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIImage *selectedImage;
@property(strong,nonatomic) NSArray *behaviourArray;

@property(strong,nonatomic) NSDictionary *dictTreatment;

@property(strong,nonatomic) NSString *strIsMale;
@property(strong,nonatomic) NSString *strIsFemale;

@property(strong,nonatomic) NSMutableString *editBehaveId;
@property(strong,nonatomic) NSMutableString *editTreatmtId;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)backEvent:(id)sender;

@end

@implementation AddMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  
    [super viewDidLoad];
    [self setupFeilds];
    self.editBehaveId  = [NSMutableString new];
    self.editTreatmtId = [NSMutableString new];
    
    behaviourIdString     = [NSMutableString stringWithString:@""];
    InterventionsIdString = [NSMutableString stringWithString:@""];
    
    if (self.editFamilyId == 1001) {
       
        self.title = @"Edit Family";
        txtChildName.text = self.namePass;
        txtSelectGender.text = self.genderPassValue;
        genderPass = self.genderPassValue;
        imag.image = self.imagMember;
        self.selectedImage = self.imagMember;
        txtChildDiagnose.text = self.diagnoseTextPass;
        diagnosisIdString = self.diagnoseIdPass;
        txtRelation.text = self.relationTextPass;
        relationIdString = self.relationIdPass;
        
        NSMutableString *string = [NSMutableString string];
        for( AddMemberViewController *myObject in self.behavArray) {
            [string appendString:[NSString stringWithFormat:@"%@\n", myObject]];
        }
        tvBehaviour.text = string;
        
        NSMutableString *string1 = [NSMutableString string];
        for( AddMemberViewController *myObject in self.treatArray) {
            [string1 appendString:[NSString stringWithFormat:@"%@\n", myObject]];
        }
        tvTreatment.text = string1;
        
        //Set id for edit family data
        
        NSMutableString *behaveString = [NSMutableString string];
        if (self.beahvIdArray.count > 0) {
            for( AddMemberViewController *myObject in self.beahvIdArray) {
                [behaveString appendString:[NSString stringWithFormat:@"%@,", myObject]];
            }
            self.editBehaveId = behaveString;
            [self.editBehaveId deleteCharactersInRange:NSMakeRange([self.editBehaveId length]-1, 1)];
        }
        else
        {
            [self.editBehaveId setString:@""];
        }
        

        NSMutableString *treatmtString = [NSMutableString string];
        if (self.treatIdArray.count > 0) {
        for( AddMemberViewController *myObject in self.treatIdArray) {
            [treatmtString appendString:[NSString stringWithFormat:@"%@,", myObject]];
        }
           self.editTreatmtId = treatmtString;
            [self.editTreatmtId deleteCharactersInRange:NSMakeRange([self.editTreatmtId length]-1, 1)];
        }
        else
        {
            [self.editTreatmtId setString:@""];
        }

        
        
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        bdayPassNSDate = [dateFormat dateFromString:self.bdayPass];

        [dateFormat setDateStyle:NSDateFormatterLongStyle];
        txtBirthdate.text = [dateFormat stringFromDate:bdayPassNSDate];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:bdayPassNSDate];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        bdayPost = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)year,(long)month,(long)day];
        DLog(@"%@",bdayPost);

        
        if ([Utility getValidString:self.yearPass].length == 0 ) {
            txtDiagnoseYear.text = [NSString stringWithFormat:@""];
            DLog(@"Date %@",self.yearPass);
        }
        else
        {
            if (self.monthPass.length>1) {
                newDiagnoseDateMinimum = [NSString stringWithFormat:@"%@-%@-02",self.yearPass,self.monthPass];
                DLog(@"Date %@",newDiagnoseDateMinimum);
            }
            else
            {
                newDiagnoseDateMinimum = [NSString stringWithFormat:@"%@-0%@-02",self.yearPass,self.monthPass];
                DLog(@"Date %@",newDiagnoseDateMinimum);
            }
            NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
            [dateFormat1 setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateDiagnose = [dateFormat1 dateFromString:newDiagnoseDateMinimum];
            
            DLog(@"Date %@",newDiagnoseDateMinimum);
            DLog(@"Date %@",self.bdayPass);
            DLog(@"Date %@",dateDiagnose);
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateDiagnose];
            NSInteger month = [components month];
            monthPostInt = [NSString stringWithFormat:@"%ld",(long)month];
            DLog(@"month : %@",monthPostInt);
            
            // set english locale
            dateFormat1.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;;
            
            dateFormat1.dateFormat=@"MMMM";
            monthStringPost = [[dateFormat1 stringFromDate:dateDiagnose] capitalizedString];
            DLog(@"Date %@",monthStringPost);
            
            dateFormat1.dateFormat=@"yyyy";
            YearStringPost = [[dateFormat1 stringFromDate:dateDiagnose] capitalizedString];
            
            if ([Utility getValidString:monthStringPost].length == 0 && [Utility getValidString:YearStringPost].length == 0) {
                txtDiagnoseYear.text = @"";
            }else
            {
            txtDiagnoseYear.text = [NSString stringWithFormat:@"%@, %@",monthStringPost,YearStringPost];
            }
        }
    }
    else
    {
        self.title = @"Add Family";
    }
    
    txtBehaviour.delegate =self;
    txtBirthdate.delegate =self;
    txtChildDiagnose.delegate =self;
    txtChildName.delegate =self;
    txtDiagnoseMonth.delegate =self;
    txtDiagnoseYear.delegate =self;
    txtTreatment.delegate =self;

    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveFamilyData)];
    
    UIButton *buttonMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonMenu.frame = CGRectMake(0, 20, 60, 40);
    [buttonMenu setTitle:@"Save" forState:UIControlStateNormal];
    //[buttonMenu setImage:[UIImage imageNamed:@"left-menu-click.png"] forState:UIControlStateNormal];
    [buttonMenu addTarget:self action:@selector(saveFamilyData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonMenu];
    
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] init];
    [anotherButton setCustomView:buttonMenu];
    self.navigationItem.rightBarButtonItem = anotherButton;

    
    [self getBehaviourlist];
    [self getTreatmentlist];
    [self getChildDiagnose];
    [self getRelationshipToYouData];

    if (!IS_IPHONE_5) {
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    CGSize scrollViewContentSize = CGSizeMake(320,750);

    [self.scrollView setContentSize:scrollViewContentSize];
    
}

 -(void)saveFamilyData
  {
      if ([self.callerView isEqualToString:kCallerEditFamily]) {
          [self editFamilyData];
       }
     else{
       [self saveValuesEvent];
    }
}


- (void)saveValuesEvent
{
    DLog(@"%s",__FUNCTION__);
   
    if (![appDelegate isNetworkAvailable]) {
        [Utility showNetWorkAlert];
        return;
    }

    NSString *base64PostString = [NSString new];

    if (self.selectedImage) {
        base64PostString = [self base64forData:UIImagePNGRepresentation(self.selectedImage)];
    }
    NSMutableString *strBehav    = [NSMutableString new];
    NSMutableString *strInterven = [NSMutableString new];
    
    if ([Utility getValidString:behaviourIdString].length > 0) {
        [strBehav setString:behaviourIdString];
    }
 
    
    if ([Utility getValidString:InterventionsIdString].length > 0) {
        [strInterven setString:InterventionsIdString];
    }
    
    if (![Utility getValidString:txtChildName.text].length > 0) {
        [Utility showAlertMessage:@"" withTitle:@"Please Enter Name"];
        
    }
    else if (![Utility getValidString:diagnosisIdString].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Diagnosis"];
    }
    else if (![Utility getValidString:bdayPost].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Birthdate"];
    }
    else if (![Utility getValidString:genderPass].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Gender"];
    }
    else if (![Utility getValidString:txtRelation.text].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Relationship"];
    }
    else if (![Utility getValidString:txtDiagnoseYear.text].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Diagnosis"];
    }

    else
    {
        
        NSDictionary *addMemberParams =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                          @"kid_name" : ObjectOrNull(txtChildName.text),
                                          @"kid_diagnosis" : ObjectOrNull(diagnosisIdString),
                                          @"kid_bday" : ObjectOrNull(bdayPost),
                                          @"kid_gender": ObjectOrNull(genderPass),
                                          @"kid_relation" : ObjectOrNull(relationIdString),
                                          @"kid_diagnosis_year": ObjectOrNull(YearStringPost),
                                          @"kid_diagnosis_month": ObjectOrNull(monthPostInt),
                                          @"kids_behaviours" : ObjectOrNull(strBehav),
                                          @"kid_treatments" : ObjectOrNull(strInterven),
                                          @"member_kid_id" : ObjectOrNull(self.kidIdPass),
                                          @"kid_post_image" : ObjectOrNull(base64PostString),
                                          @"is_image_remove":[NSString stringWithFormat:@"%d",self.isImageRemove],

                                          };
        
    
        NSString *addMemberUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_AddFamilyMember];
        DLog(@"%s Performing %@",__FUNCTION__,addMemberUrl);
        
        [serviceManager executeServiceWithURL:addMemberUrl andParameters:addMemberParams forTask:kTaskAddFamilyMember completionHandler:^(id response, NSError *error, TaskType task) {
            DLog(@" %s, %@ api response :%@",__FUNCTION__,addMemberUrl,response);
            
            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    
                    [Utility showAlertMessage: @"Family added successfully" withTitle:@"Add Family"];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                        [Utility showAlertMessage:@"Required field is empty."withTitle:@"Error"];
                    } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                        [appDelegate userAutismSessionExpire];
                    }
                    else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                    {
                        [Utility showAlertMessage:@"You cannot select feilds properly. Please re-check all the feilds"withTitle:@"Error"];
                    }
                }
            } else
            {
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:@""];
            }
        }];
    }
}




- (void)editFamilyData
{
    DLog(@"%s",__FUNCTION__);
    
    if (![appDelegate isNetworkAvailable]) {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *base64PostString = [NSString new];
    
    if (self.selectedImage) {
        base64PostString = [self base64forData:UIImagePNGRepresentation(self.selectedImage)];
    }
    NSMutableString *strBehav    = [NSMutableString new];
    NSMutableString *strInterven = [NSMutableString new];
    
    if ([Utility getValidString:self.editBehaveId].length > 0) {
        [strBehav setString:self.editBehaveId];
    }
    else
    {
        [strBehav setString:behaviourIdString];
    }
    
    if ([Utility getValidString:self.editTreatmtId].length > 0) {
        [strInterven setString:self.editTreatmtId];
       }
    else
    {
        [strInterven setString:InterventionsIdString];
        
    }
    
     if (![Utility getValidString:genderPass].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Gender"];
    }
    else{
         NSString *strUppercaseString = [genderPass uppercaseString];
         genderPass = strUppercaseString;
        }


    if (![Utility getValidString:txtChildName.text].length > 0) {
        [Utility showAlertMessage:@"" withTitle:@"Please Enter Name"];
        
    }
    else if (![Utility getValidString:diagnosisIdString].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Diagnosis"];
    }
    else if (![Utility getValidString:bdayPost].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Birthdate"];
    }
    else if (![Utility getValidString:genderPass].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Gender"];
    }
    else if (![Utility getValidString:txtRelation.text].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Relationship"];
    }
    else if (![Utility getValidString:txtDiagnoseYear.text].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Please Select Diagnosis"];
    }

    else
    {
        
        NSDictionary *addMemberParams =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                          @"kid_name" : ObjectOrNull(txtChildName.text),
                                          @"kid_diagnosis" : ObjectOrNull(diagnosisIdString),
                                          @"kid_bday" : ObjectOrNull(bdayPost),
                                          @"kid_gender": ObjectOrNull(genderPass),
                                          @"kid_relation" : ObjectOrNull(relationIdString),
                                          @"kid_diagnosis_year": ObjectOrNull(YearStringPost),
                                          @"kid_diagnosis_month": ObjectOrNull(monthPostInt),
                                          @"kids_behaviours" : ObjectOrNull(strBehav),
                                          @"kid_treatments" : ObjectOrNull(strInterven),
                                          @"member_kid_id" : ObjectOrNull(self.kidIdPass),
                                          @"kid_post_image" : ObjectOrNull(base64PostString),
                                          @"is_image_remove":[NSString stringWithFormat:@"%d",self.isImageRemove],

                                          };
        
        
        NSString *addMemberUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_EditFamilyMember];
        
        DLog(@"%s %@ Performing %@",__FUNCTION__,addMemberUrl,addMemberParams);
        
        [serviceManager executeServiceWithURL:addMemberUrl andParameters:addMemberParams forTask:kTaskAddFamilyMember completionHandler:^(id response, NSError *error, TaskType task) {
            DLog(@" %s, %@ api response :%@",__FUNCTION__,addMemberUrl,response);
            
            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    
                    [Utility showAlertMessage: @"Family added successfully" withTitle:@"Add Family"];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                        [Utility showAlertMessage:@"Required field is empty."withTitle:@"Error"];
                    } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                        [appDelegate userAutismSessionExpire];
                    }
                    else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                    {
                        [Utility showAlertMessage:@"You cannot select feilds properly. Please re-check all the feilds"withTitle:@"Error"];
                    }
                }
            } else
            {
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:@""];
            }
        }];
        
    }
}






-(void) setupFeilds
{
    
    imag =[[UIImageView alloc] initWithFrame:CGRectMake(100, -20, 120, 120)];
    imag.image = [UIImage imageNamed:@"avatar-140.png"];
    imag.layer.cornerRadius = 3.0f;
    imag.clipsToBounds = YES;
    imag.userInteractionEnabled = YES;
    imag.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:imag];
    
    UIButton *btnChooseImage =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnChooseImage setFrame:CGRectMake(0, 0, 120, 120)];
    [btnChooseImage setBackgroundColor:[UIColor clearColor]];
    [btnChooseImage addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [imag addSubview:btnChooseImage];

    
    UILabel *lblChildName =[[UILabel alloc] initWithFrame:CGRectMake(20, 110,100 , 30)];
    [lblChildName setText:@"Name"];
    [self.scrollView addSubview:lblChildName];
    
    UILabel *lblChildNameStar =[[UILabel alloc] initWithFrame:CGRectMake(67,110,30,30)];
    [lblChildNameStar setText:@"*"];
    [lblChildNameStar setTextColor:[UIColor redColor]];
    [self.scrollView addSubview:lblChildNameStar];

    txtChildName =[[CustomTextField alloc] initWithFrame:CGRectMake(20,140, 270, 30)];
    [self.scrollView addSubview:txtChildName];
    
    
    
    UILabel *lblChildDiagnose =[[UILabel alloc] initWithFrame:CGRectMake(20, 170,120 , 30)];
    [lblChildDiagnose setText:@"Diagnosis"];
    [self.scrollView addSubview:lblChildDiagnose];
    
    UILabel *lblChildDiagnoseStar =[[UILabel alloc] initWithFrame:CGRectMake(97,170,30,30)];
    [lblChildDiagnoseStar setText:@"*"];
    [lblChildDiagnoseStar setTextColor:[UIColor redColor]];
    [self.scrollView addSubview:lblChildDiagnoseStar];
    
    txtChildDiagnose =[[CustomTextField alloc] initWithFrame:CGRectMake(20,200, 270, 30)];
    txtChildDiagnose.userInteractionEnabled = NO;
    [self.scrollView addSubview:txtChildDiagnose];
    
    UIButton *btnDropChild =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnDropChild setFrame:CGRectMake(260, 200, 30, 30)];
    UIImage *cdImage =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnDropChild setImage:cdImage forState:UIControlStateNormal];
    [btnDropChild addTarget:self action:@selector(showChildDiagnose) forControlEvents:UIControlEventTouchUpInside];
    btnDropChild.tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnDropChild];
    
    
    UILabel *lblBirthdate =[[UILabel alloc] initWithFrame:CGRectMake(20, 230,80 , 30)];
    [lblBirthdate setText:@"Birthdate"];
    [self.scrollView addSubview:lblBirthdate];
    
    UILabel *lblBirthdateStar =[[UILabel alloc] initWithFrame:CGRectMake(91,230,30,30)];
    [lblBirthdateStar setText:@"*"];
    [lblBirthdateStar setTextColor:[UIColor redColor]];
    [self.scrollView addSubview:lblBirthdateStar];
    
    
    txtBirthdate =[[CustomTextField alloc] initWithFrame:CGRectMake(20,260, 270, 30)];
    txtBirthdate.userInteractionEnabled = NO;
    [self.scrollView addSubview:txtBirthdate];
    
    UIButton *btnBirthdate =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnBirthdate setFrame:CGRectMake(260, 260, 30, 30)];
    UIImage *callImage =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnBirthdate setImage:callImage forState:UIControlStateNormal];
    [btnBirthdate addTarget:self action:@selector(showBirthdayPicker) forControlEvents:UIControlEventTouchUpInside];
    btnBirthdate.tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnBirthdate];

    
    UILabel *lblGender =[[UILabel alloc] initWithFrame:CGRectMake(20, 290,60,30)];
    [lblGender setText:@"Gender"];
    [self.scrollView addSubview:lblGender];
    

    
    
    UILabel *lblGenderStar =[[UILabel alloc] initWithFrame:CGRectMake(80,290,30 , 30)];
    [lblGenderStar setText:@"*"];
    [lblGenderStar setTextColor:[UIColor redColor]];
    [self.scrollView addSubview:lblGenderStar];
    
    
    txtSelectGender =[[CustomTextField alloc] init];
    [txtSelectGender setFrame:CGRectMake(20, 320, 270, 30)];
    txtSelectGender.userInteractionEnabled = NO;
    [self.scrollView addSubview: txtSelectGender];

    
    
    btnFemaleSelect =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnFemaleSelect setFrame:CGRectMake(260, 320, 30, 30)];
    UIImage *selectFemale =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnFemaleSelect setImage:selectFemale forState:UIControlStateNormal];
    [btnFemaleSelect addTarget:self action:@selector(myGender) forControlEvents:UIControlEventTouchUpInside];
    btnFemaleSelect .tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnFemaleSelect];

    // Relationship to you
    
    UILabel *lblRelation =[[UILabel alloc] initWithFrame:CGRectMake(20, 350,270, 30)];
    [lblRelation setText:@"Relationship to you"];
    [self.scrollView addSubview:lblRelation];
    
    UILabel *lblRelationStar =[[UILabel alloc] initWithFrame:CGRectMake(170,350,30,30)];
    [lblRelationStar setText:@"*"];
    [lblRelationStar setTextColor:[UIColor redColor]];
    [self.scrollView addSubview:lblRelationStar];

    
    txtRelation =[[CustomTextField alloc] initWithFrame:CGRectMake(20,380 , 270, 30)];
    txtRelation.userInteractionEnabled = NO;
    [self.scrollView addSubview:txtRelation];
    
    btnRelation =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnRelation setFrame:CGRectMake(260, 380, 30, 30)];
    UIImage *relationImage =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnRelation setImage:relationImage forState:UIControlStateNormal];
    [btnRelation addTarget:self action:@selector(showRelationshipPicker) forControlEvents:UIControlEventTouchUpInside];
    btnRelation .tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnRelation];
    
    // Date of Diagnosis
    
    UILabel *lblYear =[[UILabel alloc] initWithFrame:CGRectMake(20, 410,270, 30)];
    [lblYear setText:@"Diagnosis date"];
    [self.scrollView addSubview:lblYear];
    
    txtDiagnoseYear =[[CustomTextField alloc] initWithFrame:CGRectMake(20,440 , 270, 30)];
    txtDiagnoseYear.userInteractionEnabled = NO;
    [self.scrollView addSubview:txtDiagnoseYear];
    
    btnYear =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnYear setFrame:CGRectMake(260, 440, 30, 30)];
    UIImage *yearImage =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnYear setImage:yearImage forState:UIControlStateNormal];
    btnYear.userInteractionEnabled = NO;
    [btnYear addTarget:self action:@selector(showDiagnoseYear) forControlEvents:UIControlEventTouchUpInside];
    btnYear .tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnYear];


    // Behaviour controls
    
    UILabel *lblBehaviour =[[UILabel alloc] initWithFrame:CGRectMake(20, 470,150 , 30)];
    [lblBehaviour setText:@"Behaviour"];
    [self.scrollView addSubview:lblBehaviour];
    
    UIImageView *imagBehaviour = [[UIImageView alloc] initWithFrame:CGRectMake(20, 500, 270, 80)];
    imagBehaviour.image =[UIImage imageNamed:@"ans-bg.png"];
    [self.scrollView addSubview:imagBehaviour];
    
    
    tvBehaviour =[[CustomTextView alloc] initWithFrame:CGRectMake(22,502 , 266, 76)];
    tvBehaviour.editable = NO;
    [self.scrollView addSubview:tvBehaviour];
    
    
    btnBehaviour =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnBehaviour setFrame:CGRectMake(260, 500, 30, 30)];
    UIImage *behaviourImage =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnBehaviour setImage:behaviourImage forState:UIControlStateNormal];
    [btnBehaviour addTarget:self action:@selector(showBehaviour) forControlEvents:UIControlEventTouchUpInside];
    btnBehaviour .tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnBehaviour];

    
    // Interventions controls
    
    UILabel *lblTreatment =[[UILabel alloc] initWithFrame:CGRectMake(20, 584,150 , 30)];
    [lblTreatment setText:@"Interventions"];
    [self.scrollView addSubview:lblTreatment];
    
    
    UIImageView *imagTreatment = [[UIImageView alloc] initWithFrame:CGRectMake(20, 614, 270, 80)];
    imagTreatment.image =[UIImage imageNamed:@"ans-bg.png"];
    [self.scrollView addSubview:imagTreatment];
    
    tvTreatment =[[CustomTextView alloc] initWithFrame:CGRectMake(22,616 , 266, 76)];
    tvTreatment.editable = NO;
    [self.scrollView addSubview:tvTreatment];
    
    
    btnTreat =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnTreat setFrame:CGRectMake(260, 614, 30, 30)];
    UIImage *treatImage =[UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnTreat setImage:treatImage forState:UIControlStateNormal];
    [btnTreat addTarget:self action:@selector(showTreatment) forControlEvents:UIControlEventTouchUpInside];
    btnTreat.tintColor = appUIGreenColor;
    [self.scrollView addSubview:btnTreat];
    
    
    txtChildName.delegate =self;
    [self setupPicker];
}

-(void)setupPicker
{
    self.baseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    UIToolbar *topBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 44)];
    UIBarButtonItem *dontBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneActionAddMember:)];
    dontBtn.tintColor = appUIGreenColor;
    topBar.items = [NSArray arrayWithObject:dontBtn];
    [self.baseView addSubview:topBar];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 216)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.baseView addSubview:self.pickerView];
    
    [self.view addSubview:self.baseView];
}



#pragma mark - Datepicker events
-(void) myGender
{
    self.arrGender =[[NSMutableArray alloc] initWithObjects:@"Male",@"Female",@"Other", nil];
    self.arrGenderCaps = [[NSMutableArray alloc] initWithObjects:@"MALE",@"FEMALE",@"OTHER", nil];
    currentPicker = kPickerGender;
    [_scrollView setContentOffset:CGPointMake(0, 220) animated:YES];
    [self showPicker];
}

-(void)selectMale:(id)sender
{
    if (!isChekMale) {
        
        [btnMaleSelect setImage:[UIImage imageNamed:@"radio-check.png"] forState:UIControlStateNormal];
        isChekMale = YES;
        self.strIsMale = @"1";
        
        DLog(@"Gender Male");
        
    }
    
    else {
        [btnMaleSelect setImage:[UIImage imageNamed:@"radio-normal.png"] forState:UIControlStateNormal];
        isChekMale = NO;
        self.strIsMale = @"0";
        
         DLog(@"Gender blank");
    }
}

-(void)  selectFemale:(id)sender
{
    if (!isChekFemale) {
        [btnFemaleSelect setImage:[UIImage imageNamed:@"radio-check.png"] forState:UIControlStateNormal];
        isChekFemale = YES;
        self.strIsFemale =@"1";
    }
    
    else {
        [btnFemaleSelect setImage:[UIImage imageNamed:@"radio-normal.png"] forState:UIControlStateNormal];
        isChekFemale = NO;
        self.strIsFemale =@"0";
    }
    
}

#pragma mark - UI Methods

-(void) selectImage
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select image from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:
                            @"Camera",
                            @"Photo Gallery",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    
}



- (IBAction)backEvent:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Parse Methods

-(void) getBehaviourlist
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
        NSString *strBehaviour = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetBehaviour];
        DLog(@"%s, Performing %@ api",__FUNCTION__,strBehaviour);
        [serviceManager executeServiceWithURL:strBehaviour forTask:kTaskGetBehaviour completionHandler:^(id response, NSError *error, TaskType task) {
            DLog(@"%s, %@ api \n response %@",__FUNCTION__,strBehaviour,response);
            if (!error && response) {
                self.behaviourArray = [parsingManager parseResponse:response forTask:task];
            }
        }];
}


-(void) getTreatmentlist
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSString *strTreatment = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetTreatment];
    DLog(@"%s, Performing %@ api",__FUNCTION__,strTreatment);
    [serviceManager executeServiceWithURL:strTreatment forTask:kTaskGetTreatment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api \n response %@",__FUNCTION__,strTreatment,response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 self.dictTreatment = parsedData;
               // DLog(@"%@",self.dictTreatment);
                
            });
        }
    }];
}

- (void)getChildDiagnose
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSString *strOtherLocalAuthcity = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_ChildDiagnose];
    DLog(@"%s, Performing %@ api",__FUNCTION__,strOtherLocalAuthcity);
    [serviceManager executeServiceWithURL:strOtherLocalAuthcity forTask:kTaskGetChildDiagnose completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s Child daignose Response %@",__FUNCTION__,response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            NSArray *arrData = [parsedData objectForKey:@"data"];
            
            arrChildDiagnose = [NSMutableArray new];
            arrChildDiagnoseIdArray = [NSMutableArray new];
            arrChildDiagnose =[arrData valueForKey:@"mkd_name"];
            arrChildDiagnoseIdArray = [arrData valueForKey:@"mkd_id"];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.pickerView reloadAllComponents];
            });
        }
    }];
    
}


- (void)getRelationshipToYouData{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *relationURL = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_RelationshipToYou];
    DLog(@"%s Performing %@ api",__FUNCTION__,relationURL);
    [serviceManager executeServiceWithURL:relationURL forTask:kTaskRelationToYou completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n Response: %@",__FUNCTION__,relationURL, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            NSArray *array =[response objectForKey:@"data"];
            //DLog(@"array %@",array);
            dispatch_async(dispatch_get_main_queue(), ^{
                arrRelationId = [array valueForKey:@"mkr_id"];
                arrRelationName = [array valueForKey:@"mkr_name"];
                [self.pickerView reloadAllComponents];
            });
        }
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark  UIDatePicker implementation

- (void)showBirthdayPicker
{
   txtDiagnoseYear.text = @"";
   //txtBirthdate.text = @"";
    [self hideKeyBoard];

    pickerViewPopup = [[UIActionSheet alloc] init];
    const CGFloat toolbarHeight = 44.0f;
    dtPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolbarHeight, 0, 0)];
    
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
   
    
    dtPicker.datePickerMode = UIDatePickerModeDate;
    dtPicker.maximumDate =[NSDate date];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    dtPicker.hidden = NO;
    dtPicker.date = [NSDate date];
    
    [dtPicker addTarget:self action:@selector(txtChangeBirthday:) forControlEvents:UIControlEventValueChanged];
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight)];
    pickerToolbar.barStyle = UIBarStyleDefault;
    [pickerToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btncancelPressed:)];
     btnCancel.tintColor = appUIGreenColor;
    [barItems addObject:btnCancel];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
     doneBtn.tintColor = appUIGreenColor;
    [barItems addObject:doneBtn];
    
    
    //txtBirthdate.text=[NSString stringWithFormat:@"%@",dtPicker.date];
    
    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"MMMM-dd-yyyy"];
    [formatter1 setDateStyle:NSDateFormatterLongStyle];
    
        dateString = [formatter1 stringFromDate:dtPicker.date];
        //DLog(@"%@",dtPicker.date);
        txtBirthdate.text=dateString;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dtPicker.date];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        bdayPost = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)year,(long)month,(long)day];
       // DLog(@"%@",bdayPost);
    
    
    [pickerToolbar setItems:barItems animated:YES];
    
    [pickerViewPopup addSubview:pickerToolbar];
    [pickerViewPopup addSubview:dtPicker];
    [pickerViewPopup showInView:self.view.superview];
    [pickerViewPopup setBounds:CGRectMake(0,0,self.view.frame.size.width, 464)];
    
    btnYear.userInteractionEnabled =YES;
}



-(void)txtChangeBirthday:(id)sender{
    
    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
    //[formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter1 setDateFormat:@"MMMM-dd-yyyy"];
    [formatter1 setDateStyle:NSDateFormatterLongStyle];

    if ([dtPicker.date compare:[NSDate date]]== NSOrderedAscending) {
        dateString = [formatter1 stringFromDate:dtPicker.date];
        //DLog(@"%@",dtPicker.date);
        txtBirthdate.text=dateString;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dtPicker.date];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        bdayPost = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)year,(long)month,(long)day];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [arrYears removeObjectAtIndex:0];
}

-(void)showDiagnoseYear
{
    [self hideKeyBoard];
   
    pickerViewPopup = [[UIActionSheet alloc] init];
    const CGFloat toolbarHeight = 44.0f;
    yearNTPicker = [[NTMonthYearPicker alloc] initWithFrame:CGRectMake(0, toolbarHeight, 0, 0)];
    
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    
    
    yearNTPicker.datePickerMode = NTMonthYearPickerModeMonthAndYear;
    yearNTPicker.minimumDate = dtPicker.date;
//    if (self.editFamilyId == 1001) {
//        yearNTPicker.minimumDate = bdayPassNSDate;
//    }
//    else
//    {
//        yearNTPicker.minimumDate = dtPicker.date;
//        DLog(@"Date ntPicker %@",dtPicker.date);
//    }
    yearNTPicker.maximumDate = [NSDate date];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    yearNTPicker.hidden = NO;
    yearNTPicker.date = [NSDate date];
    
    [yearNTPicker addTarget:self action:@selector(txtChangeMonthYear:) forControlEvents:UIControlEventValueChanged];
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight)];
    pickerToolbar.barStyle = UIBarStyleDefault;
    [pickerToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btncancelPressed:)];
     btnCancel.tintColor = appUIGreenColor;
    [barItems addObject:btnCancel];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
     doneBtn.tintColor = appUIGreenColor;
    [barItems addObject:doneBtn];
    
    
    [pickerToolbar setItems:barItems animated:YES];
    
    [pickerViewPopup addSubview:pickerToolbar];
    [pickerViewPopup addSubview:yearNTPicker];
    [pickerViewPopup showInView:self.view.superview];
    [pickerViewPopup setBounds:CGRectMake(0,0,self.view.frame.size.width, 464)];

    
}

- (void)txtChangeMonthYear:(id)sender{
    
    [self hideKeyBoard];
    
    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
    //[formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter1 setDateFormat:@"MMMM-yyyy"];
    [formatter1 setDateStyle:NSDateFormatterLongStyle];
    
    dateString = [formatter1 stringFromDate:yearNTPicker.date];
    
   
    
    NSDate *date = [formatter1 dateFromString:dateString];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger month = [components month];
    monthPostInt = [NSString stringWithFormat:@"%ld",(long)month];
    DLog(@"month : %@",monthPostInt);

    
    // set english locale
    formatter1.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;;
    
    formatter1.dateFormat=@"MMMM";
    monthStringPost = [[formatter1 stringFromDate:date] capitalizedString];
    DLog(@"Month : %@",monthStringPost);
    formatter1.dateFormat=@"yyyy";
    YearStringPost = [[formatter1 stringFromDate:date] capitalizedString];
    
    txtDiagnoseYear.text =[NSString stringWithFormat:@"%@, %@",monthStringPost,YearStringPost];
    
    }

#pragma mark - Other Picker Methods
- (void)showChildDiagnose
{
    currentPicker = kPickerChildDiagnose;
    [_scrollView setContentOffset:CGPointMake(0, 220) animated:YES];
    [self showPicker];
}

- (void)showRelationshipPicker
{
    currentPicker = kPickerRelationship;
    [_scrollView setContentOffset:CGPointMake(0, 220) animated:YES];
    [self showPicker];
}

- (void)btncancelPressed:(id)sender{
    [pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)doneButtonPressed:(id)sender{
    [pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

#pragma mark- picker opening/closing methods

- (void)showPicker {
    [self hideKeyBoard];

    [UIView animateWithDuration:0.3 animations:^{
        
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height - self.baseView.frame.size.height, self.baseView.frame.size.width, self.baseView.frame.size.height)];
    }];
    [self.pickerView reloadAllComponents];
}

- (void)hidePicker {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    }];
}

- (void)pickerDoneActionAddMember:(id)sender {
    
    if (currentPicker == kPickerChildDiagnose && [txtChildDiagnose.text isEqualToString:@""]) {
        txtChildDiagnose.text = (arrChildDiagnose.count > 0) ?  [arrChildDiagnose firstObject] : @"";
        diagnosisIdString = (arrChildDiagnoseIdArray.count > 0) ?  [arrChildDiagnoseIdArray firstObject] : @"";
    }
    else if(currentPicker == kPickerGender && [txtSelectGender.text isEqualToString:@""]) {
        txtSelectGender.text = (self.arrGender.count > 0) ?  [self.arrGender firstObject] : @"";
    }
    else if (currentPicker == kPickerRelationship && [txtRelation.text isEqualToString:@""])
    {
       txtRelation.text = (arrRelationName.count > 0) ?  [arrRelationName firstObject] : @"";
        relationIdString = (arrRelationId.count > 0) ?  [arrRelationId firstObject] : @"";
    }

    [self hidePicker];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (currentPicker == kPickerChildDiagnose) {
        return 1;
    }
    else if(currentPicker == kPickerGender) {
        return 1;
    }
    else if (currentPicker == kPickerRelationship)
    {
        return 1;
    }
    return 0;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (currentPicker == kPickerChildDiagnose) {
        return [arrChildDiagnose count];
    }
    else if(currentPicker == kPickerGender) {
        
        return [self.arrGender count];
    }
    else if (currentPicker == kPickerRelationship)
    {
        return [arrRelationName count];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (currentPicker == kPickerChildDiagnose) {
        return [arrChildDiagnose objectAtIndex:row];
    }
    
    else if(currentPicker == kPickerGender){
        
        return [self.arrGender objectAtIndex:row];
    }
    else if (currentPicker == kPickerRelationship){
        return [arrRelationName objectAtIndex:row];
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (currentPicker == kPickerChildDiagnose) {
        txtChildDiagnose.text =[arrChildDiagnose objectAtIndex:row];
        diagnosisIdString = [arrChildDiagnoseIdArray objectAtIndex:row];
        
//        if ([ar) {
//            diagnosisIdString = [arrChildDiagnoseIdArray objectAtIndex:row];
//            btnBehaviour.userInteractionEnabled = NO;
//            btnTreat.userInteractionEnabled = NO;
//        }else
//        {
//        diagnosisIdString = [arrChildDiagnoseIdArray objectAtIndex:row];
//            btnBehaviour.userInteractionEnabled = YES;
//            btnTreat.userInteractionEnabled = YES;
//        }
        
    }
    else if(currentPicker == kPickerGender) {
        txtSelectGender.text =[self.arrGender objectAtIndex:row];
        genderPass = [self.arrGenderCaps objectAtIndex:row];
    }
    else if (currentPicker == kPickerRelationship){
        txtRelation.text = [arrRelationName objectAtIndex:row];
        relationIdString = [arrRelationId objectAtIndex:row];
    }
    
}

#pragma -mark ShowTableview elements

-(void) showBehaviour
{
    NSInteger idSend = 1002;
    
    BehaviourViewController *passVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BehaviourViewController"];
    passVC.passBehaveId = idSend;
    [passVC setDelegate:self];
    [passVC setSelectedTitle:txtBehaviour.text];
    passVC.behaviourArray = self.behaviourArray;
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:passVC];
    [self presentViewController:nav animated:YES completion:^{}];
    
}

#pragma mark - behaviour and intervention delegate

// OtherDelegates methods (Behaviour and Interventions)
- (void)didSelectedBehaviour:(NSMutableArray *)behaviour :(NSMutableArray *)selectionsIdBehav
{
    NSMutableString *string = [NSMutableString string];
    //behaviourIdString = [NSMutableString string];
    for( AddMemberViewController *myObject in behaviour) {
        [string appendString:[NSString stringWithFormat:@"%@\n", myObject]];
    }
    tvBehaviour.text = string;
    [self.editBehaveId setString:@""];
    if (selectionsIdBehav.count > 0) {
    for( AddMemberViewController *myObject1 in selectionsIdBehav) {
        [behaviourIdString appendString:[NSString stringWithFormat:@"%@,", myObject1]];
    }
        [behaviourIdString deleteCharactersInRange:NSMakeRange([behaviourIdString length]-1, 1)];
    }
}


- (void)didSelectedTreatment:(NSMutableArray *)treatment :(NSMutableArray *)selectionsIdInterven
{
    NSMutableString *string = [NSMutableString string];
    for( AddMemberViewController *myObject in treatment) {
        [string appendString:[NSString stringWithFormat:@"%@\n", myObject]];
    }
    tvTreatment.text = string;
    [self.editTreatmtId setString:@""];
    InterventionsIdString = [NSMutableString string];
    
    if (selectionsIdInterven.count > 0) {
    for( AddMemberViewController *myObject1 in selectionsIdInterven) {
        [InterventionsIdString appendString:[NSString stringWithFormat:@"%@,", myObject1]];
    }
        [InterventionsIdString deleteCharactersInRange:NSMakeRange([InterventionsIdString length]-1, 1)];
    }
}



-(void) showTreatment
{
    DLog(@"Treatment test messege");
    
    NSInteger idSend = 1001;
    
    BehaviourViewController *passVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BehaviourViewController"];
    passVC.passTreatId = idSend;
    [passVC setDelegate:self];
    [passVC setSelectedTitle:txtTreatment.text];
    [passVC setDictionary:self.dictTreatment];
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:passVC];
    [self presentViewController:nav animated:YES completion:^{}];
}


#pragma mark - UITextfeild delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)hideKeyBoard {
    if ([txtChildName isFirstResponder]) {
        [txtChildName resignFirstResponder];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                    
                case 0: {
                    
                    self.selectedImage = nil;
                    self.isImageRemove = YES;
                    imag.image = [UIImage imageNamed:@"avatar-140.png"];
                }
                    break;
                case 1: {
                    self.isImageRemove = NO;
                    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:picker animated:YES completion:^{}];
                }
                    break;
                case 2: {
                    self.isImageRemove = NO;
                    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:picker animated:YES completion:^{}];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
        default:
            
            break;
    }
}


#pragma mark - UIImagePickerController Delegate
/*
 Open PECropViewController automattically when image selected.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image.size.height < 250 ||  image.size.width < 250) {
        [Utility showAlertMessage:@"" withTitle:kAlertMinimumImageSize];
        return;
    }
    self.selectedImage = image;
    DLog(@"%s, Selected Profile image Size:%@",__FUNCTION__ ,NSStringFromCGSize(image.size));
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
}

/*
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
 {
 // Picking Image from Camera/ Library
 [picker dismissViewControllerAnimated:YES completion:^{}];
 self.selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
 
 if (!self.selectedImage)
 {
 return;
 }
 
 // Adjusting Image Orientation
 NSData *data = UIImagePNGRepresentation(self.selectedImage);
 UIImage *tmp = [UIImage imageWithData:data];
 UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
 scale:self.selectedImage.scale
 orientation:self.selectedImage.imageOrientation];
 self.selectedImage = fixed;
 gzipImageData = UIImagePNGRepresentation(self.selectedImage);
 [imag setImage:self.selectedImage];
 }
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    if (croppedImage.size.height < 250 ||  croppedImage.size.width < 250) {
        [Utility showAlertMessage:@"" withTitle:kAlertMinimumImageSize];
        return;
    }
    /*
     NSData *data = UIImagePNGRepresentation(self.selectedImage);
     DLog(@"Real Photo galary image from size in MB :%.2f",(float)data.length/1024.0f/1024.0f);*/
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    imag.image = croppedImage;
    self.selectedImage = croppedImage;
    DLog(@"%s, Family image Size After Cropping:%@",__FUNCTION__ ,NSStringFromCGSize(self.selectedImage.size));
    
    /* NSData *data1 = UIImagePNGRepresentation(self.selectedImage);
     DLog(@"Real Photo galary image from size in MB :%.2f",(float)data1.length/1024.0f/1024.0f);*/
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Action methods

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.selectedImage;
    
    UIImage *image = self.selectedImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - Base64 conversion

- (NSString*)base64forData:(NSData*) theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}


@end
