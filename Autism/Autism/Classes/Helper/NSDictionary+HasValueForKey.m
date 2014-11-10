//
//  NSDictionary+HasValueForKey.m
//  Autism
//
//  Created by Dipak on 5/9/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "NSDictionary+HasValueForKey.h"

@implementation NSDictionary (HasValueForKey)

-(BOOL)hasValueForKey:(NSString *)key
{
    if([self valueForKey:key] && [self valueForKey:key] != [NSNull alloc])
        return YES;
    else
        return NO;
}
@end
