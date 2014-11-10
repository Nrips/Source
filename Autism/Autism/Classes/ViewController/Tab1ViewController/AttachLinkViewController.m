//
//  AttachLinkViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 3/18/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "AttachLinkViewController.h"
#import "CustomTextField.h"
#import "MyImageView.h"
#import "Utility.h"

static NSUInteger count;

@interface AttachLinkViewController ()
<UITextFieldDelegate>
{
    CustomTextField *txtLink;
    UIButton *btnGo;
    int i;
}

@property (strong, nonatomic) MyImageView *urlImageView;

@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSString *strUrl;

@end

@implementation AttachLinkViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupFeilds];
}

-(void) setupFeilds
{
    txtLink = [[CustomTextField alloc] initWithFrame:CGRectMake(10, 80,260 , 30)];
    txtLink.delegate = self;
    [self.view addSubview:txtLink];
    
    self.urlImageView =[[MyImageView alloc] initWithFrame:CGRectMake(70  ,115 ,185 ,130 )];
    [self.view addSubview:self.urlImageView];
    i = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveEvent:(id)sender {
    
    [self.delegate didSelectedImage:self.urlImageView.image];

    [self dismissViewControllerAnimated:YES completion:nil];
    }

- (IBAction)goEvent:(id)sender {
    
    [self getImagesByUrl];
}

#pragma mark service methods

-(void) getImagesByUrl
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *getImages =@{ @"activityUrl":txtLink.text };
    
    NSString *strImagesFromLink = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_ActivityGetImages];
    DLog(@"%s %@ api \n with parameters : %@",__FUNCTION__,strImagesFromLink,getImages);
        [serviceManager executeServiceWithURL:strImagesFromLink andParameters:getImages forTask:kTaskActivityGetImages completionHandler:^(id response, NSError *error, TaskType task) {
            DLog(@"%s %@ api \n with respnonse : %@",__FUNCTION__,strImagesFromLink,response);
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSArray *data =[response objectForKey:@"data"];
                self.imageArray =[data valueForKey:@"src"];
                
            });
        }
        
    }];
    
}


- (IBAction)selectImageAction:(id)sender {
    
    
}


- (IBAction)NextAction:(id)sender {
    
    self.strUrl = [[NSString alloc]init];
    
    DLog(@"%lu",(unsigned long)self.imageArray.count);
    
    NSInteger total = [self.imageArray count];
    
    DLog(@"Total = :%ld",(long)total);
     DLog(@"count = :%ld",(long)count);
    
    
    if(count == self.imageArray.count - 1)
    {
        count=0;
        
        self.strUrl = (NSString *)[self.imageArray objectAtIndex:count];
        [self.urlImageView configureImageForUrl:self.strUrl];
        
    }
    else
    {
        count++;
        
        self.strUrl = (NSString *)[self.imageArray objectAtIndex:count];
        [self.urlImageView configureImageForUrl:self.strUrl];

    }
    
}

- (IBAction)prevAction:(id)sender {
    
    self.strUrl = [[NSString alloc]init];
    
    DLog(@"%d i value",i);

    
    NSInteger total = [self.imageArray count];

    
    if(count==0)
    {
        count=total-1;
        
        self.strUrl = (NSString *)[self.imageArray objectAtIndex:count];
        [self.urlImageView configureImageForUrl:self.strUrl];

        
    }
    else
    {
        count--;
        
        self.strUrl = (NSString *)[self.imageArray objectAtIndex:count];
        [self.urlImageView configureImageForUrl:self.strUrl];

    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
