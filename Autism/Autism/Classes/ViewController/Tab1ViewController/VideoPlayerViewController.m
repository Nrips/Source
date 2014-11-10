//
//  VideoPlayerViewController.m
//  Autism
//
//  Created by Dipak on 8/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "Utility.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

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
    DLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(backAction:)];
    
   
    self.navigationItem.rightBarButtonItem = cancelButton;
    /*if ([self.parentView isEqualToString:kCallerViewActivityDetail]) {
        
        //TODO:More better solution
    }
    else{
         self.navigationItem.rightBarButtonItem = cancelButton;
       }*/
    
    
    

    if ([Utility getValidString:self.videoUrl].length > 0) {
        int iFrameHeight = IS_IPHONE_5 ? 504 : 416;

        NSMutableString *html = [NSMutableString string];
        
        
        [html appendString:@"<style type=\"text/css\">"];
        [html appendString:@"body {"];
        [html appendString:@"background-color: transparent;"];
        [html appendString:@"color: white;"];
        [html appendString:@"}"];
        [html appendString:@"</style>"];
        [html appendString:@"</head><body style=\"margin:0\">"];
        [html appendFormat:@"<iframe src=\"%@\" width=\"320\" height=\"%d\" frameBorder=\"0\"></iframe>", self.videoUrl,iFrameHeight];
        //[html appendFormat:@"<iframe src=\"%@\" width=\"320\" height=\"%d\" frameBorder=\"0\"></iframe>", self.videoUrl,iFrameHeight];

        //[html appendFormat:@"<iframe class=\"youtube-player\"  width=\"320\" height=\"%d\" type=\"text/html\" src=\"http://www.youtube.com/embed/VIDEO-ID?ps=docs&controls=1\" frameborder=\"0\" allowfullscreen></iframe>"self.videoUrl,iFrameHeight];

        [html appendString:@"</body></html>"];
        
        
        UIWebView *videoView = [[UIWebView alloc] initWithFrame:self.view.frame];
        videoView.scrollView.scrollEnabled = NO;
        [videoView loadHTMLString:html baseURL:nil];
        //[videoView setMediaPlaybackRequiresUserAction:no]
        //[videoView setAllowsInlineMediaPlayback:YES];
        //[videoView setMediaPlaybackRequiresUserAction:YES];
        
        [self.view addSubview:videoView];
    } else {
        DLog(@"Url is not available so could not load video");
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
