//
//  ReportToAWMView.h
//  Autism
//
//  Created by Deepak on 12/05/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol ReportToAWMViewDelegate <NSObject>

- (void)reportToAWMVDSuccessfullySubmitted;

@end

@interface ReportToAWMView : UIView

@property (nonatomic,weak) id <ReportToAWMViewDelegate>delegate;
@property(nonatomic, strong) NSString *selectedQuestionId;
@property (nonatomic) ReportToAWMType reportToAWMType;
@end
