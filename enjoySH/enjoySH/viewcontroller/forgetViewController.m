//
//  forgetViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/1.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "forgetViewController.h"
#import "GDLocalizableController.h"

@interface forgetViewController ()

@end

@implementation forgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGFloat Phonewidth = self.view.frame.size.width;
    
    [self initnav];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Bulr"]];
    imageView.frame = self.view.frame;
    [self.view addSubview:imageView];
    
    UILabel *email = [[UILabel alloc]initWithFrame:CGRectMake((Phonewidth-280)/2, 60, 150, 30)];
    email.text = GDLocalizedString(@"Your Email?");
    email.textColor = [UIColor whiteColor];
    [self.view addSubview:email];
    
    UITextField *emailaddress = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, 100, 150, 44)];
    emailaddress.placeholder = GDLocalizedString(@"Email Address");
    emailaddress.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailaddress.delegate = self;
    emailaddress.textAlignment = NSTextAlignmentCenter;
    emailaddress.textColor = [UIColor whiteColor];
    [emailaddress setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    emailaddress.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:emailaddress];
    
    UIButton *recover = [[UIButton alloc]initWithFrame:CGRectMake((Phonewidth-180)/2, 180, 180, 30 )];
    [recover setTitle:GDLocalizedString(@"RECORVER") forState:UIControlStateNormal];
    recover.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [recover setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    recover.layer.cornerRadius = 10;
    recover.titleLabel.font = [UIFont systemFontOfSize:15];
    recover.titleLabel.contentMode = UIControlContentVerticalAlignmentCenter;
    [recover setBackgroundColor:[UIColor redColor]];
    [recover addTarget:self action:@selector(recoverBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:recover];
    
    UILabel *splitLine = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-100, 150, 200, 1.5)];
    splitLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine];
    
}

-(void)initnav{
    UIButton *back  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 20)];
    [back addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    UIBarButtonItem *backbar = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backbar;
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)recoverBtnClick:(UIButton *)btn{
    
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
