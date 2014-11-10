//
//  GzipCompression.h
//  Autism
//
//  Created by Neuron-iPhone on 5/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface GzipCompression : NSObject

+ (NSData *)gzipInflate:(NSData*)data;
+ (NSData *)gzipDeflate:(NSData*)data;

@end
