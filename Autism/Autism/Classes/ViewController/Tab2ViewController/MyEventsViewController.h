//
//  MyEventsViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/27/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import <EventKit/EventKit.h>
#import <MessageUI/MessageUI.h>
#import "STTweetLabel.h"

@protocol  MyEventsViewDelegate<NSObject>

@optional
- (void)didReloadMyEventView;

@end

@interface MyEventsViewController : UIViewController

@property (nonatomic,weak) id<MyEventsViewDelegate>delegate;
@property(nonatomic,strong) NSString *strEventId;
@property(nonatomic,strong) NSString *strMessage;
@property(nonatomic,strong) NSString *strLocation;


@property (strong, nonatomic) IBOutlet MyImageView *imageEvent;
@property (strong, nonatomic) IBOutlet STTweetLabel *lblDescription;

@property(strong, nonatomic)IBOutlet UILabel *lblEndDate;


@property (strong, nonatomic) IBOutlet UILabel *lblEventName;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

@property (strong, nonatomic) IBOutlet UILabel *lblUrl;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblCity;
@property (strong, nonatomic) IBOutlet UILabel *lblLocalAuthority;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganiser;
@property (strong, nonatomic) IBOutlet UILabel *lblPostcode;
@property (strong, nonatomic) IBOutlet UILabel *lblType;
@property (strong, nonatomic) IBOutlet UILabel *lblWhoAttend;


@property (strong, nonatomic) IBOutlet UILabel *showLabelAddress;
@property (strong, nonatomic) IBOutlet UILabel *showLabelCity;
@property (strong, nonatomic) IBOutlet UILabel *showLabelLocalAuthority;
@property (strong, nonatomic) IBOutlet UILabel *showLabelOrganiser;
@property (strong, nonatomic) IBOutlet UILabel *showLabelPostcode;
@property (strong, nonatomic) IBOutlet UILabel *showLabelType;
@property (strong, nonatomic) IBOutlet UILabel *showLabelWhoAttend;
@property (strong, nonatomic) IBOutlet UILabel *showLabelWebURL;
@property (strong, nonatomic) IBOutlet UILabel *showLabelOrganizerEmail;
@property (strong, nonatomic) IBOutlet UILabel *showLabelPhone;
@property (strong, nonatomic) IBOutlet UILabel *showLabelDescription;


@property (strong, nonatomic) IBOutlet UIView *cityView;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UIView *localAuthorityView;
@property (strong, nonatomic) IBOutlet UIButton *btnReportToAwm;

@property (strong, nonatomic) IBOutlet UIImageView *imgAddress;
@property (strong, nonatomic) IBOutlet UIImageView *imgCity;
@property (strong, nonatomic) IBOutlet UIImageView *imgLocalAuthority;
@property (strong, nonatomic) IBOutlet UIImageView *imgOrganizer;
@property (strong, nonatomic) IBOutlet UIImageView *imgPostcode;
@property (strong, nonatomic) IBOutlet UIImageView *imgType;
@property (strong, nonatomic) IBOutlet UIImageView *imgWhoAttend;
@property (strong, nonatomic) IBOutlet UIImageView *imgWebUrl;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhoneNum;
@property (strong, nonatomic) IBOutlet UIImageView *imgEmail;
@property (strong, nonatomic) IBOutlet UIImageView *imgBaseField;


@property (nonatomic, strong) NSString *isSelfEvent;
@property (nonatomic, strong) NSString *parentViewControllerName;
@property (nonatomic, strong) NSString *eventDescription;



// TODO: Changed By Utkarsh Singh------->

@property (weak, nonatomic) IBOutlet UITextView *txtViewDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtViewDescriptionHeightConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblAddressHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblLocationHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblWhoShouldAttendHeightConstraint;


- (IBAction)attendEvent:(id)sender;
- (IBAction)addToCalender:(id)sender;

@end
