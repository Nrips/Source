//
//  CustomMyPeopleCell.m
//  Autism
//
//  Created by Neuron-iPhone on 3/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "CustomMyPeopleCell.h"

@implementation CustomMyPeopleCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (CustomMyPeopleCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    CustomMyPeopleCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[CustomMyPeopleCell class]]) {
            customCell = (CustomMyPeopleCell *)nibItem;
            break; // we have a winner
        }
    }
     customCell.myimag = [[MyImageView alloc]initWithFrame:CGRectMake(5,3,64,64)];
    [customCell.myimag setImage:[UIImage imageNamed:@"avatar-140.png"]];
    [customCell addSubview:customCell.myimag];
    return customCell;
}


-(void) configureCell:(MemberInCircle *)memberIncircle
{
    self.systemFont = [UIFont systemFontOfSize:13];
    
    [self.myimag configureImageForUrl:memberIncircle.userImage];
    [self.lblName setText:memberIncircle.name];
    [self.lblRole setText:memberIncircle.role];
    
    self.strAuthority = memberIncircle.locationAuth;
    self.strLocation  = memberIncircle.city;
    
    float  locationLabelWidth = [self calculateQADetailStringHeight:self.strAuthority];
 
    CGRect nameFrame = self.lblLocation.frame;
    nameFrame.size.width = locationLabelWidth;
    self.lblLocation.frame = nameFrame;
    
    CGRect frame = self.lblSeprater.frame;
    frame.origin.x = self.lblLocation.frame.origin.x + locationLabelWidth;
    self.lblSeprater.frame = frame;
    
    CGRect frame1 = self.lblCity.frame;
    frame1.origin.x = self.lblLocation.frame.origin.x + locationLabelWidth + MYCIRCLECELL_SEPRATOR + MYCIRCLECELL_SEPRATOR + MYCIRCLECELL_SEPRATOR + MYCIRCLECELL_SEPRATOR;
    self.lblCity.frame = frame1;
    
    
    [self.lblLocation setText:self.strAuthority];
    [self.lblCity setText:self.strLocation];
    
    self.imageURL = memberIncircle.userImage;
    self.userCity = memberIncircle.city;
    self.strUserKey =[memberIncircle otherUserKey];
    self.userId = memberIncircle.userId;
    self.locationAuthority = memberIncircle.locationAuth;
    self.userName = memberIncircle.name;
    
    DLog(@"my people view %@",self.lblLocation.text);
}

-(float)calculateQADetailStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(244,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.systemFont} context:nil];
    return textRect.size.width;
}
@end
