//
//  AlbumListVC.m
//  Autism
//
//  Created by Neuron-iPhone on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "AlbumListVC.h"
#import "PictureListCVCell.h"
#import "Utility.h"
#import "CTAssetsPickerController.h"
#import "UploadingProgressView.h"
#import "PicturePopupVC.h"

#define SegueIdentifierForPopup @"embedPopup"

@interface AlbumListVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate,UIGestureRecognizerDelegate,PicturePopupVCDelegate>

@property (strong,nonatomic) UIBarButtonItem *addButton;
@property (strong,nonatomic) NSArray *arrPicturesInAlbum;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UploadingProgressView *postPhotosProgressView;
@property (nonatomic, weak)   PicturePopupVC *containerViewController;
@property (nonatomic, weak)   AlbumListVC *sourceViewController;
@property ( nonatomic) BOOL isSelfAlbum;

@property (strong, nonatomic) NSString *currentSegueIdentifier;

@end

@implementation AlbumListVC

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
    self.appDel = [[UIApplication sharedApplication] delegate];
    
    [self  callPicturesInAlbumService];
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        DLog(@"Other user profile");
    }
    else
    {
    self.addButton = [[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                      target:self
                      action:@selector(addPicturesInAlbum)];
    self.navigationItem.rightBarButtonItem = self.addButton;
    }
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(longPressDetected:)];
    lpgr.minimumPressDuration = 0.6; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isSelfAlbum == NO) {
        DLog(@"Other userProfile");
    }
    else
    {
    
    }

//    [self.imageArray removeAllObjects];
//    [self.assets removeAllObjects];
    
    if ([self isMovingToParentViewController])
    {
        DLog(@"isMovingToParentViewController");
        if (self.imageArray.count > 0) {
            [self.imageArray removeAllObjects];
            
        }
        if (self.assets.count > 0) {
            [self.assets removeAllObjects];
        }
        [self.collectionView reloadData];
    }
    
    if([self.callerView isEqualToString:kPostTypeAddPhotosInAlbum])
    {
        [self showProgressView];
    }
}

#pragma mark -
- (void)longPressDetected:(UIGestureRecognizer *)sender
{
    CGPoint touchesPoint = [sender locationInView:self.collectionView];
    
    NSIndexPath *indexPath  = [self.collectionView indexPathForItemAtPoint:touchesPoint];
    PictureListCVCell *cell = (PictureListCVCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.isSelfAlbum = [cell.isSelfAlbumPicture boolValue];
    if (self.isSelfAlbum == NO) {
        DLog(@"Other userProfile");
    }
    else
    {
    if (indexPath == nil) {
        DLog(@"long press on table view but not on a row");
       }
    else
        if (sender.state == UIGestureRecognizerStateBegan) {
            DLog(@"long press on table view at row >>>>> %ld", (long)indexPath.row);
            //PicturePopupVC * child = [[PicturePopupVC alloc] init];
            
            PicturePopupVC *childPopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PicturePopupVC"];
            [childPopupVC setDelegate:self];
            childPopupVC.pictureCaption = cell.pictureCaption;
            childPopupVC.pictureId      = cell.pictureId;
            childPopupVC.albumId        = self.albumId;
            childPopupVC.isAlbumCover   = cell.isAlbumCover;
            DLog(@"Album status :  %@",cell.isAlbumCover);
            [self.navigationController addChildViewController:childPopupVC];
            //child.view.frame = self.navigationController.bounds;
            [self.navigationController.view addSubview:childPopupVC.view];
            [childPopupVC beginAppearanceTransition:YES animated:YES];
            [UIView
             animateWithDuration:0.3
             delay:0.0
             options:UIViewAnimationOptionCurveEaseOut
             animations:^(void){
                 childPopupVC.view.alpha = 1.0;
             }
             completion:^(BOOL finished) {
                 [childPopupVC endAppearanceTransition];
                 [childPopupVC didMoveToParentViewController:self.navigationController];
             }
             ];
        }
        else {
            //DLog(@"gestureRecognizer.state >>>>> %ld", sender.state);
        }
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    DLog(@"%s", __PRETTY_FUNCTION__);
//    
//    if ([segue.identifier isEqualToString:SegueIdentifierForPopup]) {
//        self.containerViewController = segue.destinationViewController;
//    }
//}

- (void)addPicturesInAlbum
{
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allAssets];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    //picker.selectedAssets       = [NSMutableArray arrayWithArray:self.assets];
    
    [self presentViewController:picker animated:YES completion:^{}];
}

#pragma mark - UIcollectionview datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrPicturesInAlbum.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PictureListCVCell *pictureCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PictureListCVCell" forIndexPath:indexPath];
    
    [pictureCell configureCell:self.arrPicturesInAlbum[indexPath.row]];
    
    DLog(@"asas %@",pictureCell.lblCaption.text);
    return pictureCell;
}

#pragma mark - collectionview delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.assets = [NSMutableArray arrayWithArray:assets];
    self.imageArray = [self getImagesFromSelectedAssets:self.assets];
    DLog(@"Done with images");
    if (self.imageArray.count > 0) {
        [self callAddPhotosInAlbum];

    }
        //[self.collectionView reloadData];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

//Call when we select asset from Photo library
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    
    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Please select not more than 10 assets"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
    //return asset.defaultRepresentation != nil;
    
}

- (NSMutableArray*)getImagesFromSelectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in assets) {
		id obj = [asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			continue;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        
        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        
        if(assetRep != nil) {
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            imgRef = [assetRep fullScreenImage];
            
            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [returnArray addObject:img];
        }
		
	}
    return returnArray;
}


#pragma mark - service methods
- (void)callPicturesInAlbumService
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *postParams =@{    @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                    @"album_id" : ObjectOrNull(self.albumId)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetPicturesInAlbum];
    DLog(@"%s Performing %@",__FUNCTION__,urlString);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskPictureInAlbum completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.arrPicturesInAlbum = [NSArray new];
                self.arrPicturesInAlbum = [parsingManager parseResponse:response forTask:task];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
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
    }];
}

- (void)callAddPhotosInAlbum
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *postParameters = @{   @"album_id" : ObjectOrNull(self.albumId)
                                        };
    [self showProgressView];
    if ([self.callerView isEqualToString:kPostTypeAddPhotosInAlbum]) {
        self.appDel.isPostAddPhotosTaskRunning = YES;
    }
    self.addButton.enabled = NO;
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_AddPhotosInAlbum];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__, requestUrl,postParameters);
    

    [serviceManager executePostImageServiceWithURL:requestUrl postParameters:postParameters imageArray:self.imageArray object:self forTask:kTaskAddPhotosInAlbum completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api response:%@",__FUNCTION__,requestUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                [self callPicturesInAlbumService];
                //[self dismissViewControllerAnimated:YES completion:nil];
                
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                if ([[dict valueForKey:@"is_blocked"] boolValue] || [[dict valueForKey:@"is_you_blocked"] boolValue]){
                    [Utility showAlertMessage:@"You cannot send a message to this user at this time. If you want to know why, please contact AWM." withTitle:@""];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else {
            DLog(@"Error:%@", error);
            if ([[error localizedDescription] isEqualToString:@"cancelled"])
                [Utility showAlertMessage:@"Picture post cancelled" withTitle:@""];
            else
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        if (task == kTaskAddPhotosInAlbum) {
            self.appDel.isPostAddPhotosTaskRunning = NO;
        }
        self.addButton.enabled = YES;
        [self.postPhotosProgressView removeFromSuperview];
        self.postPhotosProgressView = nil;
    }];

    /*
    NSDictionary *postParams =@{    @"Files": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                    @"album_id" : ObjectOrNull(self.albumId)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetPicturesInAlbum];
    DLog(@"%s Performing %@",__FUNCTION__,urlString);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTAskAddPhotosInAlbum completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.collectionView reloadData];
                });
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
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
    }];*/
}

#pragma mark - Progress View Methods

-(void)showProgressView {
    
    CGRect frame = self.view.frame;
    //frame.origin.y = frame.origin.y - 50;
    
    if (!self.postPhotosProgressView) {
        self.postPhotosProgressView = [[UploadingProgressView alloc] initWithFrame:frame];
    }
    self.postPhotosProgressView.callerView = self.callerView;
    [self.view addSubview:self.postPhotosProgressView];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSString *action = (__bridge NSString*)context;
    float progress = [[change valueForKey:@"new"] floatValue];
    DLog(@"Uploading action:%@ \n progress:%f",action, progress);
    
    self.postPhotosProgressView.callerView = action;
    [self.postPhotosProgressView updateProgressBar:progress];
}

#pragma mark - custom delegates
- (void)didReloadMyPictureAlbum
{
    [self callPicturesInAlbumService];
}


@end
