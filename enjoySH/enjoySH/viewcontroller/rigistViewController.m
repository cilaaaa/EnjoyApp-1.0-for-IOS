//
//  rigistViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/1.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "rigistViewController.h"
#import "GDLocalizableController.h"

@interface rigistViewController (){
    UITextField *username;
    UITextField *password;
    UIImage *userdepic;
    UIButton *usrpicbtn;
}

@end

@implementation rigistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat Phonewidth = self.view.frame.size.width;
    CGFloat Phoneheight = self.view.frame.size.height;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Bulr"]];
    imageView.frame = self.view.frame;
    [self.view addSubview:imageView];
    
    [self initnav];
    
    usrpicbtn = [[UIButton alloc]init];
    usrpicbtn.frame = CGRectMake(Phonewidth/2-50, Phoneheight/2-160, 100, 100);
    usrpicbtn.layer.masksToBounds = YES;
    usrpicbtn.layer.cornerRadius = 50;
    userdepic = [UIImage imageNamed:@"usrdefultpic.png"];
    
    [usrpicbtn setBackgroundImage:userdepic forState:UIControlStateNormal];
    [usrpicbtn addTarget:self action:@selector(getpic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:usrpicbtn];
    
    UITextField *cardNumber = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight/2-55, 150, 30)];
    cardNumber.placeholder = @"Card Number";
    cardNumber.textAlignment = NSTextAlignmentCenter;
    cardNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
    cardNumber.delegate = self;
    cardNumber.textColor = [UIColor whiteColor];
    [cardNumber setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    cardNumber.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:cardNumber];
    
    UILabel *splitLine = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2-22, 200, 1.5)];
    splitLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine];
    
    UITextField *pinNumber = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight/2-19, 150, 30)];
    pinNumber.placeholder = @"PIN Number";
    pinNumber.textAlignment = NSTextAlignmentCenter;
    pinNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
    pinNumber.delegate = self;
    pinNumber.textColor = [UIColor whiteColor];
    [pinNumber setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    pinNumber.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:pinNumber];
    
    UILabel *splitLine2 = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2+14, 200, 1.5)];
    splitLine2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine2];

    username = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight/2+17, 150, 30)];
    username.placeholder = @"Name";
    username.clearButtonMode = UITextFieldViewModeWhileEditing;
    username.textAlignment = NSTextAlignmentCenter;
    username.delegate = self;
    username.textColor = [UIColor whiteColor];
    [username setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:username];
    
    UILabel *splitLine3 = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2+50, 200, 1.5)];
    splitLine3.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine3];
    
    UITextField *email = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight/2+53, 150, 30)];
    email.placeholder = @"Email";
    email.textAlignment = NSTextAlignmentCenter;
    email.clearButtonMode = UITextFieldViewModeWhileEditing;
    email.delegate = self;
    email.textColor = [UIColor whiteColor];
    [email setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:email];
    
    UILabel *splitLine4 = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2+86, 200, 1.5)];
    splitLine4.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine4];
    
    UITextField *phone = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight/2+89, 150, 30)];
    phone.placeholder = @"Phone";
    phone.textAlignment = NSTextAlignmentCenter;
    phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    phone.delegate = self;
    phone.textColor = [UIColor whiteColor];
    [phone setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    phone.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:phone];
    
    UILabel *splitLine5 = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2+121, 200, 1.5)];
    splitLine5.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine5];
    
    password = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight/2+124, 150, 30)];
    password.placeholder = @"Password";
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.textAlignment = NSTextAlignmentCenter;
    password.delegate = self;
    password.secureTextEntry = YES;
    password.textColor = [UIColor whiteColor];
    [password setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:password];
    
    UIButton *activation = [[UIButton alloc]initWithFrame:CGRectMake((Phonewidth-180)/2, Phoneheight/2+170, 180, 30 )];
    [activation setTitle:GDLocalizedString(@"ACTIVATION") forState:UIControlStateNormal];
    activation.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [activation setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    activation.layer.cornerRadius = 10;
    activation.titleLabel.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    activation.titleLabel.contentMode = UIControlContentVerticalAlignmentCenter;
    activation.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    [activation setBackgroundColor:[UIColor redColor]];
    
    [activation addTarget:self action:@selector(activationBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:activation];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view from its nib.
}

-(void)initnav{
    UIButton *back  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 15, 20)];
    [back addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"ic_arrow.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backbar = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backbar;
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)activationBtnClick:(UIButton *)btn{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)getpic:(UIButton *)btn{
    //指定源类型前，检查图片源是否可用
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
        
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//用户点击选取器中的“choose”按钮时被调用，告知委托对象，选取操作已经完成，同时将返回选取图片的实例
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    userdepic = image;
    [usrpicbtn setBackgroundImage:userdepic forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
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
