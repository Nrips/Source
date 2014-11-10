//
//  NSDictionary+HasValueForKey.h
//  Autism
//
//  Created by Dipak on 5/9/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary_hasValueForKey : NSDictionary
@end

@interface NSDictionary (HasValueForKey)

-(BOOL)hasValueForKey:(NSString *)key;
@end
