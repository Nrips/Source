//
//  FindPeopleHeaderView.h
//  Autism
//
//  Created by Neuron Mac on 10/09/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FindPeopleHeaderView.h"
#import "FindPeopleViewController.h"
#import "CustomTextView.h"

@protocol FindPeopleHeaderViewDelegate <NSObject>

- (void)showPickerOnClick;
- (void)clickOnSearchButton:(NSString*)nameString emailString:(NSString *)email cityString:(NSString *)city localAuthorityString:(NSString *)localAuthority;
-(void)assignActiveTextField:(UITextField*) textField;
@end

@interface FindPeopleHeaderView : UIView <FindPeopleViewControllerDelegate,UITextViewDelegate>

-(void)setValueInLocalAuthority:(NSString *)localAuthority;

@property (nonatomic,weak) id <FindPeopleHeaderViewDelegate>delegate;

@property(nonatomic,weak) IBOutlet CustomTextView *txtName;
@property(nonatomic,weak) IBOutlet CustomTextView *txtMail;
@property(nonatomic,weak) IBOutlet CustomTextView *txtCity;
@property(nonatomic,weak) IBOutlet CustomTextView *txtLocalAuthority;

@property(nonatomic,strong)NSString *strAuthority;

@end
