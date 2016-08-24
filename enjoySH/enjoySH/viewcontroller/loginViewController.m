//
//  loginViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/1.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "loginViewController.h"
#import "XmlLogin.h"
#import "XmlLoginData.h"
#import "rigistViewController.h"
#import "forgetViewController.h"
#import "mainViewController.h"
#import "FMDB.h"
#import "UIImageView+WebCache.h"
#import "GDLocalizableController.h"

@interface loginViewController (){
    UIActivityIndicatorView *logionwait;
    UITextField *username;
    UITextField *password;
    NSMutableArray *entries;
    UIButton *login;
    UIView *activityBackGround;
    UILabel *activityLab;
    XmlLogin *xmllogin;
}

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initnav];
    [self initControl];
}

-(void)initnav{
    UIButton *back  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 20)];
    [back addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    UIBarButtonItem *backbar = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backbar;
}

-(void)initControl{
    CGFloat Phonewidth = self.view.frame.size.width;
    CGFloat Phoneheight = self.view.frame.size.height;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Bulr"]];
    imageView.frame = self.view.frame;
    [self.view addSubview:imageView];
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *picurl = [userDefaultes stringForKey:@"avatarx2"];
    UIImageView *userpic = [[UIImageView alloc]init];
    if ([userDefaultes stringForKey:@"avatarx2"]==nil) {
        userpic.image = [UIImage imageNamed:@"Avatar"];
    }else{
        [userpic sd_setImageWithURL:[NSURL URLWithString:picurl] placeholderImage:[UIImage imageNamed:@"Avatar"]];
    }
    userpic.frame = CGRectMake(Phonewidth/2-50, Phoneheight/2-160, 100, 100);
    userpic.layer.masksToBounds = YES;
    userpic.layer.cornerRadius = 50;
    [self.view addSubview:userpic];
    
    username = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2-50, 200, 44)];
    username.placeholder = GDLocalizedString(@"USERNAME");
    username.clearButtonMode = UITextFieldViewModeWhileEditing;
    username.textAlignment = NSTextAlignmentCenter;
    username.font = [UIFont systemFontOfSize:15];
    username.delegate = self;
    username.textColor = [UIColor whiteColor];
    [username setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:username];
    
    UILabel *splitLine = [[UILabel alloc]initWithFrame:CGRectMake(Phonewidth/2-125, Phoneheight/2-3, 250, 0.5)];
    splitLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:splitLine];
    
    password = [[UITextField alloc]initWithFrame:CGRectMake(Phonewidth/2-100, Phoneheight/2, 200, 44)];
    password.placeholder = GDLocalizedString(@"PASSWORD");
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.textAlignment = NSTextAlignmentCenter;
    password.delegate = self;
    password.font = [UIFont systemFontOfSize:15];
    password.secureTextEntry = YES;
    password.textColor = [UIColor whiteColor];
    [password setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:password];
    
    login = [[UIButton alloc]initWithFrame:CGRectMake((Phonewidth-180)/2, Phoneheight-100, 180, 30 )];
    [login setTitle:GDLocalizedString(@"LOGIN") forState:UIControlStateNormal];
    [login setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    login.layer.cornerRadius = 15;
    login.titleLabel.font = [UIFont systemFontOfSize:15];
    login.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    login.titleLabel.textAlignment = NSTextAlignmentCenter;
    [login setExclusiveTouch:YES];
    [login setBackgroundColor:[UIColor redColor]];
    
    [login addTarget:self action:@selector(loginBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:login];
    
    UIButton *forgot = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/2-75, Phoneheight-60, 150, 11 )];
    [forgot setTitle:GDLocalizedString(@"FORGOT PASSWORD") forState:UIControlStateNormal];
    [forgot setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgot setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    forgot.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    forgot.layer.borderColor = [UIColor blackColor].CGColor;
    [forgot setExclusiveTouch:YES];
    [forgot addTarget:self action:@selector(forgotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgot];
    
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
    
    logionwait = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    logionwait.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    logionwait.hidesWhenStopped = YES;
    [self.view addSubview:logionwait];
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
    CGRect newframe = self.view.frame;
    newframe.origin.y = -(textField.frame.origin.y-username.frame.origin.y);
    self.view.frame = newframe;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    CGRect newframe = self.view.frame;
    newframe.origin.y = 0;
    self.view.frame = newframe;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [username resignFirstResponder];
    [password resignFirstResponder];
    CGRect newframe = self.view.frame;
    newframe.origin.y = 0;
    self.view.frame = newframe;
}

-(void)loginBtnClick:(UIButton *)btn{
    [username resignFirstResponder];
    [password resignFirstResponder];
    CGRect newframe = self.view.frame;
    newframe.origin.y = 0;
    self.view.frame = newframe;
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(datalogin) object:nil];
    [thread start];
    login.enabled = NO;
    activityBackGround.hidden = NO;
    activityLab.hidden = NO;
    [logionwait startAnimating];
    
}

-(void)datalogin{
    xmllogin = [[XmlLogin alloc]init];
    [xmllogin Login:@"http://app.enjoylist.com/authenticate.asp" :username.text :password.text];
    if (xmllogin.received == nil) {
        [self performSelectorOnMainThread:@selector(networkproblem) withObject:nil waitUntilDone:NO];
    }
    if ([xmllogin.result rangeOfString:@"error"].location != NSNotFound){
        [self performSelectorOnMainThread:@selector(Passproblem) withObject:nil waitUntilDone:NO];
    }else if ([xmllogin.result rangeOfString:@"user"].location != NSNotFound){
        [self performSelectorOnMainThread:@selector(xmlLoginData) withObject:nil waitUntilDone:NO];
    }else if ([xmllogin.result rangeOfString:@"405"].location != NSNotFound){
        [self performSelectorOnMainThread:@selector(serverproblem) withObject:nil waitUntilDone:NO];
    }
    [logionwait stopAnimating];
    activityBackGround.hidden = YES;
    activityLab.hidden = YES;
}

-(void)serverproblem{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Server Promblem!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
}

-(void)networkproblem{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Network Promblem!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
}

-(void)Passproblem{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Username or Password error") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
}

-(void)xmlLoginData{
    XmlLoginData *xmlData = [[XmlLoginData alloc]init];
    [xmlData StartParse:xmllogin.received];
    NSDictionary *dict = xmlData.dict;
    if(dict != nil){
        NSInteger Id = [[dict objectForKey:@"id"] integerValue];
        NSString *Username = [dict objectForKey:@"username"];
        NSString *name = [dict objectForKey:@"name"];
        NSString *email = [dict objectForKey:@"email"];
        NSString *phone = [dict objectForKey:@"phone"];
        NSString *mobile = [dict objectForKey:@"mobile"];
        NSString *cardNumber = [dict objectForKey:@"cardNumber"];
        NSString *validity = [dict objectForKey:@"validity"];
        NSString *cardName = [dict objectForKey:@"cardName"];
        NSString *locale = [dict objectForKey:@"locale"];
        NSString *gender = [dict objectForKey:@"gender"];
        NSString *birthday = [dict objectForKey:@"birthday"];
        NSString *nationality = [dict objectForKey:@"nationality"];
        NSString *avatarx2 = [dict objectForKey:@"avatarx2"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        if([db open]){
            FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM PersonList WHERE UID = '%li'",(long)Id]];
            if([s next]==NO){
                [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO PersonList VALUES (%li,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",(long)Id,Username,name,email,phone,mobile,cardNumber,validity,cardName,locale,gender,birthday,nationality,avatarx2]];
            }
            [db close];
            NSString *flag = @"1";
            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
            [userDefaultes setObject:flag forKey:@"flag"];
            [userDefaultes setObject:Username forKey:@"username"];
            [userDefaultes setObject:birthday forKey:@"birthday"];
            [userDefaultes setObject:cardNumber forKey:@"cardNumber"];
            [userDefaultes setObject:[NSNumber numberWithLong:Id] forKey:@"userId"];
            [userDefaultes setObject:avatarx2 forKey:@"avatarx2"];
            [userDefaultes setObject:validity forKey:@"validity"];
            mainViewController *mainView =[[mainViewController alloc]init];
            [self.navigationController pushViewController:mainView animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil];
            //[self initPush];
        }
    }
}

-(void)initPush{
    // 创建一个本地推送
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compt = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit|NSHourCalendarUnit) fromDate:dat];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    NSString *userBirthday = [userDefaults objectForKey:@"birthday"];
    NSDate *birDate = [dateFormatter dateFromString:userBirthday];
    NSCalendar *calendar2 = [NSCalendar currentCalendar];
    NSDateComponents *compt2 = [calendar2 components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit|NSHourCalendarUnit) fromDate:birDate];
    NSDateComponents *compt3 = [[NSDateComponents alloc] init];
    NSCalendar *calendar3 = [NSCalendar currentCalendar];
    if ([compt month]==[compt2 month]) {
        if ([compt day]>[compt2 day]) {
            [compt3 setYear:[compt year]+1];
            [compt3 setMonth:[compt2 month]];
            [compt3 setDay:[compt2 day]];
            [compt3 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
            birDate = [calendar3 dateFromComponents:compt3];
        }
    }else if([compt month]>[compt2 month]){
        [compt3 setYear:[compt year]+1];
        [compt3 setMonth:[compt2 month]];
        [compt3 setDay:[compt2 day]];
        [compt3 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        birDate = [calendar3 dateFromComponents:compt3];
    }else{
        [compt3 setYear:[compt year]];
        [compt3 setMonth:[compt2 month]];
        [compt3 setDay:[compt2 day]];
       [compt3 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        birDate = [calendar3 dateFromComponents:compt3];
    }
    if (notification != nil) {
        // 设置推送时间
        notification.fireDate = birDate;
        // 设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = kCFCalendarUnitYear;
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = [NSString stringWithFormat:@"Happy Birthday,%@",[userDefaults objectForKey:@"username"]];
        //显示在icon上的红色圈中的数子
        notification.applicationIconBadgeNumber++;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"birthday"forKey:@"key"];
        notification.userInfo = info;
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
    }
    NSDateFormatter * dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = @"yyyy-MM-dd";
    NSDate *validDate = [dateFormatter2 dateFromString:[userDefaults objectForKey:@"validity"]];
    NSDateComponents *compttmp = [[NSDateComponents alloc] init];
    [compttmp setDay:-30];
    NSDate *validDate2 = [calendar dateByAddingComponents:compttmp toDate:validDate options:0];
    UILocalNotification *cardnotification = [[UILocalNotification alloc] init];
    cardnotification.fireDate = validDate2;
    cardnotification.repeatInterval = kCFCalendarUnitDay;
    cardnotification.soundName = UILocalNotificationDefaultSoundName;
    cardnotification.alertBody = [NSString stringWithFormat:@"%@,Your card will expire",[userDefaults objectForKey:@"username"]];
    cardnotification.applicationIconBadgeNumber +=1;
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"card"forKey:@"key"];
    notification.userInfo = info;
    [app scheduleLocalNotification:cardnotification];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex == buttonIndex) {
        login.enabled = YES;
    }
}

-(void)forgotBtnClick:(UIButton *)btn{
    forgetViewController *forgotView =[[forgetViewController alloc]init];
    [self.navigationController pushViewController:forgotView animated:YES];
    forgotView.title = GDLocalizedString(@"Forgot Password");
}

@end
