//
//  ViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/3/31.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "ViewController.h"
#import "GDLocalizableController.h"
#import "loginViewController.h"
#import "rigistViewController.h"
#import "LeftMenuViewController.h"
#import "mainViewController.h"
#import "GDLocalizableController.h"

@interface ViewController (){
    UIButton *logoBtn;
    UIView *logo;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSTimer *timer;
    UIButton *login;
    UIButton *activation;
    UIButton *browse;
    UILabel *browselab;
    UILabel *activationlab;
    UILabel *loginlab;
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    if (logo.hidden == YES) {
        [self addTimer];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //设置状态栏文字为白色
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self initBgscrollview];
    [self initButton];
    [self initLogo];
    [self initNav];
}

-(void)initNav{
    //导航透明化
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;    //让rootView禁止滑动
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toumingtu.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.view setMultipleTouchEnabled:NO];
}

-(void)initLogo{
    logo = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImageView *logoImg = [[UIImageView alloc]init];
    logoImg.frame = logo.frame;
    logoImg.image = [UIImage imageNamed:@"Bulr"];
    [self.view addSubview:logo];
    [logo addSubview:logoImg];
    
    logoBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-37.5, self.view.frame.size.height/2-15, 75, 30)];
    [logoBtn setBackgroundImage:[UIImage imageNamed:@"EnjoyLogo"] forState:UIControlStateNormal];
    [logo addSubview:logoBtn];
    
    [self performSelector:@selector(automove) withObject:nil afterDelay:0.3];
    
}

-(void)automove{
    [UIView animateWithDuration:1 animations:^{
        logoBtn.frame = CGRectMake(self.view.frame.size.width/2-75, 80, 150, 60);
    } completion:^(BOOL finished) {
        logo.hidden = YES;
        [self addTimer];
        scrollView.hidden = NO;
        login.hidden = NO;
        //activation.hidden = NO;
        browse.hidden = NO;
        pageControl.hidden = NO;
    }];
}

-(void)initBgscrollview{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height+64)];
    scrollView.hidden = YES;
    [scrollView setBounces:NO];
    [scrollView setDelegate:self];
    CGFloat imageW = scrollView.frame.size.width;
    //    图片高
    CGFloat imageH = scrollView.frame.size.height;
    //    图片的Y
    CGFloat imageY = 0;
    //    图片中数
    NSInteger totalCount = 3;
    //   1.添加3张图片
    for (int i = 0; i < totalCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.tag = i;
    //        图片X
        CGFloat imageX = i * imageW;
    //        设置frame
        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    //        设置图片
        NSString *name = [NSString stringWithFormat:@"%i.jpg", i];
        imageView.image = [UIImage imageNamed:name];
    //        隐藏指示条
        scrollView.showsHorizontalScrollIndicator = NO;
             
        [scrollView addSubview:imageView];
    }
    //    2.设置scrollview的滚动范围
    CGFloat contentW = totalCount *imageW;
    //不允许在垂直方向上进行滚动
    scrollView.contentSize = CGSizeMake(contentW, 0);
    
    //    3.设置分页
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    //page control
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, 20)];
    pageControl.currentPage = 0;
    pageControl.numberOfPages = totalCount;
    pageControl.hidden = YES;
    [self.view addSubview:pageControl];
}

-(void)initButton{
    CGFloat Phonewidth = self.view.frame.size.width;
    CGFloat Phoneheight = self.view.frame.size.height;
    
    UIImageView *logoView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"EnjoyLogo.png"]];
    logoView.frame = CGRectMake(Phonewidth/2-75, 80, 150, 60);
    [self.view addSubview:logoView];
    
    login = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/8, Phoneheight-90, Phonewidth/4, 30)];
    [login setTitle:GDLocalizedString(@"login") forState:UIControlStateNormal];
    login.titleLabel.font = [UIFont systemFontOfSize:15];
    login.layer.borderWidth = 1;
    login.layer.borderColor = [UIColor whiteColor].CGColor;
    login.layer.cornerRadius = 15;
    [login addTarget:self action:@selector(LoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    login.hidden = YES;
    [login setExclusiveTouch:YES];
    [self.view addSubview:login];
    
    activation = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/2-25, Phoneheight-100, 50, 50)];
    [activation setBackgroundImage:[UIImage imageNamed:@"Activation"] forState:UIControlStateNormal];
    [activation addTarget:self action:@selector(activationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    activation.hidden = YES;
    [activation setExclusiveTouch:YES];
    [self.view addSubview:activation];
    activationlab = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-37, Phoneheight-66, 74, 12)];
    [activationlab setText:GDLocalizedString(@"ACTIVATION")];
    activationlab.textAlignment = NSTextAlignmentCenter;
    activationlab.textColor = [UIColor whiteColor];
    activationlab.hidden = YES;
    activationlab.font = [UIFont fontWithName:@"ArialHebrew" size:12];
    [self.view addSubview:activationlab];
    
    browse = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/8*5, Phoneheight-90, Phonewidth/4, 30)];
    [browse addTarget:self action:@selector(browseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [browse setTitle:GDLocalizedString(@"BROWSE") forState:UIControlStateNormal];
    browse.hidden = YES;
    browse.titleLabel.font = [UIFont systemFontOfSize:15];
    browse.layer.borderWidth = 1;
    browse.layer.borderColor = [UIColor whiteColor].CGColor;
    browse.layer.cornerRadius = 15;
    [browse setExclusiveTouch:YES];
    [self.view addSubview:browse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [timer invalidate];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}

- (void)addTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)nextImage
{
    int page = (int)pageControl.currentPage;
    if (page == 2) {
        page = 0;
        }else
        {
                page++;
        }
    CGFloat x = page * scrollView.frame.size.width;
    [UIView animateWithDuration:1 animations:^{
        scrollView.contentOffset = CGPointMake(x, -64);
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView2{
    CGFloat scrollviewW =  scrollView2.frame.size.width;
    CGFloat x = scrollView2.contentOffset.x;
    int page = (x + scrollviewW / 2) /  scrollviewW;
    pageControl.currentPage = page;
}

-(void)LoginBtnClick:(UIButton *)btn{
    [timer invalidate];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([[userdefault objectForKey:@"flag"] isEqualToString:@"1"]) {
        mainViewController *mainView = [[mainViewController alloc]init];
        [self.navigationController pushViewController:mainView animated:YES];
    }else{
        [userdefault setObject:@"0" forKey:@"flag"];
        loginViewController *loginView =[[loginViewController alloc]init];
        [self.navigationController pushViewController:loginView animated:YES];
        loginView.title = GDLocalizedString(@"LOGIN");
    }
}
-(void)activationBtnClick:(UIButton *)btn{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Yet Open") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
    /*[timer invalidate];
    rigistViewController *registView = [[rigistViewController alloc]init];
    [self.navigationController pushViewController:registView animated:YES];
    registView.title =GDLocalizedString(@"ACTIVATION");*/
}
-(void)browseBtnClick:(UIButton *)btn{
    [timer invalidate];
    mainViewController *mainView = [[mainViewController alloc]init];
    [self.navigationController pushViewController:mainView animated:YES];
}

-(void)changeLanguage{
    [login setTitle:GDLocalizedString(@"login") forState:UIControlStateNormal];
    [browse setTitle:GDLocalizedString(@"BROWSE") forState:UIControlStateNormal];
}

@end
