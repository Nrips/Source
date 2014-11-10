//
//  Constants.h
//  Autism
//
//  Created by Neuron Solutions on 22/12/13.
//  Copyright (c) 2013 Neuron Solutions. All rights reserved.
//

#define KEY_USER_DEFAULTS_USER_ID                   @"UserID"
#define KEY_USER_DEFAULTS_USER_NAME                 @"UserName"
#define KEY_USER_DEFAULTS_USER_ROLE                 @"UserRole"
#define KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL      @"UserProfilePicUrl"
#define KEY_USER_DEFAULTS_USER_TYPE                 @"UserType"
#define DEVICE_ID                                   @"UserDeviceID"

#define KEY_USER_DEFAULTS_USER_City                 @"UserCity"
#define KEY_USER_DEFAULTS_USER_LocalAuthority       @"UserLocalAuthority"


#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define ViewHeight [UIScreen mainScreen].bounds.size.height

#define IOS_Version     [[[UIDevice currentDevice] systemVersion] floatValue]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

//Build Changes

//#define BASE_URL @"http://whatall.com/index.php/api/"

#define BASE_URL @"http://192.168.0.166/autism/index.php/api/"

//For Live

//#define BASE_URL @"https://connect.autismwestmidlands.org.uk/index.php/api/"

#define WEB_URL_OtherLocalAuthority @"auth/getOtherLocalAuthority"

#define WEB_URL_SignUp @"auth/signup"

#define WEB_URL_Login @"auth/login"

#define WEB_URL_Role @"auth/getRole"

#define WEB_URL_LocalAuthority @"auth/getLocalAuthority"

#define WEB_URL_FBLogin @"auth/fb_login"
#define WEB_URL_ApplicationDownload @"auth/PushApplicationDownload"

#define WEB_URL_FBUpdateLogin @"auth/FacebookPopup"

#define WEB_URL_GetQuestions @"auth/StoryQuestion"

#define WEB_URL_PostAnswers @"activity/StoryQuestion"

#define WEB_URL_GetBehaviour @"Activity/MyFamilyBehavaiours"

#define WEB_URL_GetTreatment @"activity/MyFamilyTreatment"

#define WEB_URL_ChildDiagnose @"activity/MyFamilyDiagnosis"

#define WEB_URL_QuestionKeywords @"Question/GetQuestionTag"

#define WEB_URL_AddQuestion @"Question/AddQuestion"

#define WEB_URL_GetAndSearchPeople @"Findpeople/SearchPeople"

#define WEB_URL_GetAllQueston @"Question/GetAllQuestions"

#define WEb_URL_GetEventDetail @"Events/GetAllEvents"

#define WEB_URL_GetMyQueston @"Question/GetMyAllQuestions"

#define WEB_URL_ShowingEventDetails @"Events/eventDetail"

#define WEB_URL_ActivityGetImages @"Activity/GetImagesByUrl"

#define WEB_URL_GetMyActivity @"Activity/GetMyActivity"
#define WEB_URL_GetMemberList @"Activity/GetMemberList"
#define WEB_URL_MemberInCircle @"Activity/GetMemberCircle"

#define WEB_URL_GetUserDetails @"auth/GetUserDetailById"

#define WEB_URL_HelpfulCount @"Question/HelpFullQuestion"

#define Web_URL_QuestionDetails @"Question/GetQuestionDetailById"

#define Web_URL_HelpfulAnswer @"Question/GetQuestionAnswerHelpfulById"

#define Web_URL_ReplyQuestion @"Question/GetQuestionAnswerById"

#define Web_URL_AddQuestion @"Question/AddQuestion"

#define Web_URL_EditQuestion @"Question/EditQuestion"

#define Web_URL_DeleteQuestion @"Question/DeleteQuestion"

#define Web_URL_EditAnswer @"Question/EditQuestionAnswer"
#define Web_URL_DeleteAnswer @"Question/DeleteQuestionAnswer"


#define Web_URL_PostQuestionComment @"Question/PostQuestionComment"
#define Web_URL_ReportActivityComment @"Activity/ReportActivityComment"
#define Web_URL_AttendEvent @"events/EventAttendUnattend"

#define Web_URL_QuestionReportToAWM @"Question/QuestionReportToAWM"
#define Web_URL_QuestionAnswerReportToAWM @"Question/QuestionAnswerReportToAWM"
#define Web_URL_ReportActivityReportToAWM @"Activity/ReportActivity"
#define Web_URL_ReportFamilyMemberReportToAWM @"Activity/ReportFamilyMember"
#define Web_URL_ReportStoryReportToAWM @"Activity/ReportStory"
#define Web_URL_InboxMemberReportToAWM @"Inbox/InboxMemberReportToAWM"
#define Web_URL_ServiceDetailReportToAWM @"provider/ProviderServiceReportToAWM"

#define Web_URL_AddMemberInTeam @"Findpeople/AddMemberInTeam"
#define Web_URL_AddProviderInTeam @"Provider/AddProviderInTeam"

#define Web_URL_PostLikeHug @"activity/PostLikeHug"

#define Web_URL_FindProvider @"provider/GetProviders"

#define Web_URL_QADetailHelpfull @"Question/QuestionAnswerHelpfull"

#define Web_URL_QADetailLike @"Question/QuestionAnwserLike"

#define Web_URL_PostActivity @"Activity/PostActivity"

#define Web_URL_PostInboxMessage @"inbox/PostMessage"

#define Web_URL_OtherUserActivity @"Activity/GetOtherMemberActivity" 

#define Web_URL_ShareActivity @"Activity/ShareActivity"

#define Web_URL_ServiceProviderCategory @"provider/GetServiceCategory"
#define Web_URL_ActivityComment @"Activity/ActivityComment"
#define Web_URL_BlockMember @"findpeople/BlockMember"
#define Web_URL_BlockUserFromQA @"Question/BlockUserFromQA"

#define Web_URL_ServiceProviderDetail @"provider/GetProviderDetail"

#define Web_URL_GetActivityDetailById @"Activity/GetActivityDetailById"

#define Web_URL_DeleteActivity @"Activity/DeleteActivity"

#define Web_URL_GetServiceDetail @"Provider/GetServiceDetailById"

#define Web_URL_ActivityCommentLike @"Activity/ActivityCommentLike"
#define WEB_URL_ProviderInCirlce  @"Activity/GetMemberProvider"


#define Web_URL_EditActivityComment @"Activity/EditActivityComment"

#define Web_URL_DeleteActivityComment @"Activity/DeleteActivityComment"

#define Web_URL_ContactUs @"auth/ContactUs"

#define Web_URL_EventReportToAWM @"Events/EventReportToAWM"

#define Web_URL_ShowReview @"Provider/GetServiceReviewsById"

#define Web_URL_WriteReview @"Provider/WriteReview"

#define Web_URL_RelationshipToYou @"Activity/MyFamilyRelation"

#define Web_Url_GetFamilyList  @"Activity/GetMemberFamily" 

#define Web_Url_DeleteFamilyMember @"activity/DeleteFamilyMember"

#define WEB_URL_AddFamilyMember @"Activity/AddFamilyMember"
#define WEB_URL_EditFamilyMember @"Activity/EditFamilyMember"

#define WEB_URL_DeleteFamilyMember @"activity/DeleteFamilyMember"

#define WEB_URL_GetMemberContact  @"inbox/GetMemberCircle"

#define WEB_URL_InboxMemberList   @"inbox/GetMemberList"

#define WEB_URL_InboxMemberSearchList @"activity/GetMemberList"

#define WEB_URL_PostMessege  @"inbox/PostNewMessage"

#define WEB_URL_EventAndCalendar  @"Events/CalenderData"

#define WEB_URL_GetMemberStory @"Activity/GetMemberStory"

#define WEB_URL_DeleteConversation @"inbox/DeleteConversation"

#define WEB_URL_GetMessageconversation @"inbox/GetMemberMessages"
#define WEB_URL_InboxMessageDetailDelete @"inbox/DeleteMessages"

#define WEB_URL_Logout @"auth/Logout"
#define WEB_URL_GetNotificationCount @"Activity/GetNotificationCount"
#define WEB_URL_GetNotificationList @"Activity/GetNotificationList"
#define WEB_URL_DeleteNotification @"Activity/DeleteNotification"

#define WEB_URL_UpdateProfilePicture @"activity/UpdateProfilePicture"

#define Web_URL_DeleteReview @"provider/DeleteReview"
#define Web_URL_EditReview @"provider/EditReview"

#define WEB_URL_PostMultiImage        @"activity/PostMultiImage"

#define WEB_URL_AddAlbum              @"activity/AddAlbum"

#define WEB_URL_GetALbumList          @"activity/GetMemberAlbum"

#define WEB_URL_GetPicturesInAlbum    @"activity/GetAlbumPictures"

#define WEB_URL_DeleteAlbum           @"activity/DeleteAlbum"

#define WEB_URL_RenameAlbum           @"activity/EditAlbum"

#define WEB_URL_AddPhotosInAlbum      @"activity/AddImageToAlbum"

#define WEB_URL_EditPictureCaption    @"activity/EditPictureCaption"

#define WEB_URL_DeletePicture         @"activity/DeleteAlbumPicture"

#define WEB_URL_MakeAlbumCover        @"activity/MakeAlbumCover"

#define WEB_URL_RemoveAlbumCover      @"activity/RemoveAlbumCover"




#define FBUserId                                      @"FBUserId"
#define kFacebookPostLink                             @"https://www.google.co.in/"
#define kFacebookPostImage                            @""
#define kFacebookPostName                             @"Neuron"
#define kFacebookPostCaption                          @"MY Connect Post"
#define kFacebookPostDescription                      @""
#define FacebookErrorTitleKey @"Error"
#define FacebookErrorDescriptionKey @"It seems like there is some problem with the facebook server. Please try again later."
#define kRememberMeFlag                                @"remember_me_flag"
#define kUserEmailUserDefault                          @"login_user_email_id"
#define kUserPasswordUserDefault                       @"login_user_password"

#define appUIGreenColor [UIColor colorWithRed:0/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f];

//Button Titles
#define kTitleInCircle                       @"In Circle"
#define kTitleAddToCircle                    @"Add to Circle"

#define kTitleUnblockMember                 @"Unblock Member"
#define kTitleBlockThisMember               @"Block This Member"
#define kTitleReportToAWM                   @"Report to AWM"
#define kTitleBlockUserFromQA               @"Block User from QA"
#define kTitleDeleteConversation            @"Delete Conversation"

#define kTitleAttendEvent                  @"Attend Event"
#define kTitleUnAttendEvent                @"Unattend Event"






//Alert Messages
#define kAlertMessageUnblockUser         @"Please unblock this member first."
#define kAlertMessageSomethingWrong      @"Sorry something went wrong from the server side"
#define kAlertMinimumImageSize           @"Minimum image size should be : 250 * 250 !"


#define kProfileTypeOther                     @"OtherProfile"
#define kProfileTypeMy                        @"My"
#define kTitleSelect                          @"Select"
#define kUpdateReview                         @"Update"

#define kPostUpdateTypeSendMessage            @"SendMessage"
#define kPostUpdateTypePostUpdate             @"PostUpdate"
#define kPostUpdateTypePostUpdateOther        @"PostUpdateOther"
#define kPostUpdateTypePostUpdateMy           @"PostUpdateMy"
#define kPostUpdateTypeSendDetailMessage      @"SendMessageDetail"
#define kCTAssetsPickerController             @"CTAssetsPickerController"
#define kPostTypeAddPhotosInAlbum             @"AddPhotosInAlbum"



//CERTIFICATE_TYPE
#define kCertificateDevelopment                          @"development"
#define kCertificateDistribution                         @"distribution"
#define kCertificateAppStore                             @"live"

//HotWords (Clickable words)

#define kHotWordHandle                             @"Handle"
#define kHotWordHashtag                            @"Hashtag"
#define kHotWordLink                               @"Link"
#define kHotWordNotification                       @"Notification"

#define kCallerViewActivity                       @"ActivityViewController"
#define kCallerViewQA                             @"QAViewController"
#define kCallerViewQADetail                       @"QADetailViewController"
#define kCallerViewMyQA                           @"MyQaViewController"
#define kCallerViewHelpful                        @"HelpfulDetailViewController"
#define kCallerViewReply                          @"ReplyDetailViewController"
#define kCallerViewQADetailHeader                 @"QADetailHeaderViewController"
#define kCallerViewActivityDetail                 @"ActivityDetailViewController"
#define kCallerViewActivityDetailHeader           @"ActivityDetailHeaderViewController"
#define kCallerViewEventDetail                    @"EventDetailViewController"
#define kEventType                                @"EditQuestion"
#define kCallerViewQADetailAnswerEdit             @"QADetailViewController"
#define kCallerViewFindPeople                     @"FindPeopleViewController"
#define kCallerViewReview                         @"ViewReviewViewController"
#define kCallerEditFamily                         @"FamilyListCell"
#define kCallerMyCircleProvider                   @"MyCircleProviderViewController"




//Title
#define kTitleNotifications                       @"Notifications"


//Keyboard
#define kHideKeyboard                                   @"HideKeyboardFrom"
#define kHideKeyboardFromPostViewController             @"HideKeyboardFromPostViewController"
#define kHideKeyboardFromTab3ViewController             @"HideKeyboardFromTab3ViewController"
#define kHideKeyboardFromFindPeopleViewController       @"HideKeyboardFromFindPeopleViewController"
#define kHideKeyboardFromFindProviderViewController     @"HideKeyboardFromFindProviderViewController"

#define kFindPeopleApiCAllFromProfileViewController     @"FindPeopleApiCAllFromProfileViewController"



#define kAddKeyboardObserver                    @"AddKeyboardObserver"
#define kRemoveKeyboardObserver                 @"RemoveKeyboardObserver"


//TAG
#define kTagDeleteActivityAlert             100
#define kTagDeleteAllMessagesAlert          101
#define kTagDeleteSelectedMessagesAlert     102
#define kTagBlockMemeberAlert               103
#define kTagDeleteReviewAlert               104
#define kTagEventAttendAlert                105

//MessageView Constant
#define CELL_CONTENT_MARGIN         10.0f
#define MESSAGE_DETAIL_LABEL_YAXIS  30.0f
#define INBOX_IMAGE_VIEW_HEIGHT     110.0f
#define INBOX_MESSAGELABEL_WIDTH    262.0f
#define INBOX_ATTACH_IMAGE_VIEW_HEIGHT     100.0f
#define INBOX_ATTACH_LINK_LABEL_HEIGHT     25.0f



//QA Constant
#define QA_VIEW_HEIGHT  70.0f
#define TAG_VIEW_HEIGHT  23.0f
#define BUTTON_VIEW_HEIGHT  34.0f
#define QACELL_CONTENT_MARGIN      9.0f

//Activity Constant
#define ACTIVITY_COLLECTIONVIEW_HEIGHT  100.0f
#define ACTIVITY_BUTTONVIEW0_HEIGHT 30.f
#define ACTIVITY_MEMBERNAME_HEIGHT 15.0f
#define ACTIVITY_TIMELABEL_HEIGHT 22.f
#define ACTIVITY_LABELMARGIN_HEIGHT 15.0f
#define ACTIVITY_VIDEOFRAME_HEIGHT 220.0f
#define ACTIVITY_ATTACHIMAGEFRAME_HEIGHT 102.0f
#define ACTIVITY_ATTACH_VIDEO_URL_HEIGHT 28.0f
#define CELL_LABEL_MARGIN         5.0f




//QADetail Constant
#define QADETAILBUTTON_VIEW_HEIGHT  32.0f
#define NAMELABEL_HEIGHT  20.0f
#define BUTTON_VIEW_MERGIN  10.0f


//ViewReview Constant
#define REVIEWBUTTON_VIEW_HEIGHT  30.0f
#define RATING_LABEL_YAXIS  30.0f
#define REVIEWCELL_CONTENT_MARGIN  9.0f

//Service Provider Constant
#define ProviderDetail_LABEL_YAXIS  30.0f
#define SERVICECELL_CONTENT_MARGIN  9.0f

#define SERVICE_DETAIL_LABEL_STARTING_Y_POSITION   58.0f
#define SERVICE_DETAIL_LABEL_MARGIN 10.0f
#define SERVICE_DETAIL_BASEIMAGE_HEIGHT 260.0f
#define PHONE_LABEL_HEIGHT   15.0f
#define RATING_VIEW_HEIGHT   10.0f
#define EMAIL_LABEL_HEIGHT   20.0f
#define WEBSITE_LABEL_HEIGHT 20.0f

#define MYCIRCLECELL_SEPRATOR 2.0f

#define SERVICE_BASEIMAGE_HEIGHT 280.0f

#define kProgressFractionCompleted @"fractionCompleted"

// Provider Constant
#define PROVIDER_DETAIL_LABEL_HIGHT  22.0f
#define SERVICE_TITLE_LABLE_HIGHT    22.0f
#define SERVICE_DETAIL_LABEL_STARTING_YPOSITION  22.0f

#define EVENT_DETAIL_LABEL_STARTING_YPOSITION   175.0f
#define EVENT_DETAIL_LABEL_MARGIN 10.0f
#define EVENT_DETAIL_BASEIMAGE_HEIGHT 260.0f
#define DICT_GET(_dict_, _key_) _dict_[_key_] == [NSNull null] ? @"" : _dict_[_key_]


// Enums will be defined here

typedef  enum{
    KTaskGetId,
    kTaskGetRole,
    kTaskGetLocalAuthority,
    kTaskGetOtherLocalAuthority,
    kTaskSignUp,
    kTaskLogin,
    kTaskFbdata,
    kTaskFbUpdateData,
    kTaskGetStoryQuestion,
    kTAskPostStoryAnswers,
    kTaskGetChildDiagnose,
    kTaskGetBehaviour,
    kTaskGetTreatment,
    kTaskQuestionKeywords,
    kTaskPostQuestion,
    kTaskGetSearchPeople,
    KTaskGetAllQuestion,
    kTaskGetEventDetails,
    kTaskMyQuestion,
    kTaskEventDetailShowing,
    kTaskActivityGetImages,
    kTaskGetActivity,
    kTaskGetMemberList,
    kTaskPostUrl,
    kTaskPostUpdate,
    kTaskPostUpdateOther,
    kTaskPostInboxMessage,
    kTaskPostUpdateMy,
    kTaskMemberInCircle,
    kTaskGetUserDetails, 
    kTaskQuestionDetails,
    kTaskHelpfulAnswer,
    kTaskReplyQuestion,
    kPostQuestionComment,
    kTaskAttendEvent,
    kTaskPostQuestionComment,
    kTaskReportActivityComment,
    kTaskAddMemberInTeam,
    kTaskQuestionReportToAWMForQuestions,
    kTaskQuestionReportToAWMForQuestionsReplies,
    kTaskQuestionReportToAWMForReportActivity,
    kTaskReportToAWMReportFamilyMember,
    kTaskLikeHug,
    kTaskQADetailHelpfull,
    kTaskQADetailLike,
    kTaskOtherActivity,
    kTaskShareActivity,
    kTaskFindProvider,
    kTaskProviderCategory,
    kTaskActivityComment,
    kTaskBlockMember,
    kTaskBlockUserFromQA,
    kTaskFindProviderDetail,
    kTaskGetActivityDetailById,
    kTaskDeleteActivity,
    kTaskServiceDetail,
    kTaskActivityCommentLike,
    kTaskEditActivityComment,
    kTaskDeleteActivityComment,
    kTaskContactUs,
    kTaskEventReportToAWM,
    kTaskShowReview,
    kTaskParseProviderServices,
    kTaskProviderInCircle,
    kTaskAddProviderInTeam,
    kTaskWriteReview,
    kTaskRelationToYou,
    kTaskGetFamilyList,
    kTaskAddFamilyMember,
    kTaskEditFamilyMember,
    kTaskDeleteFamilyMember,
    kTaskGetMemberContact,
    kTaskInboxMemberList,
    kTaskPostMessege,
    kTaskEventAndCalendar,
    kTaskGetMemberStory,
    kTaskDeleteConversation,
    kTaskGetMessageConversation,
    kTaskLogout,
    kTaskGetNotificationCount,
    kTaskGetNotificationList,
    kTaskDeleteNotification,
    kTaskUpdateProfilePicture,
    kTaskMessageDetailDelete,
    kTaskImageUploading,
    kTaskPushApplicationDownload,
    kTaskDeleteReview,
    kTaskEditReview,
    kTaskAddAlbum,
    kTaskAlbumList,
    kTaskPictureInAlbum,
    kTaskDeleteAlbum,
    kTaskRenameAlbum,
    kTaskInboxSearchMember,
    kTaskAddPhotosInAlbum,
    kTaskDeletePicture,
    kTaskEditCaption,
    kTaskMakeAlbumCover,
    kTaskRemoveAlbumCover
    }TaskType;

typedef enum{
    PostTypePublic = 0,
    PostTypeCircle = 1
} PostType;

typedef enum{
    ReportToAWMTypeQuestion = 0,
    ReportToAWMTypeQuestionReplies = 1,
    ReportToAWMTypeReportActivity = 2,
    ReportToAWMTypeReportEvent= 3,
    ReportToAWMTypeFamily= 4,
    ReportToAWMTypeStory= 5,
    ReportToAWMTypeInboxMember = 6,
    ReportToAWMTypeReportService= 7


} ReportToAWMType;

typedef enum{
    CommentTypeReplyOnQuestion = 0,
    CommentTypeActivity = 1,
    CommentTypeProfile = 2,
    CommentTypeActivityDetail = 3,
    CommentTypeEditAnswerInQADetail = 4

    
} CommentType;

typedef enum{
    UserTypeSelf = 0,
    UserTypeOther = 1
} UserType;

/*
 response_code
 RC0000 – Success Response.
 RC0001 – Error.
 RC0002 – No Result Found.
 RC0003 – Required field can not be empty.
 RC0004 – Session Expired.
 RC0005 – APN server error.
*/

/* Test Credential
 
 App Login Userid - avania@neuronsolutions.com   // it's also valid for live
           Psw    - test123
 
            Userid - nri.scs@gmail.com
            Psw    - 123456
 
App Login via Facebook Userid - neuronmobileteam@gmail.com
                       Psw    - neuron123
*/

