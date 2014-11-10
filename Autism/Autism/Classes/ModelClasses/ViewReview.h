//
//  ViewReview.h
//  Autism
//
//  Created by Neuron Solutions on 5/29/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewReview : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *reviewText;
@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) NSString *reviewId;
@property (strong, nonatomic) NSString *serviceId;
@property (nonatomic) BOOL isSelfReview;


@end
