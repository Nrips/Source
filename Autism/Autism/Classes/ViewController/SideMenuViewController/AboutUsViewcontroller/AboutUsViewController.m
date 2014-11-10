//
//  AboutUsViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 3/11/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
{
    UILabel *lblAbout;
    UILabel *lblWhatwedo;
    UILabel *lblWhatText;
    
    UILabel *lbl1;
    UILabel *lbl2;
    UILabel *lbl3;
    UILabel *lbl4;
    
    UILabel *lbl1Text;
    UILabel *lbl2Text;
    UILabel *lbl3Text;
    UILabel *lbl4Text;
    
    UILabel *lblVisionHead;
    UILabel *lblVisionText;
    
    UILabel *lblHistoryHead;
    UILabel *lblHistoryText;
    
    UIImageView *imag;
}

@end

@implementation AboutUsViewController

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
    self.title =@"About Us";
    
    CGSize contentSize = CGSizeMake(320, 1150);
    [scrollView setContentSize:contentSize];
    
    [self setupFeilds];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setupFeilds
{
    imag =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1150)];
    [imag setImage:[UIImage imageNamed:@"light-gray-full-bg.fw.png"]];
    [scrollView addSubview:imag];
    
//    UILabel *lblAboutus =[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 112, 25)];
//    [lblAboutus setText:@"About us"];
//    [lblAboutus setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
//    [lblAboutus setTextColor:[UIColor purpleColor]];
//    [scrollView addSubview:lblAboutus];

    
    
    UILabel *lblfontsize =[[UILabel alloc] initWithFrame:CGRectMake(140, 0, 85, 30)];
    [lblfontsize setText:@"Font Size"];
    //[lblfontsize setTextColor:[UIColor purpleColor]];
    [scrollView addSubview:lblfontsize];
    
    
    UIButton *fontSmall =[UIButton buttonWithType:UIButtonTypeCustom];
    [fontSmall setImage:[UIImage imageNamed:@"a-btn.fw.png"] forState:UIControlStateNormal];
    [fontSmall setFrame:CGRectMake(220, 0, 50, 40)];
    [fontSmall addTarget:self action:@selector(afontSmall) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:fontSmall];
    
    
    UIButton *fontBig =[UIButton buttonWithType:UIButtonTypeCustom];
    [fontBig setImage:[UIImage imageNamed:@"a+btn.fw.png"] forState:UIControlStateNormal];
    [fontBig setFrame:CGRectMake(260, 0, 50, 40)];
    [fontBig addTarget:self action:@selector(aFontBig) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:fontBig];

    
    
    
    lblAbout =[[UILabel alloc] initWithFrame:CGRectMake(10, 40, 280, 240)];
    [lblAbout setText:@"There are more than half a million people in the UK living with autism, an invisible, misunderstood and lonely disability. 60,000 live in the West Midlands.We are the leading charity in the West Midlands for people affected by autism. We exist to enable all people with autism, and those who love and care for them to lead fulfilling and rewarding lives. Our passionate, expert staff and volunteers work across all age groups and abilities, providing direct support to people affected by autism."];
    lblAbout.numberOfLines = 0;
    lblAbout.adjustsFontSizeToFitWidth=YES;
    lblAbout.minimumScaleFactor=0.9;
    lblAbout.textAlignment =  NSTextAlignmentJustified;
    [lblAbout setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lblAbout];
    
    lblWhatwedo =[[UILabel alloc] initWithFrame:CGRectMake(10, 280, 300, 40)];
    [lblWhatwedo setText:@"What do we do?"];
    [lblWhatwedo setTextColor:[UIColor purpleColor]];
    [lblWhatwedo setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    [scrollView addSubview:lblWhatwedo];
    
    
    
    lbl1 =[[UILabel alloc] initWithFrame:CGRectMake(10, 320, 30, 30)];
    [lbl1 setText:@">"];
    [lbl1 setTextColor:[UIColor purpleColor]];
    lbl1.adjustsFontSizeToFitWidth=YES;
    lbl1.minimumScaleFactor=0.9;
    lbl1.textAlignment =  NSTextAlignmentJustified;
    [lbl1 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl1];
    
    lbl1Text =[[UILabel alloc] initWithFrame:CGRectMake(40, 322, 250, 80)];
    [lbl1Text setText:@"Support people with autism to live as independently as possible, in residential care, or in their own or the family home."];
    //[lbl1Text setTextColor:[UIColor purpleColor]];
    lbl1Text.numberOfLines = 0;
    lbl1Text.adjustsFontSizeToFitWidth=YES;
    lbl1Text.minimumScaleFactor=0.9;
    lbl1Text.textAlignment =  NSTextAlignmentJustified;
    [lbl1Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl1Text];
    
    
    lbl2 =[[UILabel alloc] initWithFrame:CGRectMake(10, 418, 30, 30)];
    [lbl2 setText:@">"];
    [lbl2 setTextColor:[UIColor purpleColor]];
    [lbl2 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl2];
    
    lbl2Text =[[UILabel alloc] initWithFrame:CGRectMake(40, 410, 250, 80)];
    [lbl2Text setText:@"Provide activities and events and support for families, and an information helpline."];
    //[lbl1Text setTextColor:[UIColor purpleColor]];
    lbl2Text.numberOfLines = 0;
    lbl2Text.adjustsFontSizeToFitWidth=YES;
    lbl2Text.minimumScaleFactor=0.9;
    lbl2Text.textAlignment =  NSTextAlignmentJustified;
    [lbl2Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl2Text];
    
    
    lbl3 =[[UILabel alloc] initWithFrame:CGRectMake(10, 498, 30, 30)];
    [lbl3 setText:@">"];
    [lbl3 setTextColor:[UIColor purpleColor]];
    [lbl3 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl3];
    
    lbl3Text =[[UILabel alloc] initWithFrame:CGRectMake(40, 500, 250, 40)];
    [lbl3Text setText:@"Help people with autism to find and keep a job."];
    //[lbl1Text setTextColor:[UIColor purpleColor]];
    lbl3Text.numberOfLines = 0;
    lbl3Text.adjustsFontSizeToFitWidth=YES;
    lbl3Text.minimumScaleFactor=0.9;
    lbl3Text.textAlignment =  NSTextAlignmentJustified;
    [lbl3Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl3Text];
    
    
    lbl4 =[[UILabel alloc] initWithFrame:CGRectMake(10, 555, 30, 30)];
    [lbl4 setText:@">"];
    [lbl4 setTextColor:[UIColor purpleColor]];
    [lbl4 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl4];
    
    lbl4Text =[[UILabel alloc] initWithFrame:CGRectMake(40, 550, 250, 80)];
    [lbl4Text setText:@"Offer training for parents of children with autism, and the professionals who help them ....and much more!"];
    //[lbl1Text setTextColor:[UIColor purpleColor]];
    lbl4Text.adjustsFontSizeToFitWidth=YES;
    lbl4Text.minimumScaleFactor=0.9;
    lbl4Text.textAlignment =  NSTextAlignmentJustified;
    lbl4Text.numberOfLines = 0;
    [lbl4Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lbl4Text];


    lblVisionHead =[[UILabel alloc] initWithFrame:CGRectMake(10, 640, 300, 40)];
    [lblVisionHead setText:@"Our Vision"];
    [lblVisionHead setTextColor:[UIColor purpleColor]];
    [lblVisionHead setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    [scrollView addSubview:lblVisionHead];
    
    
    lblVisionText =[[UILabel alloc] initWithFrame:CGRectMake(10, 675, 300, 80)];
    [lblVisionText setText:@"Is a world where all people on the autism spectrum have the specialist care and support they need to lead fulfilling and rewarding lives."];
    //[lbl1Text setTextColor:[UIColor purpleColor]];
    lblVisionText.adjustsFontSizeToFitWidth=YES;
    lblVisionText.minimumScaleFactor=0.9;
    lblVisionText.textAlignment =  NSTextAlignmentJustified;
    lblVisionText.numberOfLines = 0;
    [lblVisionText setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lblVisionText];

    
    lblHistoryHead =[[UILabel alloc] initWithFrame:CGRectMake(10, 760, 300, 40)];
    [lblHistoryHead setText:@"Our History"];
    [lblHistoryHead setTextColor:[UIColor purpleColor]];
    [lblHistoryHead setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    [scrollView addSubview:lblHistoryHead];
    
    
    lblHistoryText =[[UILabel alloc] initWithFrame:CGRectMake(10, 760, 300, 340)];
    [lblHistoryText setText:@"Our story began in 1965 when groups of parents with children on the autism spectrum in Birmingham joined together to provide each other with support and encouragement. By the 1980s, parents were campaigning to raise funds to set up Oakfield House, our first residential home, opened by Princess Anne in 1988. We now have six residential homes; two supported living establishments, and provide support in the community to hundreds of people on the autism spectrum and their families. Parental support groups remain very important: we have large numbers of support groups throughout the West Midlands."];
    //[lbl1Text setTextColor:[UIColor purpleColor]];
    lblHistoryText.adjustsFontSizeToFitWidth=YES;
    lblHistoryText.minimumScaleFactor=0.9;
    lblHistoryText.textAlignment =  NSTextAlignmentJustified;
    lblHistoryText.numberOfLines = 0;
    [lblHistoryText setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [scrollView addSubview:lblHistoryText];

    
}

-(void)aFontBig
{
    CGSize contentSize = CGSizeMake(320, 1830);
    [scrollView setContentSize:contentSize];
    
    [imag setFrame:CGRectMake(0, 0, 320, 1830)];
    
   
    [lblAbout setFrame:CGRectMake(10, 40, 280, 240 + 180)];
    [lblWhatwedo setFrame:CGRectMake(10, 280, 300, 40 +360)];
    [lbl1 setFrame:CGRectMake(10, 300, 30, 120 + 320)];
    [lbl1Text setFrame:CGRectMake(40, 350, 250, 470)];
    [lbl2 setFrame:CGRectMake(10, 440, 30, 30+470)];
    [lbl2Text setFrame:CGRectMake(40, 440, 250, 80+500)];
    [lbl3 setFrame:CGRectMake(10, 518, 30, 30+570)];
    [lbl3Text setFrame:CGRectMake(40, 520, 250, 40+580)];
    [lbl4 setFrame:CGRectMake(10, 555, 30, 30+ 630)];
    [lbl4Text setFrame:CGRectMake(40, 550, 250, 80 + 690)];
    [lblVisionHead setFrame:CGRectMake(10, 1010, 300, 40)];
    [lblVisionText setFrame:CGRectMake(10, 1030, 300, 180)];
    [lblHistoryHead setFrame:CGRectMake(10, 1210, 300, 40)];
    [lblHistoryText setFrame:CGRectMake(10, 1250, 300, 550)];


    
    [lblAbout setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lblWhatwedo setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl1 setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl1Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl2 setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl2Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl3 setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl3Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl4 setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lbl4Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lblVisionHead setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lblVisionText setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lblHistoryHead setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    [lblHistoryText setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];

}

-(void) afontSmall
{
    [lblAbout setFrame:CGRectMake(10, 40, 280, 240)];
    [lblWhatwedo setFrame:CGRectMake(10, 280, 300, 40)];
    [lbl1 setFrame:CGRectMake(10, 320, 30, 30)];
    [lbl1Text setFrame:CGRectMake(40, 322, 250, 80)];
    [lbl2 setFrame:CGRectMake(10, 418, 30, 30)];
    [lbl2Text setFrame:CGRectMake(40, 410, 250, 80)];
    [lbl3 setFrame:CGRectMake(10, 498, 30, 30)];
    [lbl3Text setFrame:CGRectMake(40, 500, 250, 40)];
    [lbl4 setFrame:CGRectMake(10, 555, 30, 30)];
    [lbl4Text setFrame:CGRectMake(40, 550, 250, 80)];
    [lblVisionHead setFrame:CGRectMake(10, 640, 300, 40)];
    [lblVisionText setFrame:CGRectMake(10, 675, 300, 80)];
    [lblHistoryHead setFrame:CGRectMake(10, 760, 300, 40)];
    [lblHistoryText setFrame:CGRectMake(10, 760, 300, 340)];
    
   
    [lblAbout setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lblWhatwedo setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    [lbl1 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl1Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl2 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl2Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl3 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl3Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl4 setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lbl4Text setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lblVisionHead setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    [lblVisionText setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [lblHistoryHead setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    [lblHistoryText setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    
    CGSize contentSize = CGSizeMake(320, 1150);
    [scrollView setContentSize:contentSize];

}

@end
