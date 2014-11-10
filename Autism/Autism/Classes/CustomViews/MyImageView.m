//
//  MyImageView.m
//  Autism
//
//  Created by Neuron-iPhone on 2/22/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "MyImageView.h"

@interface MyImageView()
{
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSString *imageUrl;
@end

@implementation MyImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(MyImageView *)initWithFrame:(CGRect)frame andImageUrl:(NSString *)url {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageUrl = url;
        if ([appSharedData.imageCacheDictionary objectForKey:url]) {
            [self setImage:[[appSharedData imageCacheDictionary] objectForKey:url]];
        }
        else {
            self.imageData = [NSMutableData new];
            NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
            [conn start];
        }
    }
    return self;
}


- (void)configureImageForUrlWithLoader:(NSString *)url{
    //NSString *properlyEscapedURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.imageUrl = url;
    
    if ([[appSharedData imageCacheDictionary] objectForKey:url]) {
        [indicator stopAnimating];
        [self setImage:[[appSharedData imageCacheDictionary] objectForKey:url]];
    }
    else {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.backgroundColor = [UIColor clearColor];
        indicator.color = [UIColor purpleColor];
        indicator.center = self.center;// it will display in center of image view
        [self addSubview:indicator];
        [indicator startAnimating];

        self.imageData = [NSMutableData new];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
        [conn start];
    }
    
}
 

-(void)configureImageForUrl:(NSString *)url{
    NSString *properlyEscapedURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.imageUrl = properlyEscapedURL;
    if ([[appSharedData imageCacheDictionary] objectForKey:properlyEscapedURL]) {
        [self setImage:[[appSharedData imageCacheDictionary] objectForKey:properlyEscapedURL]];
    }
    else {
        self.imageData = [NSMutableData new];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:properlyEscapedURL]] delegate:self];
        [conn start];
    }
    
}
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.imageData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    UIImage *image = [UIImage imageWithData:self.imageData];
    //TODO Need to debug and nil image issue
    if (!image)
        return;
    [[appSharedData imageCacheDictionary] setObject:image forKey:self.imageUrl];
    //[indicator stopAnimating];
    [self setImage:image];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
@end
