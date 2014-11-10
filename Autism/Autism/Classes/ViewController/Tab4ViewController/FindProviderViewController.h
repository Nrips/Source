//
//  FindProviderViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface FindProviderViewController : UIViewController

@property (strong, nonatomic) NSString *providerNameString;
@property (strong, nonatomic) NSString *serviceCategoryString;
@property (strong, nonatomic) NSString *serviceCategoryId;


@property (strong, nonatomic) IBOutlet CustomTextField *txtProviderName;
@property (strong, nonatomic) IBOutlet CustomTextField *txtCityorTown;
@property (strong, nonatomic) IBOutlet CustomTextField *txtLocalAuthorityArea;
@property (strong, nonatomic) IBOutlet CustomTextField *txtServiceCategory;
@property (strong, nonatomic) IBOutlet UIButton *BtnCheckProvider;
@property(strong,nonatomic)NSString *parentViewType;
-(IBAction)checkProviderAction:(id)sender;

@end
