//
//  CommentViewController.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-22.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentPost.h"
#import "RatePost.h"
#import "GDLocalizableController.h"

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@interface CommentViewController (){
    UITextView *commentText;
    UIBarButtonItem *backbar;
    UIScrollView *_contentView;
    UILabel *commentPlaceholder;
    UIButton *right;
    UIView *Statusview;
    NSInteger foodScore;
    NSInteger envirScore;
    NSInteger serviceScore;
    NSInteger valueVScore;
    UIActivityIndicatorView *wait;
    UIView *activityBackGround;
    UILabel *activityLab;
}

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:LabColor(0.94, 0.94, 0.94)];
    [self initStar];
    [self initnav];
}

-(void)initnav{
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.text = GDLocalizedString(@"RATING");
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:15];
    self.navigationItem.titleView = titleLab;
    right  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [right setExclusiveTouch:YES];
    UILabel *rightlab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    rightlab.textColor = [UIColor whiteColor];
    rightlab.text = GDLocalizedString(@"Submit");
    rightlab.textAlignment = NSTextAlignmentCenter;
    rightlab.font = [UIFont boldSystemFontOfSize:15];
    [right addSubview:rightlab];
    [right addTarget:self action:@selector(submit)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIButton *back  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 20)];
    [back setExclusiveTouch:YES];
    [back addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    backbar = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backbar;
    
    Statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    Statusview.backgroundColor = LabColor(0.90,0,0);
    [self.view addSubview:Statusview];
    
    activityBackGround = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height)/2-30, 100, 80)];
    activityBackGround.backgroundColor = [UIColor blackColor];
    activityBackGround.layer.cornerRadius = 10;
    activityBackGround.hidden = YES;
    [self.view addSubview:activityBackGround];
    
    activityLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height/2+10, 100, 30)];
    activityLab.textAlignment = NSTextAlignmentCenter;
    activityLab.textColor = [UIColor whiteColor];
    activityLab.text = GDLocalizedString(@"LOAD");
    activityLab.hidden = YES;
    [self.view addSubview:activityLab];
    
    wait = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    wait.hidesWhenStopped = YES;
    wait.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.view addSubview:wait];
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initStar{
    _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height+64)];
    [_contentView setBounces:NO];
    _contentView.delegate = self;
    [_contentView setContentSize:CGSizeMake(0, 640)];
    [self.view addSubview:_contentView];
    
    CGFloat starViewHeight = self.view.frame.size.height/5*3;
    UIView *starView = [[UIView alloc]initWithFrame:CGRectMake(10, 70, self.view.frame.size.width-20, starViewHeight)];
    [_contentView addSubview:starView];
    
    UILabel *starline = [[UILabel alloc]initWithFrame:CGRectMake(10, starViewHeight-1, self.view.frame.size.width-20, 1)];
    starline.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [starView addSubview:starline];
    
    UIView *foodview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, starView.frame.size.width, starViewHeight/4)];
    foodview.backgroundColor = [UIColor whiteColor];
    [starView addSubview:foodview];
    
    UIView *foodsubview = [[UIView alloc]init];
    [foodview addSubview:foodsubview];
    
    UIView *foodline = [[UIView alloc]initWithFrame:CGRectMake(10, starViewHeight/4-1, self.view.frame.size.width-40, 1)];
    foodline.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [starView addSubview:foodline];
    
    UILabel *food = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, starView.frame.size.width, 17)];
    food.text =GDLocalizedString(@"FOOD");
    food.textAlignment = NSTextAlignmentCenter;
    food.textColor = [UIColor grayColor];
    food.font = [UIFont systemFontOfSize:15];
    [foodsubview addSubview:food];
    
    CGFloat starwidth = self.view.frame.size.width*0.6;
    TQStarRatingView *foodStar = [[TQStarRatingView alloc] initWithFrame:CGRectMake((starView.frame.size.width-starwidth)/2+5, 22, starwidth, (starwidth-50)/5) numberOfStar:5];
    foodStar.delegate = self;
    foodStar.tag = 1;
    foodScore = 5;
    [foodsubview addSubview:foodStar];
    foodsubview.frame = CGRectMake(0, (foodview.frame.size.height-22-foodStar.frame.size.height)/2, self.view.frame.size.width-20, foodview.frame.size.height);
    
    UIView *environmentview = [[UIView alloc]initWithFrame:CGRectMake(0, starViewHeight/4, starView.frame.size.width, starViewHeight/4)];
    environmentview.backgroundColor = [UIColor whiteColor];
    [starView addSubview:environmentview];
    
    UIView *environmentsubview = [[UIView alloc]init];
    [environmentview addSubview:environmentsubview];
    
    UIView *environmentline = [[UIView alloc]initWithFrame:CGRectMake(10, starViewHeight/2-1, self.view.frame.size.width-40, 1)];
    environmentline.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [starView addSubview:environmentline];
    
    UILabel *environment = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, starView.frame.size.width, 17)];
    environment.text = GDLocalizedString(@"ENVIRONMENT");
    environment.textAlignment = NSTextAlignmentCenter;
    environment.textColor = [UIColor grayColor];
    environment.font = [UIFont systemFontOfSize:15];
    [environmentsubview addSubview:environment];
    
    TQStarRatingView *environmentStar = [[TQStarRatingView alloc] initWithFrame:CGRectMake((starView.frame.size.width-starwidth)/2+5, 22, starwidth, (starwidth-50)/5) numberOfStar:5];
    environmentStar.delegate = self;
    environmentStar.tag = 2;
    envirScore = 5;
    [environmentsubview addSubview:environmentStar];
    environmentsubview.frame = CGRectMake(0, (environmentview.frame.size.height-22-environmentStar.frame.size.height)/2, self.view.frame.size.width-20, environmentview.frame.size.height);
    
    UIView *serviceview = [[UIView alloc]initWithFrame:CGRectMake(0, starViewHeight/2, starView.frame.size.width, starViewHeight/4)];
    serviceview.backgroundColor = [UIColor whiteColor];
    [starView addSubview:serviceview];
    
    UIView *serviceSubView = [[UIView alloc]init];
    [serviceview addSubview:serviceSubView];
    
    UIView *serviceline = [[UIView alloc]initWithFrame:CGRectMake(10, starViewHeight/4*3-1, self.view.frame.size.width-40, 1)];
    serviceline.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [starView addSubview:serviceline];
    
    UILabel *service = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, starView.frame.size.width, 17)];
    service.textAlignment = NSTextAlignmentCenter;
    service.textColor = [UIColor grayColor];
    service.text = GDLocalizedString(@"SERVICE");
    service.font = [UIFont systemFontOfSize:15];
    [serviceSubView addSubview:service];
    
    TQStarRatingView *serviceStar = [[TQStarRatingView alloc] initWithFrame:CGRectMake((starView.frame.size.width-starwidth)/2+5,22, starwidth, (starwidth-50)/5) numberOfStar:5];
    serviceStar.delegate = self;
    serviceStar.tag = 3;
    serviceScore = 5;
    [serviceSubView addSubview:serviceStar];
    serviceSubView.frame = CGRectMake(0, (serviceview.frame.size.height-22-serviceStar.frame.size.height)/2, self.view.frame.size.width-20, serviceview.frame.size.height);
    
    UIView *valueview = [[UIView alloc]initWithFrame:CGRectMake(0, starViewHeight/4*3, starView.frame.size.width, starViewHeight/4)];
    valueview.backgroundColor = [UIColor whiteColor];
    [starView addSubview:valueview];
    
    UIView *valueSubView = [[UIView alloc]init];
    [valueview addSubview:valueSubView];
    
    UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, starView.frame.size.width, 17)];
    value.text = GDLocalizedString(@"VALUE");
    value.textAlignment = NSTextAlignmentCenter;
    value.textColor = [UIColor grayColor];
    value.font = [UIFont systemFontOfSize:15];
    [valueSubView addSubview:value];
    
    TQStarRatingView *valueVStar = [[TQStarRatingView alloc] initWithFrame:CGRectMake((starView.frame.size.width-starwidth)/2+5, 22, starwidth, (starwidth-50)/5) numberOfStar:5];
    valueVStar.delegate = self;
    valueVStar.tag = 4;
    valueVScore = 5;
    [valueSubView addSubview:valueVStar];
    valueSubView.frame = CGRectMake(0, (valueview.frame.size.height-22-valueVStar.frame.size.height)/2, self.view.frame.size.width-20, valueview.frame.size.height);
    
    commentText = [[UITextView alloc]initWithFrame:CGRectMake(10, starViewHeight+80, self.view.frame.size.width-20, starViewHeight/2)];
    commentText.font = [UIFont systemFontOfSize:15];
    commentText.tag = 10;
    [commentText setTextContainerInset:UIEdgeInsetsMake(15, 10, 0, 10)];
    commentText.delegate =self;
    [_contentView addSubview:commentText];
    
    UILabel *commentTextline = [[UILabel alloc]initWithFrame:CGRectMake(10, commentText.frame.size.height+commentText.frame.origin.y, self.view.frame.size.width-20, 1)];
    commentTextline.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [_contentView addSubview:commentTextline];
    commentPlaceholder = [[UILabel alloc]initWithFrame:CGRectMake(25, starViewHeight+95, 200, 20)];
    commentPlaceholder.text = GDLocalizedString(@"Please input comment");
    commentPlaceholder.enabled = NO;
    commentPlaceholder.font = [UIFont systemFontOfSize:14];
    commentPlaceholder.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:commentPlaceholder];
}


-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        commentPlaceholder.text = GDLocalizedString(@"Please input comment");
    }else{
        commentPlaceholder.text = @"";
    }
}

-(void)submit{
    activityBackGround.hidden = NO;
    activityLab.hidden = NO;
    [wait startAnimating];
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(commentpost) object:nil];
    NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(ratepost) object:nil];
    [thread1 start];
    [thread2 start];
}

-(void)commentpost{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *uid = [userDefaultes objectForKey:@"userId"];
    CommentPost *cp = [[CommentPost alloc]init];
    [cp Comment:@"http://app.enjoylist.com/comment.asp" :commentText.text :_locationId :uid :_clientid :@"0"];
}

-(void)ratepost{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *uid = [userDefaultes objectForKey:@"userId"];
    RatePost *rp = [[RatePost alloc]init];
    [rp Rate:@"http://app.enjoylist.com/rate.asp" :foodScore :envirScore :serviceScore :valueVScore :_locationId :_clientid :uid];
    if ([rp.result rangeOfString:@"success"].location != NSNotFound){
        [self performSelectorOnMainThread:@selector(successAlter) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(netAlter) withObject:nil waitUntilDone:NO];
    }
}

-(void)netAlter{
    [wait stopAnimating];
    activityLab.hidden = YES;
    activityBackGround.hidden = YES;
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Network Promblem!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
}

-(void)successAlter{
    [wait stopAnimating];
    activityBackGround.hidden = YES;
    activityLab.hidden = YES;
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Success to submit!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == 10) {
        [textView becomeFirstResponder];
        Statusview.frame = CGRectMake(0, commentText.frame.origin.y-70, self.view.frame.size.width, 64);
        UIButton *left  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [left setTitle:GDLocalizedString(@"Done") forState:UIControlStateNormal];
        [left addTarget:self action:@selector(Done)forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        [self.navigationItem setTitle:@""];
        self.navigationItem.rightBarButtonItem = nil;
        [UIView beginAnimations:nil context:nil];
        [_contentView setContentSize:CGSizeMake(0, 640-(commentText.frame.origin.y-70))];
        [UIView setAnimationDuration:0.3];
        CGRect frame = self.view.frame;
        frame.origin.y -= commentText.frame.origin.y-70;
        frame.size.height +=commentText.frame.origin.y-70;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (commentText.isFirstResponder) {
        Statusview.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
        self.navigationItem.leftBarButtonItem = backbar;
        [self.navigationItem setTitle:GDLocalizedString(@"RATING")];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        frame.size.height -= commentText.frame.origin.y-70;
        self.view.frame = frame;
        [UIView commitAnimations];
        [commentText resignFirstResponder];
        [_contentView setContentSize:CGSizeMake(0, 640+(commentText.frame.origin.y-70))];
    }
}

-(void)Done{
    Statusview.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    self.navigationItem.leftBarButtonItem = backbar;
    [self.navigationItem setTitle:GDLocalizedString(@"RATING")];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height -= commentText.frame.origin.y-70;
    self.view.frame = frame;
    [UIView commitAnimations];
    [_contentView setContentSize:CGSizeMake(0, 640+(commentText.frame.origin.y-70))];
    [commentText resignFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(void)starRatingView:(TQStarRatingView *)view score:(NSInteger)score
{
    switch (view.tag) {
        case 1:
        {
            foodScore = score;
        }
            break;
        case 2:
        {
            envirScore = score;
        }
            break;
        case 3:
        {
            serviceScore = score;
        }
            break;
        case 4:
        {
            valueVScore = score;
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
