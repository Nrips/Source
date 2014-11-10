//
//  ParsingManager.m
//  Autism
//
//  Created by Haider on 03/02/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "ParsingManager.h"
#import "Behaviour.h"
#import "PersonInFinder.h"
#import "GetAllQuestion.h"
#import "GetMyQuestion.h"
#import "QuestionsInStory.h"
#import "EventsDetail.h"
#import "GetMyActivity.h"
#import "MemberInCircle.h"
#import "UserDetails.h"
#import "QuestionDetail.h"
#import "HelpfulAnswer.h"
#import "ReplyQuestion.h"
#import "FindProvider.h"
#import "ActivityDetails.h"
#import "ProviderDetail.h"
#import "NSDictionary+HasValueForKey.h"
#import "ProviderServices.h"
#import "ProviderInCircle.h"
#import "ViewReview.h"
#import "MemberInFamily.h"
#import "MessageInInbox.h"
#import "EventCountOnMonth.h"
#import "ContactInCircle.h"
#import "InboxDetailMessage.h"
#import "Notification.h"
#import "Member.h"
#import "AlbumList.h"
#import "PicturesInAlbum.h"
#import "MessageSearch.h"

static ParsingManager *objParsingManager;
@implementation ParsingManager

+ (ParsingManager *)sharedManager{
    static dispatch_once_t predicate;
    if(objParsingManager == nil){
        dispatch_once(&predicate,^{
            objParsingManager = [[ParsingManager alloc] init];
        });
    }
    return objParsingManager;
}

- (id)parseResponse:(id)response forTask:(TaskType)task{

    NSMutableArray *commonArray = [[NSMutableArray alloc]init];
    
    if (task == kTaskGetSearchPeople)
    {
        
        NSArray *tempArray = [response objectForKey:@"data"];
        
        for (int i = 0; i < [tempArray count]; i++)
        {
            NSDictionary *tempDic = [tempArray objectAtIndex:i];
            PersonInFinder *person = [[PersonInFinder alloc]init];
     
            if ([tempDic hasValueForKey:@"member_uname"]) {
                person.personName = [tempDic  objectForKey:@"member_uname"];
            }
            if ([tempDic hasValueForKey:@"member_city"]) {
                person.city = [tempDic objectForKey:@"member_city"];
            }
            if ([tempDic hasValueForKey:@"member_image"]) {
                person.imageUrl = [tempDic objectForKey:@"member_image"];
            }
            if ([tempDic hasValueForKey:@"member_role"]) {
                person.role = [tempDic objectForKey:@"member_role"];
            }
            if ([tempDic hasValueForKey:@"member_id"]) {
                person.UserID = [tempDic objectForKey:@"member_id"];
            }
            if ([tempDic hasValueForKey:@"member_local_authority"]) {
                person.localAuthority = [tempDic objectForKey:@"member_local_authority"];
            }
            if ([tempDic hasValueForKey:@"member_in_circle"]) {
                person.isInCircle = [[tempDic objectForKey:@"member_in_circle"]boolValue];
            }
            if ([tempDic hasValueForKey:@"is_memeber_blocked"]) {
                person.isMemeberBlocked = [[tempDic objectForKey:@"is_memeber_blocked"]boolValue];
            }
            
            [commonArray addObject:person];
        }
    }
    else if (task == kTaskGetStoryQuestion)
    {
        
        NSArray *tempArray = [response objectForKey:@"data"];
        
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            QuestionsInStory *questions = [[QuestionsInStory alloc] init];
            questions.questionsName =[tempDic objectForKey:@"sq_name"];
            questions.idQues = [tempDic objectForKey:@"sq_id"];
            [commonArray addObject:questions];
        }];
        
    }
    else if (task == KTaskGetAllQuestion){
        
        NSArray *tempQuestionArray = [response objectForKey:@"data"];
        
        for (int i=0; i<[tempQuestionArray count]; i++)
        {
            NSDictionary *tempQuestinDic = [tempQuestionArray objectAtIndex:i];
            GetAllQuestion *question = [[GetAllQuestion alloc]init];
            
            question.getQuestion        = [tempQuestinDic objectForKey:@"question"];
            question.quetionDetails     = [tempQuestinDic objectForKey:@"question_detail"];
            question.imageUrl           = [tempQuestinDic objectForKey:@"member_picture"];
            question.helpfulCount       = [tempQuestinDic objectForKey:@"question_helpful_count"];
            question.repliesCount       = [[tempQuestinDic objectForKey:@"question_reply_count"]stringValue];
            question.questionId         = [tempQuestinDic objectForKey:@"question_id"];
            question.userName           = [tempQuestinDic objectForKey:@"member_name"];
            question.isSelfQuestion     = [[tempQuestinDic objectForKey:@"question_self"] boolValue];
            question.isQuestionReported = [tempQuestinDic objectForKey:@"question_is_reported"];
            question.addedQuestionMemberID = [tempQuestinDic objectForKey:@"question_added_member_id"];
            question.isMemberAlreadyInCircle = [[tempQuestinDic objectForKey:@"already_in_circle"] boolValue];
            question.tagsArray = [tempQuestinDic objectForKey:@"question_tags"];
            question.isHelpful = [[tempQuestinDic objectForKey:@"is_helpful"] boolValue];
          
            if ([tempQuestinDic hasValueForKey:@"member_tagged"]) {
                question.memberTagsArray = [tempQuestinDic objectForKey:@"member_tagged"];
            }
            
            [commonArray addObject:question];
        }
    }
    
    else if (task == kTaskGetEventDetails)
    {
        
        NSArray *tempQuestionArray = [response objectForKey:@"data"];
        for (int i=0; i<[tempQuestionArray count]; i++)
        {
            
            NSDictionary *tempQuestinDic = [tempQuestionArray objectAtIndex:i];
            
            EventsDetail *events = [[EventsDetail alloc]init];
            events.eventHeading = [tempQuestinDic objectForKey:@"event_name"];
            events.location = [tempQuestinDic objectForKey:@"event_location"];
            events.fullDate =   [tempQuestinDic objectForKey:@"event_full_date"];
            events.time = [tempQuestinDic objectForKey:@"event_time"];
            events.colorCode = [tempQuestinDic objectForKey:@"event_color_code"];
            events.date = [tempQuestinDic objectForKey:@"event_date"];
            events.day = [tempQuestinDic objectForKey:@"event_day"];
            events.month = [tempQuestinDic objectForKey:@"event_month"];
            events.eventId = [tempQuestinDic objectForKey:@"event_id"];
            
            [commonArray addObject:events];
            
        }
    }
    
    else if (task == kTaskMyQuestion){
        
        NSArray *tempQuestionArray = [response objectForKey:@"data"];
        
        for (int i=0; i<[tempQuestionArray count]; i++) {
            
            NSDictionary *tempQuestinDic = [tempQuestionArray objectAtIndex:i];
            GetMyQuestion  *myQuestion = [[GetMyQuestion alloc]init];
          
            myQuestion.getQuestion        = [tempQuestinDic objectForKey:@"question"];
            myQuestion.quetionDetails     = [tempQuestinDic objectForKey:@"question_detail"];
            myQuestion.imageUrl           = [tempQuestinDic objectForKey:@"member_picture"];
            myQuestion.helpfulCount       = [tempQuestinDic objectForKey:@"question_helpful_count"];
            myQuestion.repliesCount       = [[tempQuestinDic objectForKey:@"question_reply_count"]stringValue];
            myQuestion.questionId         = [tempQuestinDic objectForKey:@"question_id"];
            myQuestion.userName           = [tempQuestinDic objectForKey:@"member_name"];
            myQuestion.isSelfQuestion     = [[tempQuestinDic objectForKey:@"question_self"] boolValue];
            myQuestion.isQuestionReported = [[tempQuestinDic objectForKey:@"question_is_reported"] boolValue];
            myQuestion.addedQuestionMemberID = [tempQuestinDic objectForKey:@"question_added_member_id"];
            myQuestion.isMemberAlreadyInCircle = [[tempQuestinDic objectForKey:@"already_in_circle"] boolValue];
            myQuestion.tagsArray = [tempQuestinDic objectForKey:@"question_tags"];
            myQuestion.isHelpful = [[tempQuestinDic objectForKey:@"is_helpful"] boolValue];
            
            if ([tempQuestinDic hasValueForKey:@"member_tagged"]) {
                myQuestion.memberTagsArray = [tempQuestinDic objectForKey:@"member_tagged"];
            }

    DLog(@"string tag value %@",myQuestion.memberTagsArray);
            //DLog(@" parsing%@",tempQuestinDic);
            
            [commonArray addObject:myQuestion];
        }
    }
    
    
    else if ((task == kTaskGetActivity) || (task == kTaskOtherActivity))
    {
        NSArray *tempArray = [response objectForKey:@"data"];
        
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            GetMyActivity *myActivity = [[GetMyActivity alloc] init];
            myActivity.name =[tempDic objectForKey:@"member_name"];
            myActivity.detail = [tempDic objectForKey:@"member_activity_text"];
            
            myActivity.picture = [tempDic objectForKey:@"member_picture"];
            myActivity.hug = [tempDic objectForKey:@"member_activity_hug"];
            myActivity.like = [tempDic objectForKey:@"member_activity_like"];
            myActivity.activityId = [tempDic objectForKey:@"activity_id"];
            myActivity.activityMemberId = [tempDic objectForKey:@"activity_member_id"];
            myActivity.isMemberActivityReported = [[tempDic objectForKey:@"member_activity_is_reported"] boolValue];
            myActivity.isSelfMemberActivity = [[tempDic objectForKey:@"member_activity_self"] boolValue];
            myActivity.isMemberAlreadyCircle = [[tempDic objectForKey:@"is_member_already_circle"] boolValue];
            myActivity.isMemberActivityLike = [[tempDic objectForKey:@"member_activity_like"] boolValue];
            myActivity.isMemberActivityHug = [[tempDic objectForKey:@"member_activity_hug"] boolValue];
            myActivity.isMemeberBlocked = [[tempDic objectForKey:@"is_memeber_blocked"]boolValue];
           
             if ([tempDic hasValueForKey:@"is_wall_post"]) {
                myActivity.isWallPost = [[tempDic objectForKey:@"is_wall_post"]boolValue];
                }
            
            if ([tempDic hasValueForKey:@"wall_post_member_id"]) {
                myActivity.wallPostUSerId = [tempDic objectForKey:@"wall_post_member_id"];
            }
            
            if ([tempDic hasValueForKey:@"wall_post_member_name"]) {
                myActivity.wallPostUSerName = [tempDic objectForKey:@"wall_post_member_name"];
            }
            
            
            myActivity.attachVideoUrl = [tempDic hasValueForKey:@"activity_video_link"] ? [tempDic objectForKey:@"activity_video_link"] : @"";


             myActivity.videoThumbnailImageUrl = [tempDic hasValueForKey:@"activity_video_thumbnail"] ? [tempDic objectForKey:@"activity_video_thumbnail"] : @"";
            
            myActivity.videoUrl = [tempDic hasValueForKey:@"activity_video_ifame"] ? [tempDic objectForKey:@"activity_video_ifame"] : @"";
            
            myActivity.tagsArray = [tempDic objectForKey:@"member_tagged"];
            myActivity.activityTime = [tempDic objectForKey:@"activity_time"];
           
            if ([tempDic hasValueForKey:@"activity_images"]) {
                myActivity.imagesArray = [tempDic objectForKey:@"activity_images"];
                DLog(@"activity images %@",myActivity.imagesArray);
            }
            
            if ([tempDic hasValueForKey:@"member_activity_link"]) {
                myActivity.attachLinkUrl = [tempDic objectForKey:@"member_activity_link"];
                
            }
            
            if ([tempDic hasValueForKey:@"member_activity_image_attach_link"]) {
                myActivity.attachLinkThumbnailImageUrl = [tempDic objectForKey:@"member_activity_image_attach_link"];
                
            }
         [commonArray addObject:myActivity];
            
        }];
    }
    
    else if (task == kTaskMemberInCircle)
    {
        
        NSArray *tempArray = [response objectForKey:@"data"];
        
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            MemberInCircle *memberInCircle =[[MemberInCircle alloc] init];
            memberInCircle.name =[tempDic objectForKey:@"member_name"];
            memberInCircle.locationAuth = [tempDic objectForKey:@"member_local_authority"];
            memberInCircle.userImage = [tempDic objectForKey:@"member_image"];
            memberInCircle.otherUserKey = [tempDic objectForKey:@"member_id"];
            memberInCircle.role = [tempDic objectForKey:@"member_role"];
            memberInCircle.city = [tempDic objectForKey:@"member_city"];
            memberInCircle.userId = [tempDic objectForKey:@"member_id"];

            [commonArray addObject:memberInCircle];
        }];
    }
    
    
    else if (task == kTaskGetUserDetails)
    {
        
        NSArray *tempArray = [response objectForKey:@"data"];
        
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            UserDetails  *userDet =[[UserDetails alloc] init];
            userDet.name =[tempDic objectForKey:@"member_full_name"];
            userDet.location =[tempDic objectForKey:@"member_local_authority"];
            userDet.userImage =[tempDic objectForKey:@"member_picture"];
            [commonArray addObject:userDet];
        }];
        
    }
    
    
    else if (task == kTaskQuestionDetails)
    {
        
        NSArray *tempArray = [response objectForKey:@"data"];
        
        NSArray *arrTempReply = [tempArray valueForKey:@"replies"];

        
        [arrTempReply enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            QuestionDetail  *quesDetail =[[QuestionDetail alloc] init];
            quesDetail.answer = [tempDic objectForKey:@"answer"];
            quesDetail.quetionDetails = [tempDic objectForKey:@"question"];
            quesDetail.name = [tempDic objectForKey:@"member_name"];
            quesDetail.imageUrl  = [tempDic objectForKey:@"member_picture"];
            quesDetail.checkReplyHelpfull = [[tempDic valueForKey:@"question_reply_is_helpful"]boolValue];
            quesDetail.checkReplyLike = [[tempDic valueForKey:@"question_reply_is_like"]boolValue];
            quesDetail.questionReplyID = [tempDic valueForKey:@"question_reply_id"];
            quesDetail.isQuestionReplyReported = [[tempDic valueForKey:@"question_answer_is_reported"] boolValue];
            quesDetail.answerTime = [tempDic objectForKey:@"question_answer_time"];
            quesDetail.answerMemberID = [tempDic objectForKey:@"answer_member_id"];
            quesDetail.isSelfQuestion = [[tempDic objectForKey:@"question_answer_self"]boolValue];
            quesDetail.getQuestionId  = [tempDic objectForKey:@"question_id"];
            if ([tempDic hasValueForKey:@"member_tagged"]) {
                quesDetail.memberTagsArray = [tempDic objectForKey:@"member_tagged"];
            }
            
            DLog(@"string tag value %@",quesDetail.memberTagsArray);

            [commonArray addObject:quesDetail];
        }];
    }
    
    else if (task == kTaskHelpfulAnswer)
     {
        
        NSArray *tempArray = [response objectForKey:@"data"];
        
        NSArray *arrTempReply = [tempArray valueForKey:@"replies"];
        
        
        [arrTempReply enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            DLog(@"Temp dictionary data %@",tempDic);
            
            HelpfulAnswer *helpful = [[HelpfulAnswer alloc] init];
            helpful.answer = [tempDic objectForKey:@"answer"];
            helpful.name  = [tempDic objectForKey:@"member_name"];
            helpful.imageUrl = [tempDic objectForKey:@"member_picture"];
            helpful.addedQuestionMemberID = [tempDic objectForKey:@"answer_member_id"];
            
            if ([tempDic hasValueForKey:@"member_tagged"]) {
                helpful.memberTagsArray = [tempDic objectForKey:@"member_tagged"];
            }
            DLog(@"string tag value %@",helpful.memberTagsArray);
           [commonArray addObject:helpful];
        }];
    }
    
 else if (task == kTaskReplyQuestion)
     {
        NSArray *tempArray = [response objectForKey:@"data"];
        
        NSArray *arrTempReply = [tempArray valueForKey:@"replies"];
        
        
        [arrTempReply enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            ReplyQuestion *reply = [[ReplyQuestion alloc] init];
            reply.answer = [tempDic objectForKey:@"answer"];
            reply.name   = [tempDic objectForKey:@"member_name"];
            reply.imageUrl = [tempDic objectForKey:@"member_picture"];
            reply.addedQuestionMemberID = [tempDic objectForKey:@"answer_member_id"];
            
            if ([tempDic hasValueForKey:@"member_tagged"]) {
                reply.memberTagsArray = [tempDic objectForKey:@"member_tagged"];
             }
            
            DLog(@"string tag value %@",reply.memberTagsArray);

         [commonArray addObject:reply];
            
        }];
    }
    
    else if (task == kTaskFindProvider)
    {
        NSArray *tempArray = [response objectForKey:@"data"];
        
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            FindProvider *provider   = [[FindProvider alloc] init];
            provider.providerName  = [tempDic objectForKey:@"provider_name"];
            provider.providerCategory = [tempDic objectForKey:@"provider_category"];
            provider.providerDescription = [tempDic objectForKey:@"provider_description"];
            provider.providerRating  = [tempDic objectForKey:@"provider_rating"];
            provider.userId = [tempDic objectForKey:@"add_member_id"];
            provider.checkInCircle = [[tempDic objectForKey:@"provider_incirle"]boolValue];
            provider.providerId = [tempDic objectForKey:@"provider_id"];
            provider.providerServices = [tempDic valueForKey:@"provider_services"];
            provider.isSelfProvider = [[tempDic valueForKey:@"is_self_provider"] boolValue];

            [commonArray addObject:provider];
            
        }];
    }
    
    
    else if (task == kTaskFindProviderDetail)
    {
        NSArray *tempArray = [response objectForKey:@"data"];
        NSArray *recentReviewArray = [[tempArray valueForKey:@"recent_reviews"]objectAtIndex:0];
       self.providerService = [[tempArray valueForKey:@"provider_services"]objectAtIndex:0];
        
        
        [recentReviewArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            ProviderDetail *provider = [[ProviderDetail alloc] init];
            provider.Providername  = [tempDic objectForKey:@"provider_name"];
            provider.serviceRating = [tempDic objectForKey:@"service_rating"];
            provider.serviceName   = [self.providerService valueForKey:@"service_name"];
            provider.reviewDetail  = [tempDic objectForKey:@"service_review_text"];
            provider.reviewMemberImage = [tempDic objectForKey:@"member_image"];
            provider.reviewMemberName = [tempDic objectForKey:@"member_name"];
            [commonArray addObject:provider];
        }];
    }
    else if (task == kTaskParseProviderServices)
    {
        NSArray *tempArray = [response objectForKey:@"data"];
        NSArray *providerServiceArray = [[tempArray valueForKey:@"provider_services"]objectAtIndex:0];
        [providerServiceArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            ProviderServices *providerServices   = [[ProviderServices alloc] init];
            providerServices.serviceName  = [tempDic objectForKey:@"service_name"];
            providerServices.serviceID = [tempDic objectForKey:@"service_id"];
            [commonArray addObject:providerServices];
        }];
    }
    
    else if (task == kTaskShowReview)
    {
        NSArray *tempArray = [response objectForKey:@"data"];
      
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            ViewReview *review = [[ViewReview alloc]init];
            review.name = [tempDic objectForKey:@"member_name"];
            review.rating = [tempDic objectForKey:@"service_rating"];
            review.reviewText = [tempDic objectForKey:@"service_review_text"];
            review.serviceId  = [tempDic objectForKey:@"service_id"];
            review.reviewId   = [tempDic objectForKey:@"service_review_id"];
            review.isSelfReview = [[tempDic objectForKey:@"is_self"]boolValue];;
            [commonArray addObject:review];
        }];
    }

  else if (task == kTaskGetActivityDetailById)
    {
        NSArray *dataArray = [response objectForKey:@"data"];

        NSArray *tempArray = [[dataArray valueForKey:@"activity_comments"]objectAtIndex:0];
 
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop) {
            
            ActivityDetails  *activityDetails = [[ActivityDetails alloc] init];
            activityDetails.commentUserName  = [tempDic objectForKey:@"member_name"];
            activityDetails.commentUserImageUrl = [tempDic objectForKey:@"member_picture"];
            activityDetails.activityCommentID = [tempDic objectForKey:@"activity_comment_id"];
            activityDetails.commentTime = [tempDic objectForKey:@"comment_activity_time"];
            activityDetails.commentText = [tempDic objectForKey:@"member_activity_text"];
            activityDetails.activityCommentMemberID = [tempDic objectForKey:@"activity_comment_member_id"];
            activityDetails.isActivityCommentLiked = [[tempDic objectForKey:@"activity_comment_like"] boolValue];
            activityDetails.isSelfActivityComment = [[tempDic objectForKey:@"activity_comment_self"] boolValue];
            if ([tempDic hasValueForKey:@"activity_like_count"]) {
                activityDetails.likeCount = [tempDic objectForKey:@"activity_like_count"];
            }
            if ([tempDic hasValueForKey:@"activity_hug_count"]) {
                activityDetails.hugCount = [tempDic objectForKey:@"activity_hug_count"];
            }
            if ([tempDic hasValueForKey:@"member_tagged"]) {
                activityDetails.tagsArray = [tempDic objectForKey:@"member_tagged"];
            }

            [commonArray addObject:activityDetails];
        }];
}
    else if (task == kTaskProviderInCircle)
    {
        NSArray *tempArray = [response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop)
         {
             ProviderInCircle *providerObj = [[ProviderInCircle alloc]init];
             providerObj.city = [tempDic objectForKey:@"provider_city"];
             providerObj.address  = [tempDic objectForKey:@"provider_address"];
             providerObj.categoryName = [tempDic objectForKey:@"provider_category_name"];
             providerObj.phoneNumber = [tempDic objectForKey:@"provider_phone_no"];
             providerObj.rating = [tempDic objectForKey:@"provider_rating"];
             providerObj.name = [tempDic objectForKey:@"provider_name"];
             providerObj.services = [tempDic objectForKey:@"provider_services"];
             providerObj.zipcode = [tempDic objectForKey:@"provider_zipcode"];
             providerObj.providerId = [tempDic objectForKey:@"provider_id"];
             providerObj.isProviderInCircle = [[tempDic objectForKey:@"provider_incirle"] boolValue];

             [commonArray addObject:providerObj];

         }];
    }
    
    else if (task == kTaskGetFamilyList)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            MemberInFamily *familyMember = [MemberInFamily new];
            
            if ([tempDic hasValueForKey:@"member_kid_age"]) {
                familyMember.age = [tempDic objectForKey:@"member_kid_age"];
            }
            if ([tempDic hasValueForKey:@"member_kid_detail"]) {
                familyMember.detail = [tempDic objectForKey:@"member_kid_detail"];
            }
            if ([tempDic hasValueForKey:@"member_kid_gender"]) {
                familyMember.gender = [tempDic objectForKey:@"member_kid_gender"];
            }
            if ([tempDic hasValueForKey:@"member_kid_image"]) {
                familyMember.image = [tempDic objectForKey:@"member_kid_image"];
            }
            if ([tempDic hasValueForKey:@"member_kid_name"]) {
                familyMember.name = [tempDic objectForKey:@"member_kid_name"];
            }
            if ([tempDic hasValueForKey:@"member_kid_is_self"]) {
                 familyMember.isSelf = [[tempDic objectForKey:@"member_kid_is_self"]boolValue];
            }
            if ([tempDic hasValueForKey:@"member_kid_is_reported"]) {
                familyMember.isAlreadyReported = [[tempDic objectForKey:@"member_kid_is_reported"]boolValue] ;
            }
            if ([tempDic hasValueForKey:@"kid_behaviours"]) {
                familyMember.behaviourArray = [tempDic objectForKey:@"kid_behaviours"];
            }
            if ([tempDic hasValueForKey:@"kid_diagnosis"]) {
                familyMember.diagnosisArray = [tempDic objectForKey:@"kid_diagnosis"];
            }
            if ([tempDic hasValueForKey:@"kid_relation"]) {
                familyMember.relationArray = [tempDic objectForKey:@"kid_relation"];
            }
            if ([tempDic hasValueForKey:@"kid_treatments"]) {
                familyMember.treatmentArray = [tempDic objectForKey:@"kid_treatments"];
            }
           /*( if ([tempDic hasValueForKey:@"diagnosis_month"]) {
                familyMember.month = [tempDic objectForKey:@"diagnosis_month"];
            } else
            {
                familyMember.month = nil;
            }*/
            familyMember.month = [tempDic hasValueForKey:@"diagnosis_month"] ? [tempDic objectForKey:@"diagnosis_month"] : nil;

            if ([tempDic hasValueForKey:@"diagnosis_year"]) {
                familyMember.year = [tempDic objectForKey:@"diagnosis_year"];
               // DLog(@"familyMember.year:%@ \n server:%@",familyMember.year, [tempDic objectForKey:@"diagnosis_year"]);
            }
            if ([tempDic hasValueForKey:@"kid_bday_date"]) {
                familyMember.bdaydate = [tempDic objectForKey:@"kid_bday_date"];
            }
            if ([tempDic hasValueForKey:@"kid_id"]) {
                familyMember.kidId = [tempDic objectForKey:@"kid_id"];
            }
            [commonArray addObject:familyMember];
        }];
    }
    else if (task == kTaskGetBehaviour)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            __block BOOL isSkip = NO;
            Behaviour *behaviour = [Behaviour new];
            
            if ([tempDic hasValueForKey:@"name"]) {
                behaviour.behaviourCategoryName = [tempDic objectForKey:@"name"];
            }
            behaviour.behaviourArray = [[NSMutableArray alloc]init];
            if ([tempDic hasValueForKey:@"value"]) {
                NSArray *valueArray =[tempDic objectForKey:@"value"];
                [valueArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
                    
                    NSString *subId= [tempDic objectForKey:@"sub_id"];
                    if (![subId isEqualToString:@"35"]) {
                        NSString *subName = [tempDic objectForKey:@"sub_name"];
                        NSDictionary *nameAndIDDict = [[NSDictionary alloc] initWithObjectsAndKeys:subId, @"behaviour_id", subName, @"behaviour_name", nil];
                        [behaviour.behaviourArray addObject:nameAndIDDict];
                    }
                    
                    ///////
                        if ([tempDic hasValueForKey:@"sub_category"]) {
                            if (!isSkip) {
                                [commonArray addObject:behaviour];
                            }
                            isSkip = YES;
                            Behaviour *subCatBehaviour = [Behaviour new];
                            subCatBehaviour.behaviourArray = [[NSMutableArray alloc]init];
                            if ([tempDic hasValueForKey:@"sub_name"]) {
                                subCatBehaviour.behaviourCategoryName = [tempDic objectForKey:@"sub_name"];
                            }
                            NSArray *subCategoryArray =[tempDic objectForKey:@"sub_category"];
                            [subCategoryArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
                                
                                NSString *subId= [tempDic objectForKey:@"sub_category_id"];
                                NSString *subName = [tempDic objectForKey:@"sub_category_subname"];
                                NSDictionary *nameAndIDDict = [[NSDictionary alloc] initWithObjectsAndKeys:subId, @"behaviour_id", subName, @"behaviour_name", nil];
                                [subCatBehaviour.behaviourArray addObject:nameAndIDDict];
                            }];
                            [commonArray addObject:subCatBehaviour];
                        }//////////
                }];
            }
            if (!isSkip) {
                [commonArray addObject:behaviour];
            }
            
        }];
    }
    else if (task == kTaskInboxMemberList)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            MessageInInbox *inbox = [MessageInInbox new];
            
            if ([tempDic hasValueForKey:@"member_id"]) {
                inbox.memberId = [tempDic objectForKey:@"member_id"];
            }
            if ([tempDic hasValueForKey:@"member_name"]) {
                inbox.name = [tempDic objectForKey:@"member_name"];
            }
            if ([tempDic hasValueForKey:@"message_last_message"]) {
                inbox.lastMessage = [tempDic objectForKey:@"message_last_message"];
            }
            if ([tempDic hasValueForKey:@"member_image"]) {
                inbox.imageUrl = [tempDic objectForKey:@"member_image"];
            }if ([tempDic hasValueForKey:@"is_reported"]) {
                inbox.isReported = [[tempDic objectForKey:@"is_reported"] boolValue];
              }
            if ([tempDic hasValueForKey:@"is_record"]) {
                inbox.isMessageRecord = [[tempDic objectForKey:@"is_record"] boolValue];
               }

            
            [commonArray addObject:inbox];
        }];
    }
    
    else if (task == kTaskInboxSearchMember)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            MessageSearch *inbox = [MessageSearch new];
            
            if ([tempDic hasValueForKey:@"id"]) {
                inbox.memberId = [tempDic objectForKey:@"id"];
            }
            if ([tempDic hasValueForKey:@"name"]) {
                inbox.memberName = [tempDic objectForKey:@"name"];
            }
            if ([tempDic hasValueForKey:@"avatar"]) {
                inbox.memberImageUrl = [tempDic objectForKey:@"avatar"];
            }
          [commonArray addObject:inbox];
        }];
    }

    else if (task == kTaskEventAndCalendar)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            EventCountOnMonth *eventCount = [EventCountOnMonth new];
            
            if ([tempDic hasValueForKey:@"event_date"]) {
                eventCount.eventDate = [tempDic objectForKey:@"event_date"];
            }
            if ([tempDic hasValueForKey:@"event_total"]) {
                eventCount.totalEvent = [tempDic objectForKey:@"event_total"];
            }
            [commonArray addObject:eventCount];
        }];
    }
    else if (task == kTaskGetMemberContact)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            ContactInCircle *contact = [ContactInCircle new];
            
            if ([tempDic hasValueForKey:@"member_id"]) {
                contact.memberId = [tempDic objectForKey:@"member_id"];
            }
            if ([tempDic hasValueForKey:@"member_name"]) {
                contact.name = [tempDic objectForKey:@"member_name"];
            }
            [commonArray addObject:contact];
        }];
    }
    else if (task == kTaskGetMessageConversation)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            InboxDetailMessage *inboxDetail = [InboxDetailMessage new];
            
            if ([tempDic hasValueForKey:@"member_image"]) {
                inboxDetail.memberImageUrl = [tempDic objectForKey:@"member_image"];
            }
            if ([tempDic hasValueForKey:@"member_message_image_attach_link"]) {
                inboxDetail.attachLinkImageUrl = [tempDic objectForKey:@"member_message_image_attach_link"];
            }
            if ([tempDic hasValueForKey:@"member_message_link"]) {
                inboxDetail.attachLinkUrl = [tempDic objectForKey:@"member_message_link"];
            }
            if ([tempDic hasValueForKey:@"member_name"]) {
                inboxDetail.name = [tempDic objectForKey:@"member_name"];
            }
            if ([tempDic hasValueForKey:@"message"]) {
                inboxDetail.message = [tempDic objectForKey:@"message"];
            }
            if ([tempDic hasValueForKey:@"message_id"]) {
                inboxDetail.messageId = [tempDic objectForKey:@"message_id"];
            }
            if ([tempDic hasValueForKey:@"message_images"]) {
                inboxDetail.imagesArray = [tempDic objectForKey:@"message_images"];
                 //DLog(@"Images : %@",inboxDetail.imagesArray);
            }
            if ([tempDic hasValueForKey:@"message_member_id"]) {
                inboxDetail.memberId = [tempDic objectForKey:@"message_member_id"];
            }
            if ([tempDic hasValueForKey:@"message_video_link"]) {
                inboxDetail.videoLink = [tempDic objectForKey:@"message_video_link"];
             }
            
            [commonArray addObject:inboxDetail];
        
        }];
        
    }
    else if (task == kTaskGetNotificationList)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            Notification *notification = [Notification new];
            
            if ([tempDic hasValueForKey:@"notification_id"]) {
                notification.notificationId = [tempDic objectForKey:@"notification_id"];
            }
            
            if ([tempDic hasValueForKey:@"notification_key_pair"]) {
                NSDictionary *notificationKeyPair = [tempDic objectForKey:@"notification_key_pair"];
                if ([notificationKeyPair hasValueForKey:@"key1"]) {
                    NSDictionary *notificationKey1 = [notificationKeyPair objectForKey:@"key1"];
                    if ([notificationKey1 hasValueForKey:@"user_id"]) {
                        notification.userID = [notificationKey1 objectForKey:@"user_id"];
                    }
                    if ([notificationKey1 hasValueForKey:@"user_name"]) {
                        notification.userName = [notificationKey1 objectForKey:@"user_name"];
                    }
                }
                if ([notificationKeyPair hasValueForKey:@"key2"]) {
                    NSDictionary *notificationkey2 = [notificationKeyPair objectForKey:@"key2"];
                    if ([notificationkey2 hasValueForKey:@"id"]) {
                        notification.notificationTypeID = [notificationkey2 objectForKey:@"id"];
                    }
                    if ([notificationkey2 hasValueForKey:@"name"]) {
                        notification.notificationKey2 = [notificationkey2 objectForKey:@"name"];
                    }
                }
                if ([notificationKeyPair hasValueForKey:@"key3"]) {
                    NSDictionary *notificationkey3 = [notificationKeyPair objectForKey:@"key3"];
                    if ([notificationkey3 hasValueForKey:@"id"]) {
                        notification.notificationKey3ID = [notificationkey3 objectForKey:@"id"];
                    }
                    if ([notificationkey3 hasValueForKey:@"name"]) {
                        notification.notificationKey3 = [notificationkey3 objectForKey:@"name"];
                    }
                }
                if ([notificationKeyPair hasValueForKey:@"key4"]) {
                    NSDictionary *notificationkey4 = [notificationKeyPair objectForKey:@"key4"];
                    if ([notificationkey4 hasValueForKey:@"id"]) {
                        notification.notificationKey4ID = [notificationkey4 objectForKey:@"id"];
                    }
                    if ([notificationkey4 hasValueForKey:@"name"]) {
                        notification.notificationKey4 = [notificationkey4 objectForKey:@"name"];
                    }
                }
            }
            if ([tempDic hasValueForKey:@"notification_text"]) {
                notification.notificationText = [tempDic objectForKey:@"notification_text"];
            }
            if ([tempDic hasValueForKey:@"notification_time"]) {
                notification.notificationTime = [tempDic objectForKey:@"notification_time"];
            }
            if ([tempDic hasValueForKey:@"notification_type"]) {
                notification.notificationType = [tempDic objectForKey:@"notification_type"];
            }
            [commonArray addObject:notification];
        }];
    }
    else if (task == kTaskGetMemberList)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            Member *member = [Member new];
            if ([tempDic hasValueForKey:@"avatar"]) {
                member.avatar = [tempDic objectForKey:@"avatar"];
            }
            if ([tempDic hasValueForKey:@"id"]) {
                member.memberId = [tempDic objectForKey:@"id"];
            }
            if ([tempDic hasValueForKey:@"name"]) {
                member.name = [tempDic objectForKey:@"name"];
            }
            [commonArray addObject:member];
        }];
    }
    else if (task == kTaskAlbumList)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            AlbumList *album = [AlbumList new];
            if ([tempDic hasValueForKey:@"album_cover_image"]) {
                album.albumCover = [tempDic objectForKey:@"album_cover_image"];
            }
            if ([tempDic hasValueForKey:@"album_id"]) {
                album.albumId = [tempDic objectForKey:@"album_id"];
            }
            if ([tempDic hasValueForKey:@"album_name"]) {
                album.albumName = [tempDic objectForKey:@"album_name"];
            }
            if ([tempDic hasValueForKey:@"is_default_album"]) {
                album.isDefaultAlbum = [[tempDic objectForKey:@"is_default_album"] boolValue];
            }
            if ([tempDic hasValueForKey:@"is_self_album"]) {
                album.isSelfAlbum = [[tempDic objectForKey:@"is_self_album"] boolValue];
            }
            if ([tempDic hasValueForKey:@"album_picture_count"]) {
                album.pictureCount = [tempDic objectForKey:@"album_picture_count"];
            }
            [commonArray addObject:album];
        }];
    }
    else if (task == kTaskPictureInAlbum)
    {
        NSArray *tempArray =[response objectForKey:@"data"];
        [tempArray enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL *stop){
            
            PicturesInAlbum *album = [PicturesInAlbum new];
            if ([tempDic hasValueForKey:@"album_is_cover_image"]) {
                album.isCoverImage = [tempDic objectForKey:@"album_is_cover_image"];
            }
            if ([tempDic hasValueForKey:@"album_picture"]) {
                album.pictureUrl = [tempDic objectForKey:@"album_picture"];
            }
            if ([tempDic hasValueForKey:@"album_picture_caption"]) {
                album.pictureCaption = [tempDic objectForKey:@"album_picture_caption"];
            }
            if ([tempDic hasValueForKey:@"album_picture_id"]) {
                album.PictureId = [tempDic objectForKey:@"album_picture_id"];
            }
            if ([tempDic hasValueForKey:@"is_self_album_picture"]) {
                album.isSelfAlbumPicture = [tempDic objectForKey:@"is_self_album_picture"];
            }
            [commonArray addObject:album];
        }];
    }



    else{
        return response;
    }
    return commonArray;
}


@end
