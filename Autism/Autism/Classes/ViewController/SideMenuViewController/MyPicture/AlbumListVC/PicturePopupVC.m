//
//  PicturePopupVC.m
//  Autism
//
//  Created by Neuron-iPhone on 9/11/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "PicturePopupVC.h"
#import "AlbumListVC.h"
#import "Utility.h"

@interface PicturePopupVC ()<UIAlertViewDelegate>

@property (nonatomic,weak) PicturePopupVC *child;
@property (nonatomic,weak) AlbumListVC *parentView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *btnMakeAlbumCover;
@property (strong, nonatomic) IBOutlet UILabel *lblCaption;
@property (strong, nonatomic) NSString *pictureCaptionNew;
@property ( nonatomic)BOOL isCurrentCover;

- (IBAction)editCaption_Action:(id)sender;
- (IBAction)deletePicture_Action:(id)sender;
- (IBAction)albumCover_Action:(id)sender;


@end

@implementation PicturePopupVC

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
    // Do any additional setup after loading the view.
    //self.baseView.alpha = 0.5;
    self.tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.tapGesture];
    
    if (![Utility getValidString:self.pictureCaption].length > 0)
         self.lblCaption.text = @"No Caption";
    else
         self.lblCaption.text = self.pictureCaption;
    
    self.isCurrentCover = [self.isAlbumCover boolValue];
    if (self.isCurrentCover == YES)
        [self.btnMakeAlbumCover setTitle:@"Remove Album Cover" forState:UIControlStateNormal];
    else
        [self.btnMakeAlbumCover setTitle:@"Make Album Cover" forState:UIControlStateNormal];
    
    self.contentView.layer.cornerRadius = 10.0f;
    self.contentView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)tapGestureEvent:(id)sender {
    
    [self removePopupview];
    /*
    self.parentView = [self.storyboard instantiateViewControllerWithIdentifier:@"AlbumListVC"];
    [self.child didMoveToParentViewController:self.parentView];
    [self.child beginAppearanceTransition:NO animated:YES];
    [UIView
     animateWithDuration:0.3
     
     animations:^(void){
         self.child.view.alpha = 0.0;
     }
     completion:^(BOOL finished) {
         [self.child endAppearanceTransition];
         [self.child.view removeFromSuperview];
         [self.child removeFromParentViewController];
     }
     ];
     */
}
- (IBAction)editCaption_Action:(id)sender {
    //self.tapGesture.enabled = NO;
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Edit Caption"
                                                  message:@"Enter a new caption for this picture"
                                                 delegate:self cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)deletePicture_Action:(id)sender {
    [self callDeletePictureService];
}

- (IBAction)albumCover_Action:(id)sender {
    [self callAlbumCoverService];
}
#pragma mark - private methods
- (void)removePopupview
{
    self.view=nil;
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
#pragma mark - alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self callEditCaptionService:[[alertView textFieldAtIndex:0]text]];
    }
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    UIView *viewTouched = [self.view hitTest:point withEvent:nil];
    if (viewTouched.tag == 100) {
        // Don't BEGIN the gestureRecognizer
        return NO;
    } else {
        // Do BEGIN the gestureRecognizer
        return YES;
    }
}

#pragma mark - service methods
- (void)callEditCaptionService:(NSString *)caption
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *postParams =@{   @"album_picture_id"        : ObjectOrNull(self.pictureId),
                                   @"album_picture_caption"   : ObjectOrNull(caption)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_EditPictureCaption];
    DLog(@"%s Performing %@ with parameters \n %@",__FUNCTION__,urlString,postParams);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskEditCaption completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(didReloadMyPictureAlbum)]) {
                    [self.delegate didReloadMyPictureAlbum];
                }
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    //[Utility showAlertMessage:@"Please rename album with proper name"withTitle:@"Edit Album"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removePopupview];
    }];
}

- (void)callDeletePictureService
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *postParams =@{    @"album_picture_id"  : ObjectOrNull(self.pictureId)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_DeletePicture];
    DLog(@"%s Performing %@ with parameters \n %@",__FUNCTION__,urlString,postParams);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskDeletePicture completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                if ([self.delegate respondsToSelector:@selector(didReloadMyPictureAlbum)]) {
                    [self.delegate didReloadMyPictureAlbum];
                }
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    //[Utility showAlertMessage:@"Please rename album with proper name"withTitle:@"Edit Album"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removePopupview];
    }];
}

- (void)callAlbumCoverService
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *postParams = [NSDictionary new];
    NSString     *urlString  = [NSString new];
    TaskType task;
    if (self.isCurrentCover == YES) {
        task = kTaskRemoveAlbumCover;
         postParams =@{    @"album_picture_id"  : ObjectOrNull(self.pictureId),
                           @"album_id"          : ObjectOrNull(self.albumId)
                      };
         urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_RemoveAlbumCover];
        DLog(@"%s Performing %@ with parameters \n %@",__FUNCTION__,urlString,postParams);

    }
    else
    {
        task = kTaskMakeAlbumCover;
        postParams =@{    @"album_picture_id"  : ObjectOrNull(self.pictureId),
                          @"album_id"          : ObjectOrNull(self.albumId)
                          };
        urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_MakeAlbumCover];
        DLog(@"%s Performing %@ with parameters \n %@",__FUNCTION__,urlString,postParams);
    }
    
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:task completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(didReloadMyPictureAlbum)]) {
                    [self.delegate didReloadMyPictureAlbum];
                }
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    //[Utility showAlertMessage:@"Please rename album with proper name"withTitle:@"Edit Album"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removePopupview];
    }];
}

@end
