//
//  LeftMenuViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/7.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "GDLocalizableController.h"
#import "VenueViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "ListViewController.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "mainViewController.h"
#import "MapViewController.h"
#import "FavoriteViewController.h"
#import "FMDB.h"
#import "XmlDataParser.h"
#import "UIImageView+WebCache.h"
#import <AlipaySDK/AlipaySDK.h>
#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@implementation LeftMenuViewController{
    NSArray *picmenu;
    UITableView *_tableView;
    UITableView *searchTable;
    NSArray *menu;
    NSArray *selectedPic;
    UIImageView *iconImage;
    UISearchBar *search;
    NSMutableArray *dataArray;
    UIImageView *_touxiang;
    UIActivityIndicatorView *_aiView;
    UIView *activityBackGround;
    UILabel *activityLab;
    UILabel *_username;
    UIButton *_signout;
    UISwitch *languageSw;
    UILabel *loginLab;
    int favNum;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    favNum = 0;
    self.view.backgroundColor = [UIColor colorWithRed:0.89/1 green:0.89/1 blue:0.89/1 alpha:1];
    search = [[UISearchBar alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, 20, self.view.frame.size.width/5*4+3, 50)];
    search.delegate = self;
    [search setBackgroundImage:[UIImage imageNamed:@"toumingtu.png"] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    for (UIView *subview in search.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textfield = (UITextField *)subview;
            textfield.layer.cornerRadius = 0;
        }
    }
    search.placeholder = GDLocalizedString(@"SEARCH");
    [self.view addSubview:search];
    
    UIView *userinfo = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, 70, self.view.frame.size.width, 115)];
    _touxiang = [[UIImageView alloc]init];
    _touxiang.frame = CGRectMake(15, 20, 75, 75);
    _touxiang.layer.cornerRadius = 37.5;
    _touxiang.layer.masksToBounds = YES;
    [userinfo addSubview:_touxiang];
    
    [self.view addSubview:userinfo];
    _username = [[UILabel alloc]initWithFrame:CGRectMake(105, 40, 150, 20)];
    _username.textAlignment = NSTextAlignmentLeft;
    [userinfo addSubview:_username];
    
    UILabel *validityNum = [[UILabel alloc]initWithFrame:CGRectMake(105, 55, 150, 10)];
    validityNum.textAlignment = NSTextAlignmentLeft;
    validityNum.font = [UIFont systemFontOfSize:12];
    [userinfo addSubview:validityNum];
    
    UILabel *validityLab = [[UILabel alloc]initWithFrame:CGRectMake(105, 70, 150, 10)];
    validityLab.textAlignment = NSTextAlignmentLeft;
    validityLab.font = [UIFont systemFontOfSize:12];
    [userinfo addSubview:validityLab];
    
    _signout = [[UIButton alloc]initWithFrame:CGRectMake(105, 65, 80, 50)];
    loginLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
    loginLab.font = [UIFont systemFontOfSize:12];
    [_signout addSubview:loginLab];
    [_signout setExclusiveTouch:YES];
    [_signout addTarget:self action:@selector(_signoutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [userinfo addSubview:_signout];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y+200, self.view.frame.size.width/4*3+20, self.view.frame.size.height)];
    _tableView.backgroundColor = [UIColor colorWithRed:0.89/1 green:0.89/1 blue:0.89/1 alpha:1];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.bounces = NO;
    _tableView.tag = 1;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
    
    searchTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 70 ,self.view.frame.size.width/4*3+20, self.view.frame.size.height)];
    searchTable.delegate = self;
    searchTable.dataSource = self;
    searchTable.tag = 2;
    searchTable.hidden = YES;
    searchTable.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:searchTable];
    
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
    
    _aiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _aiView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _aiView.hidesWhenStopped = YES;
    [self.view addSubview:_aiView];
    [_aiView stopAnimating];
    
    menu = [[NSArray alloc]initWithArray:[NSArray arrayWithObjects:GDLocalizedString(@"HOME"),GDLocalizedString(@"POPULAR"),GDLocalizedString(@"FAVORITES"),GDLocalizedString(@"LANGUAGE"),nil]];
    picmenu = [NSArray arrayWithObjects:[UIImage imageNamed:@"homeblack"],[UIImage imageNamed:@"popularblack"],[UIImage imageNamed:@"favoritesblack"], [UIImage imageNamed:@"languageblack"],nil];
    selectedPic = [NSArray arrayWithObjects:[UIImage imageNamed:@"homewhite"],[UIImage imageNamed:@"popularwhite"] ,[UIImage imageNamed:@"favoriteswhite"],[UIImage imageNamed:@"languagewhite"],nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        if([[userDefaultes stringForKey:@"flag"]isEqualToString:@"1"]){
            NSInteger UID = [userDefaultes integerForKey:@"userId"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
            FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
            if([db open]){
                FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM PersonList WHERE UID = '%li'",(long)UID]];
                while([s next]){
                    NSString *picurl = [s stringForColumn:@"AVATARX2"];
                    NSString *name = [s stringForColumn:@"NAME"];
                    NSString *validity = [s stringForColumn:@"VALIDITY"];
                    NSString *cardNum = [s stringForColumn:@"CARDNUMBER"];
                    [_touxiang sd_setImageWithURL:[NSURL URLWithString:picurl] placeholderImage:[UIImage imageNamed:@"Avatar s"]];
                    CGRect tempFrame1 = _username.frame;
                    tempFrame1.origin.y = 30;
                    _username.frame = tempFrame1;
                    CGRect tempFrame2 = _signout.frame;
                    tempFrame2.origin.y = 85;
                    _signout.frame = tempFrame2;
                    validityNum.text = cardNum;
                    validityLab.text = validity;
                    loginLab.text = GDLocalizedString(@"Sign Out");
                    _username.text = name;
                }
                [db close];
            }
        }else{
            _touxiang.image = [UIImage imageNamed:@"Avatar s"];
            loginLab.text =GDLocalizedString(@"LOGIN");
            CGRect tempFrame1 = _username.frame;
            tempFrame1.origin.y = 40;
            _username.frame = tempFrame1;
            CGRect tempFrame2 = _signout.frame;
            tempFrame2.origin.y = 65;
            _signout.frame = tempFrame2;
            validityNum.text = @"";
            validityLab.text = @"";
            _username.text = GDLocalizedString(@"HELLO");
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        [search resignFirstResponder];
        searchTable.hidden = YES;
        [search setShowsCancelButton:NO];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favorite) name:@"favorite" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedLanguage) name:@"changedLanguage" object:nil];
}

-(void)favorite{
    favNum++;
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    if (tableView.tag == 1) {
        number = [menu count];
    }else if (tableView.tag == 2){
        number = dataArray.count;
    }else{
        number = 0;
    }
    return number;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (tableView.tag == 1) {
        if(indexPath.row == 3){
            languageSw = [[UISwitch alloc]init];
            [languageSw addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = languageSw;
            languageSw.onTintColor = [UIColor redColor];
            if ([[GDLocalizableController userLanguage]  isEqual: CHINESE]) {
                languageSw.on = YES;
            }else if ([[GDLocalizableController userLanguage]  isEqual: ENGLISH]){
                languageSw.on = NO;
            }
        }else if(indexPath.row == 2){
            if (favNum>0) {
                UIView *favnumView = [[UIView alloc]initWithFrame:CGRectMake(_tableView.frame.size.width-35, 10, 20, 20)];
                favnumView.layer.cornerRadius = 10;
                favnumView.backgroundColor = LabColor(0.90, 0, 0);
                UILabel *favnumLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
                favnumLab.textColor = [UIColor whiteColor];
                favnumLab.textAlignment = NSTextAlignmentCenter;
                favnumLab.font = [UIFont boldSystemFontOfSize:14];
                favnumLab.text = [NSString stringWithFormat:@"%i",favNum];
                [cell addSubview:favnumView];
                [favnumView addSubview:favnumLab];
            }
        }
        iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(25, 14.5, 15, 15)];
        if (indexPath.row == 2) {
            iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(27.5, 14.5, 10, 15)];
        }
        iconImage.image = (UIImage *)[picmenu objectAtIndex:indexPath.row];
        iconImage.contentMode = UIViewContentModeScaleToFill;
        [cell.contentView addSubview:iconImage];
        [cell.contentView bringSubviewToFront:iconImage];
        UILabel *leftLab = [[UILabel alloc]initWithFrame:CGRectMake(48, 0, 150, cell.frame.size.height)];
        [cell.contentView addSubview:leftLab];
        leftLab.text = [menu objectAtIndex:indexPath.row];
        leftLab.font = [UIFont systemFontOfSize:15];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
        cell.backgroundColor = [UIColor clearColor];
        [tableView setSeparatorColor:[UIColor whiteColor]];
    }else if (tableView.tag == 2){
        NSDictionary *dict = [[NSDictionary alloc]init];
        dict = [dataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"companyname"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageview = (UIImageView *)view;
            imageview.image = (UIImage *)[picmenu objectAtIndex:indexPath.row];
        }
        else if ([view isKindOfClass:[UILabel class]]){
            UILabel *titleLab = (UILabel *)view;
            titleLab.textColor = [UIColor blackColor];
        }
    }
    if (tableView.tag == 2){
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                UIImageView *imageview = (UIImageView *)view;
                imageview.image = (UIImage *)[selectedPic objectAtIndex:indexPath.row];
            }
            else if ([view isKindOfClass:[UILabel class]]){
                UILabel *titleLab = (UILabel *)view;
                titleLab.textColor = [UIColor whiteColor];
            }
        }
        UIViewController *vc ;
        switch (indexPath.row)
        {
            case 0:
            {
                mainViewController *mv = [[mainViewController alloc]init];
                vc = mv;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
            }
                break;
                
            case 1:
            {
                ListViewController *lv = [[ListViewController alloc]init];
                vc = lv;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
            }
                break;
                
            case 2:
            {
                favNum = 0;
                [_tableView reloadData];
                FavoriteViewController *fv = [[FavoriteViewController alloc]init];
                vc = fv;
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
            }
                break;

            case 3:
            {
                NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
                if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
                    [GDLocalizableController setUserlanguage:ENGLISH];
                    [userdefault setObject:@"en" forKey:@"languageFlag"];
                }else{
                    [GDLocalizableController setUserlanguage:CHINESE];
                    [userdefault setObject:@"ch" forKey:@"languageFlag"];
                }
                activityLab.hidden=NO;
                activityBackGround.hidden=NO;
                [_aiView startAnimating];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLanguage" object:nil];
            }
                break;
            default:
                break;
        }
    }else if (tableView.tag == 2){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *dict = [[NSDictionary alloc]init];
        cell.textLabel.textColor = [UIColor whiteColor];
        dict = [dataArray objectAtIndex:indexPath.row];
        VenueViewController *venView = [[VenueViewController alloc]init];
        venView.clientid = [dict objectForKey:@"cid"];
        [[SlideNavigationController sharedInstance] pushViewController:venView animated:YES];
        [search resignFirstResponder];
        [search setShowsCancelButton:NO];
        searchTable.hidden = YES;
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
    searchTable.hidden = NO;
    for (UIView *view in [[[searchBar subviews]objectAtIndex:0]subviews]) {
        if ([view isKindOfClass:[NSClassFromString(@"UINavigationButton")class]]) { 
            UIButton *cancel = (UIButton *)view;
            [cancel setTitle: GDLocalizedString(@"CANCEL") forState:UIControlStateNormal];
            [cancel setTitleColor:LabColor(0.90, 0, 0) forState:UIControlStateNormal];
        }
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    XmlDataParser *searchdata = [[XmlDataParser alloc]init];
    NSString *string = [NSString stringWithFormat:@"http://app.enjoylist.com/search.asp?keyword=%@",searchText];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string = [string stringByAppendingString:@"&locale=zh-cn"];
    }
    [searchdata StartParse:string];
    dataArray = searchdata.dataArray;
    if (dataArray == nil) {
        
    }else{
        [searchTable reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    searchTable.hidden = YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
}

-(void)_signoutBtnClick:(UIButton *)btn{
    favNum = 0;
    [_tableView reloadData];
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:[NSNumber numberWithInt:0]forKey:@"userId"];
    [userdefaults setObject:@"0"forKey:@"flag"];
    [userdefaults setObject:@""forKey:@"cardNumber"];
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
}

-(void)switchValueChange:(UISwitch *)sw{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([sw isOn]) {
        [GDLocalizableController setUserlanguage:CHINESE];
        [userdefault setObject:@"ch" forKey:@"languageFlag"];
    }else{
        [GDLocalizableController setUserlanguage:ENGLISH];
        [userdefault setObject:@"en" forKey:@"languageFlag"];
    }
    activityLab.hidden=NO;
    activityBackGround.hidden=NO;
    [_aiView startAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLanguage" object:nil];
}

-(void)changeLanguage{
    search.placeholder = GDLocalizedString(@"SEARCH");
    menu = [NSArray arrayWithObjects:GDLocalizedString(@"HOME"),GDLocalizedString(@"POPULAR"),GDLocalizedString(@"FAVORITES"),GDLocalizedString(@"LANGUAGE"),nil];
    [_tableView reloadData];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if ([[userDefaultes stringForKey:@"flag"]isEqualToString:@"0"]) {
        loginLab.text = GDLocalizedString(@"LOGIN");
        _username.text = GDLocalizedString(@"HELLO");
    }else if([[userDefaultes stringForKey:@"flag"]isEqualToString:@"1"]){
        NSInteger UID = [userDefaultes integerForKey:@"userId"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        if([db open]){
            FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM PersonList WHERE UID = '%li'",(long)UID]];
            while([s next]){
                NSString *name = [s stringForColumn:@"NAME"];
                loginLab.text = GDLocalizedString(@"Sign Out");
                _username.text = name;
            }
            [db close];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (search.isFirstResponder) {
        [search resignFirstResponder];
        [search setShowsCancelButton:NO];
        searchTable.hidden = YES;
    }
}

-(void)changedLanguage{
    activityLab.hidden=YES;
    activityBackGround.hidden=YES;
    [_aiView stopAnimating];
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
