//
//  STTweetLabel.m
//  STTweetLabel
//
//  Created by Sebastien Thiebaud on 09/29/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

#import "STTweetLabel.h"
#import "STTweetTextStorage.h"
#import "Utility.h"
#import "NSDictionary+HasValueForKey.h"

#define STURLRegex @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

#pragma mark -
#pragma mark STTweetLabel

@interface STTweetLabel () <UITextViewDelegate>

@property (strong) STTweetTextStorage *textStorage;
@property (strong) NSLayoutManager *layoutManager;
@property (strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSString *cleanText;

@property (strong) NSMutableArray *rangesOfHotWords;

@property (nonatomic, strong) NSDictionary *attributesText;
@property (nonatomic, strong) NSDictionary *attributesHandle;
@property (nonatomic, strong) NSDictionary *attributesHashtag;
@property (nonatomic, strong) NSDictionary *attributesLink;
@property (nonatomic, strong) NSDictionary *attributesNotification;

@property (nonatomic, strong)  NSString *hotWordID;

@property (strong) UITextView *textView;

- (void)setupLabel;
- (void)determineHotWords;
- (void)determineLinks;
- (void)updateText;

@end

@implementation STTweetLabel {
    BOOL _isTouchesMoved;
    NSRange _selectableRange;
    int _firstCharIndex;
    CGPoint _firstTouchLocation;
}

#pragma mark -
#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupLabel];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupLabel];
}

#pragma mark -
#pragma mark Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:[_cleanText substringWithRange:_selectableRange]];
    
    @try {
        [_textStorage removeAttribute:NSBackgroundColorAttributeName range:_selectableRange];
    } @catch (NSException *exception) {
    }
}

#pragma mark -
#pragma mark Setup

- (void)setupLabel {
  //Initialize task perform here thing.....
}

- (void)setupFontColorOfHashTag {
    if ([self.callerView isEqualToString:kTitleNotifications]) {
        _attributesHashtag = @{NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0f green:36/255.0f blue:137/255.0f alpha:1.0f], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
        _attributesNotification = @{NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0f green:36/255.0f blue:137/255.0f alpha:1.0f], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
        
    }else {
        _attributesHashtag = @{NSForegroundColorAttributeName: [UIColor colorWithRed:44/255.0f green:173/255.0f blue:182/255.0f alpha:1.0f], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
        _attributesNotification = @{NSForegroundColorAttributeName: [UIColor colorWithRed:44/255.0f green:173/255.0f blue:182/255.0f alpha:1.0f], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
    }
    
    _attributesLink = @{NSForegroundColorAttributeName: [[UIColor alloc] initWithRed:129.0/255.0 green:171.0/255.0 blue:193.0/255.0 alpha:1.0], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14.0]};
    
    self.validProtocols = @[@"http", @"https"];
}

#pragma mark -
#pragma mark Printing and calculating text

- (void)determineHotWords {

    if (_cleanText == nil)
        return;
    
    _textStorage = [[STTweetTextStorage alloc] init];
    _layoutManager = [[NSLayoutManager alloc] init];
    
    NSMutableString *tmpText = [[NSMutableString alloc] initWithString:_cleanText];
    
    // Support RTL
    if (!_leftToRight) {
        tmpText = [[NSMutableString alloc] init];
        [tmpText appendString:@"\u200F"];
        [tmpText appendString:_cleanText];
    }
    
    _rangesOfHotWords = [[NSMutableArray alloc] init];
    
    if ([self.callerView isEqualToString:kTitleNotifications]) {
        [self determineHotWordsForNotification];
    } else if ([self.callerView isEqualToString:kCallerViewActivity]) {
        [self determineHotWordsInString:self.getMyActivity.detail replaceWithTagID:self.getMyActivity.tagsArray];
        
       // DLog(@"activity value %@  , %@",self.getMyActivity.detail,self.getMyActivity.tagsArray);
        
    }else if ([self.callerView isEqualToString:kCallerViewQA]) {
        [self determineHotWordsInString:self.question.quetionDetails replaceWithTagID:self.question.memberTagsArray];
        
        // DLog(@"%s_______> \n question value %@  ,\n memberTagsArray: %@",__FUNCTION__,self.question.quetionDetails,self.question.memberTagsArray);
        
    }
    
    else if ([self.callerView isEqualToString:kCallerViewMyQA]) {
        [self determineHotWordsInString:self.myQuestion.quetionDetails replaceWithTagID:self.myQuestion.memberTagsArray];
        
        //DLog(@"question value %@  , %@",self.myQuestion.quetionDetails,self.myQuestion.memberTagsArray);
    }
    
    else if ([self.callerView isEqualToString:kCallerViewQADetail]) {
        [self determineHotWordsInString:self.questionDetail.quetionDetails replaceWithTagID:self.questionDetail.memberTagsArray];
        
       // DLog(@"question value %@  , %@",self.questionDetail.quetionDetails,self.questionDetail.memberTagsArray);
    }

    

    else if ([self.callerView isEqualToString:kCallerViewHelpful]) {
        [self determineHotWordsInString:self.helpfulQuestion.answer replaceWithTagID:self.helpfulQuestion.memberTagsArray];
        
       // DLog(@"question value %@  , %@",self.helpfulQuestion.answer,self.helpfulQuestion.memberTagsArray);
    }
    else if ([self.callerView isEqualToString:kCallerViewReply]) {
        [self determineHotWordsInString:self.replyQuestion.answer replaceWithTagID:self.replyQuestion.memberTagsArray];
    
    }
    
    else if ([self.callerView isEqualToString:kCallerViewQADetailHeader]) {
        [self determineHotWordsInString:self.qaDetail replaceWithTagID:self.QATagArray];
        // DLog(@"question value %@  , %@",self.qaDetail,self.QATagArray);
        
    }
    
    else if ([self.callerView isEqualToString:kCallerViewActivityDetail]) {
        [self determineHotWordsInString:self.acttivityDetail.commentText replaceWithTagID:self.acttivityDetail.tagsArray];
        
    }
    
    else if ([self.callerView isEqualToString:kCallerViewActivityDetailHeader]) {
        [self determineHotWordsInString:self.activityDetail replaceWithTagID:self.ActivityTagArray];
       // DLog(@"question value %@  , %@",self.qaDetail,self.QATagArray);
        
    }
    
 else if ([self.callerView isEqualToString:kCallerViewEventDetail]) {
        [self determineHotWordsInString:self.eventDetail replaceWithTagID:nil];
      //  DLog(@"question value %@",self.eventDetail);
        
    }

    
     [self determineLinks];
     [self updateText];
}

- (void)determineLinks {
    NSMutableString *tmpText = [[NSMutableString alloc] initWithString:_cleanText];

    NSError *regexError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:STURLRegex options:0 error:&regexError];

    [regex enumerateMatchesInString:tmpText options:0 range:NSMakeRange(0, tmpText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *protocol = @"http";
        NSString *link = [tmpText substringWithRange:result.range];
        NSRange protocolRange = [link rangeOfString:@"://"];
        if (protocolRange.location != NSNotFound) {
            protocol = [link substringToIndex:protocolRange.location];
        }

        if ([_validProtocols containsObject:protocol.lowercaseString]) {
            [_rangesOfHotWords addObject:@{@"hotWord": @(STTweetLink), @"protocol": protocol, @"range": [NSValue valueWithRange:result.range]}];
        }
    }];
}

- (void)updateText
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_cleanText];
    [attributedString setAttributes:_attributesText range:NSMakeRange(0, _cleanText.length)];
    
    for (NSDictionary *dictionary in _rangesOfHotWords)  {
        NSRange range = [[dictionary objectForKey:@"range"] rangeValue];
        STTweetHotWord hotWord = (STTweetHotWord)[[dictionary objectForKey:@"hotWord"] intValue];
        [attributedString setAttributes:[self attributesForHotWord:hotWord] range:range];
        //Set Backgorund color of hot words.
        //[attributedString addAttribute: NSBackgroundColorAttributeName value: [UIColor yellowColor] range: range];
    }
    
    [_textStorage appendAttributedString:attributedString];
    
    _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    [_layoutManager addTextContainer:_textContainer];
    [_textStorage addLayoutManager:_layoutManager];

    if (_textView != nil)
        [_textView removeFromSuperview];
    
    _textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:_textContainer];
    _textView.delegate = self;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textContainer.lineFragmentPadding = 0;
    _textView.textContainerInset = UIEdgeInsetsZero;
    _textView.userInteractionEnabled = NO;
    
    
   /* DLog(@"------Frame:%@",NSStringFromCGRect(self.frame));
    DLog(@"NofoLines:%f",ceil(_textView.frame.size.height
                               / _textView.font.lineHeight));*/
    int noOfLine = ceil(_textView.frame.size.height
                        / _textView.font.lineHeight);
    
    if (noOfLine > 4 && noOfLine < 15) {
        [_textView setFont:[UIFont systemFontOfSize:13.3]];
    }else if (noOfLine > 14)
    {
        [_textView setFont:[UIFont systemFontOfSize:13.4]];
    }
    [_textView sizeToFit];
    //DLog(@"++++++++++TextViewText:%@\n ++++++++++++++++++",_textView.text);
    
    [self addSubview:_textView];
}

#pragma mark -
#pragma mark Public methods

- (CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width {
    if (_cleanText == nil)
        return CGSizeZero;

    return [_textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
}

#pragma mark -
#pragma mark Private methods

- (NSArray *)hotWordsList {
    return _rangesOfHotWords;
}

#pragma mark -
#pragma mark Setters

- (void)setText:(NSString *)text {
    [super setText:@""];
    _cleanText = text;
    [self determineHotWords];
}

- (void)setValidProtocols:(NSArray *)validProtocols {
    _validProtocols = validProtocols;
    [self determineHotWords];
}

- (void)setAttributes:(NSDictionary *)attributes {
    if (!attributes[NSFontAttributeName]) {
        NSMutableDictionary *copy = [attributes mutableCopy];
        copy[NSFontAttributeName] = self.font;
        attributes = [NSDictionary dictionaryWithDictionary:copy];
    }
    
    if (!attributes[NSForegroundColorAttributeName]) {
        NSMutableDictionary *copy = [attributes mutableCopy];
        copy[NSForegroundColorAttributeName] = self.textColor;
        attributes = [NSDictionary dictionaryWithDictionary:copy];
    }

    _attributesText = attributes;
    
    [self determineHotWords];
}

- (void)setAttributes:(NSDictionary *)attributes hotWord:(STTweetHotWord)hotWord {
    if (!attributes[NSFontAttributeName]) {
        NSMutableDictionary *copy = [attributes mutableCopy];
        copy[NSFontAttributeName] = self.font;
        attributes = [NSDictionary dictionaryWithDictionary:copy];
    }
    
    if (!attributes[NSForegroundColorAttributeName]) {
        NSMutableDictionary *copy = [attributes mutableCopy];
        copy[NSForegroundColorAttributeName] = self.textColor;
        attributes = [NSDictionary dictionaryWithDictionary:copy];
    }
    
    switch (hotWord)  {
        case STTweetHandle:
            _attributesHandle = attributes;
            break;
        case STTweetHashtag:
            _attributesHashtag = attributes;
            break;
        case STTweetLink:
            _attributesLink = attributes;
            break;
        case STTweetNotificationType:
            _attributesNotification = attributes;
            break;
            
        default:
            break;
    }
    
    [self determineHotWords];
}

- (void)setLeftToRight:(BOOL)leftToRight {
    _leftToRight = leftToRight;

    [self determineHotWords];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    _textView.textAlignment = textAlignment;
}

- (void)setDetectionBlock:(void (^)(STTweetHotWord, NSString *, NSString *, NSString *, NSRange))detectionBlock {
    if (detectionBlock) {
        _detectionBlock = [detectionBlock copy];
        self.userInteractionEnabled = YES;
    } else {
        _detectionBlock = nil;
        self.userInteractionEnabled = NO;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    self.text = attributedText.string;
    if (self.text.length > 0) {
        [self setAttributes:[attributedText attributesAtIndex:0 effectiveRange:NULL]];
    }
}

#pragma mark -
#pragma mark Getters

- (NSString *)text {
    return _cleanText;
}

- (NSDictionary *)attributes {
    return _attributesText;
}

- (NSDictionary *)attributesForHotWord:(STTweetHotWord)hotWord {
    switch (hotWord) {
        case STTweetHandle:
            return _attributesHandle;
            break;
        case STTweetHashtag:
            return _attributesHashtag;
            break;
        case STTweetLink:
            return _attributesLink;
            break;
        case STTweetNotificationType:
            return _attributesNotification;
            break;
        default:
            break;
    }
}

- (BOOL)isLeftToRight {
    return _leftToRight;
}

#pragma mark -
#pragma mark Retrieve word after touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(![self getTouchedHotword:touches]) {
        [super touchesBegan:touches withEvent:event];
    }
    
    _isTouchesMoved = NO;
    
    @try {
        [_textStorage removeAttribute:NSBackgroundColorAttributeName range:_selectableRange];
    } @catch (NSException *exception) {
    }
    
    _selectableRange = NSMakeRange(0, 0);
    _firstTouchLocation = [[touches anyObject] locationInView:_textView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([self getTouchedHotword:touches] == nil) {
        [super touchesMoved:touches withEvent:event];
    }
    
    if (!_textSelectable) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setMenuVisible:NO animated:YES];
        
        return;
    }
    
    _isTouchesMoved = YES;
    
    int charIndex = [self charIndexAtLocation:[[touches anyObject] locationInView:_textView]];
    
    @try {
        [_textStorage removeAttribute:NSBackgroundColorAttributeName range:_selectableRange];
    } @catch (NSException *exception) {
    }
    
    if (_selectableRange.length == 0) {
        _selectableRange = NSMakeRange(charIndex, 1);
        _firstCharIndex = charIndex;
    } else if (charIndex > _firstCharIndex) {
        _selectableRange = NSMakeRange(_firstCharIndex, charIndex - _firstCharIndex + 1);
    } else if (charIndex < _firstCharIndex) {
        _firstTouchLocation = [[touches anyObject] locationInView:_textView];
        
        _selectableRange = NSMakeRange(charIndex, _firstCharIndex - charIndex);
    }
    
    @try {
        [_textStorage addAttribute:NSBackgroundColorAttributeName value:_selectionColor range:_selectableRange];
    } @catch (NSException *exception) {
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];

    if (_isTouchesMoved) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:CGRectMake(_firstTouchLocation.x, _firstTouchLocation.y, 1.0, 1.0) inView:self];
        [menuController setMenuVisible:YES animated:YES];
        
        [self becomeFirstResponder];

        return;
    }
    
    if (!CGRectContainsPoint(_textView.frame, touchLocation))
        return;

    id touchedHotword = [self getTouchedHotword:touches];
    if(touchedHotword != nil) {
        NSRange range = [[touchedHotword objectForKey:@"range"] rangeValue];
        
        _detectionBlock((STTweetHotWord)[[touchedHotword objectForKey:@"hotWord"] intValue], [_cleanText substringWithRange:range], self.hotWordID,[touchedHotword objectForKey:@"protocol"], range);
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (NSUInteger)charIndexAtLocation:(CGPoint)touchLocation {
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:touchLocation inTextContainer:_textView.textContainer];
    CGRect boundingRect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:_textView.textContainer];
    
    if (CGRectContainsPoint(boundingRect, touchLocation))
        return [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    else
        return -1;
}

- (id)getTouchedHotword:(NSSet *)touches {
    NSUInteger charIndex = [self charIndexAtLocation:[[touches anyObject] locationInView:_textView]];
    
    for (id obj in _rangesOfHotWords) {
        NSRange range = [[obj objectForKey:@"range"] rangeValue];
        
          if (charIndex >= range.location && charIndex < range.location + range.length) {
              self.hotWordID = [obj objectForKey:@"hotWordID"];
            return obj;
        }
    }
    
    return nil;
}

//
-(void)determineHotWordsInString:(NSString *)commnentString replaceWithTagID:(NSArray *)tagArray{
    
   /* STTweetHotWord hotWord;
    hotWord = STTweetHashtag;
    NSRange range;
    NSString *userId;
    NSString *userIdWithAt;
    NSString *userName;

    NSString *activityDetailStr = self.getMyActivity.detail;
    DLog(@"-------activityDetailStr with @ID:%@",activityDetailStr);
    
    DLog(@"============member_tagged:%@",self.getMyActivity.tagsArray);
    for (NSDictionary *tagDict in self.getMyActivity.tagsArray) {
         if ([tagDict hasValueForKey:@"id"] && [tagDict hasValueForKey:@"name"]) {
            userId = [tagDict valueForKey:@"id"];
            userIdWithAt = [NSString stringWithFormat:@"@%@",userId];
            userName = [tagDict valueForKey:@"name"];
           
            _cleanText = [_cleanText stringByReplacingOccurrencesOfString:userIdWithAt
                                                                             withString:userName];
            range = [_cleanText rangeOfString:userName];
            [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": userId, @"range": [NSValue valueWithRange:range]}];
        }
        
       // DLog(@"-------activityDetailStr:%@",activityDetailStr);
    }*/
    
    
    
    STTweetHotWord hotWord;
    hotWord = STTweetHashtag;
    NSRange range;
    NSString *userId;
    NSString *userIdWithAt;
    NSString *userName;
    self.rangeArray = [NSMutableArray new];
   // DLog(@"-------commnentString with @ID:%@",commnentString);
    
    //DLog(@"============member_tagged:%@",tagArray);
    for (NSDictionary *tagDict in tagArray) {
        if ([tagDict hasValueForKey:@"id"] && [tagDict hasValueForKey:@"name"]) {
            userId = [tagDict valueForKey:@"id"];
            userIdWithAt = [NSString stringWithFormat:@"@%@",userId];
            userName = [tagDict valueForKey:@"name"];
            
            _cleanText = [_cleanText stringByReplacingOccurrencesOfString:userIdWithAt
                                                               withString:userName];
            range = [_cleanText rangeOfString:userName];
            [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": userId, @"range": [NSValue valueWithRange:range]}];
            [self.rangeArray addObject:@{@"range": [NSValue valueWithRange:range]}];
        }
        
       // DLog(@"-------commnentString after replacingwith Id:%@",_cleanText);
    }
    
}

- (void)determineHotWordsForNotification
{
    STTweetHotWord hotWord;
    hotWord = STTweetHashtag;
    NSRange range;
    NSString *userName = [Utility getValidString:self.notifcation.userName];
    _cleanText = [_cleanText stringByReplacingOccurrencesOfString:@"key1"
                                                       withString:userName];
    range = [_cleanText rangeOfString:userName];
    [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": self.notifcation.userID, @"range": [NSValue valueWithRange:range]}];
    
    NSString *notificationKey2 = [Utility getValidString:self.notifcation.notificationKey2];
    
    if ([_cleanText rangeOfString:@"key2"].location != NSNotFound) {
        _cleanText = [_cleanText stringByReplacingOccurrencesOfString:@"key2"
                                                           withString:notificationKey2];
        hotWord = STTweetNotificationType;
        range = [_cleanText rangeOfString:notificationKey2];
        
        [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": self.notifcation.notificationTypeID, @"range": [NSValue valueWithRange:range]}];
        
    }
    
    NSString *notificationKey3 = [Utility getValidString:self.notifcation.notificationKey3];
    
    if ([_cleanText rangeOfString:@"key3"].location != NSNotFound) {
        _cleanText = [_cleanText stringByReplacingOccurrencesOfString:@"key3"
                                                           withString:notificationKey3];
        hotWord = STTweetNotificationType;
        range = [_cleanText rangeOfString:notificationKey3];
        [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": self.notifcation.notificationKey3ID, @"range": [NSValue valueWithRange:range]}];
    }
    
    NSString *notificationKey4 = [Utility getValidString:self.notifcation.notificationKey4];
    
    if ([_cleanText rangeOfString:@"key4"].location != NSNotFound) {
        _cleanText = [_cleanText stringByReplacingOccurrencesOfString:@"key4"
                                                           withString:notificationKey4];
        hotWord = STTweetNotificationType;
        range = [_cleanText rangeOfString:notificationKey4];
        [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": self.notifcation.notificationKey4ID, @"range": [NSValue valueWithRange:range]}];
    }
    
    if ([Utility getValidString:self.notifcation.notificationTime].length > 0) {
        _cleanText = [_cleanText stringByAppendingString:[NSString stringWithFormat:@" (%@)", [Utility getValidString:self.notifcation.notificationTime]]];
    }
}
@end
