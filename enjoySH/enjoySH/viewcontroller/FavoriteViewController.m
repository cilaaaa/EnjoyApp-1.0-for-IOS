//
//  FavoriteViewController.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-23.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FMDB.h"
#import "SlideNavigationContorllerAnimator.h"
#import "VenueViewController.h"
#import "GDLocalizableController.h"
#import "UIImageView+WebCache.h"
#import "MapViewController.h"
#import "YFJLeftSwipeDeleteTableView.h"

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@interface FavoriteViewController (){
    YFJLeftSwipeDeleteTableView *_tableView;
    NSMutableArray *dataArray;
}

@end

@implementation FavoriteViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:LabColor(0.95, 0.95, 0.95)];
    // Do any additional setup after loading the view.
    [self initnav];
    [self.view setBackgroundColor:LabColor(0.95, 0.95, 0.95)];
    _tableView= [[YFJLeftSwipeDeleteTableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.bounds.size.height-64)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 0;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.tableFooterView = [[UIView alloc]init];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger Uid = [userdefaults integerForKey:@"userId"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    dataArray = [[NSMutableArray alloc]init];
    if([db open]){
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM FavoriteList WHERE UID = '%li'",(long)Uid]];
        while ([result next]){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[[result stringForColumn:@"ICONX2"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"picx2"];
            [dict setObject:[[result stringForColumn:@"NAME"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"name"];
            [dict setObject:[[result stringForColumn:@"PRICE"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"price"];
            [dict setObject:[result stringForColumn:@"SCORE"] forKey:@"score"];
            [dict setObject:[[result stringForColumn:@"EXCERPT"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"excerpt"];
            [dict setObject:[result stringForColumn:@"CID"] forKey:@"id"];
            [dataArray addObject:dict];
        }
        [db close];
        [_tableView reloadData];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (dataArray!=nil) {
        NSDictionary *_dict = [dataArray objectAtIndex:indexPath.row];
        UIImageView *clientIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        [clientIcon sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"picx2"]]];
        [cell.contentView addSubview:clientIcon];
        UIView *clientDetailView = [[UIView alloc]init];
        [cell.contentView addSubview:clientDetailView];
        UILabel *clientName = [[UILabel alloc]init];
        clientName.text = [_dict objectForKey:@"name"];
        clientName.lineBreakMode = NSLineBreakByTruncatingTail;
        clientName.numberOfLines = 1;
        clientName.font = [UIFont boldSystemFontOfSize:13];
        CGRect clientNameRect = [clientName.text boundingRectWithSize:CGSizeMake(cell.frame.size.width-90, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:clientName.font} context:nil];
        clientName.frame = CGRectMake(80, 0, clientNameRect.size.width, clientNameRect.size.height);
        [clientDetailView addSubview:clientName];
        
        NSString *stars = [_dict objectForKey:@"score"];
        NSInteger starinter = stars.doubleValue+0.5;
        NSInteger j = 0;
        for (NSInteger i=0; i<starinter ; i++) {
            UIImageView *star = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star"]];
            CGRect _frame = CGRectMake(80+i*13+i*5, 3+clientName.frame.size.height, 13, 13);
            star.frame = _frame;
            [clientDetailView addSubview:star];
            j = i;
        }
        if (j!=0) {
            j++;
        }
        for (; j<5 ; j++) {
            UIImageView *blackstar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star2"]];
            CGRect _frame = CGRectMake(80+j*13+j*5, 3+clientName.frame.size.height, 13, 13);
            blackstar.frame = _frame;
            [clientDetailView addSubview:blackstar];
        }
        
        UILabel *excerpt = [[UILabel alloc]init];
        excerpt.text = [_dict objectForKey:@"excerpt"];
        excerpt.textColor = [UIColor grayColor];
        excerpt.font = [UIFont systemFontOfSize:12];
        excerpt.numberOfLines = 0;
        excerpt.lineBreakMode = NSLineBreakByWordWrapping;
        [clientDetailView addSubview:excerpt];
        
        UILabel *pricelab = [[UILabel alloc]init];
        pricelab.font = [UIFont systemFontOfSize:12];
        pricelab.numberOfLines=1;
        pricelab.textColor = [UIColor grayColor];
        pricelab.lineBreakMode = NSLineBreakByTruncatingTail;
        NSString *priceString = [_dict objectForKey:@"price"];
        if(![priceString isEqualToString:@""]){
            priceString = [_dict objectForKey:@"price"];
            pricelab.text = priceString;
            CGRect priceRect = [priceString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:pricelab.font} context:nil];
            pricelab.frame = CGRectMake(cell.frame.size.width-priceRect.size.width-30, 22+clientName.frame.size.height-1, priceRect.size.width, priceRect.size.height);
            UIImageView *price = [[UIImageView alloc]initWithFrame:CGRectMake(pricelab.frame.origin.x-15, 22+clientName.frame.size.height, 12, 12)];
            price.image = [UIImage imageNamed:@"average"];
            [clientDetailView addSubview:price];
        }
        [clientDetailView addSubview:pricelab];
        CGRect excerptRect = [excerpt.text boundingRectWithSize:CGSizeMake(pricelab.frame.origin.x-115, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:excerpt.font} context:nil];
        CGRect newframe = excerpt.frame;
        newframe.origin.x = 95;
        newframe.origin.y = 22+clientName.frame.size.height-1;
        newframe.size.width = excerptRect.size.width;
        newframe.size.height = excerptRect.size.height;
        excerpt.frame = newframe;
        UIImageView *cuisine = [[UIImageView alloc]initWithFrame:CGRectMake(80, 22+clientName.frame.size.height, 12, 12)];
        cuisine.image = [UIImage imageNamed:@"cuisine"];
        [clientDetailView addSubview:cuisine];
        clientDetailView.frame = CGRectMake(0, (80-6-clientName.frame.size.height-13-excerpt.frame.size.height)/2, self.view.frame.size.width, 6+clientName.frame.size.height+13+excerpt.frame.size.height);
        
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(10, 79, self.view.frame.size.width-20, 1)];
        line.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [cell.contentView addSubview:line];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VenueViewController *venueView = [[VenueViewController alloc]init];
    venueView.clientid = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:venueView animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        if([db open]){
            [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM FavoriteList WHERE CID = '%li'",(long)[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]]];
            [db close];
            [dataArray removeObjectAtIndex:[indexPath row]];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
            [tableView setEditing:NO animated:YES];
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return GDLocalizedString(@"DELETE");
}

-(void)initnav{
    UIButton *left  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
    [left setImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    [left addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIButton *rightbutton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightbutton setExclusiveTouch:YES];
    [rightbutton setImage:[UIImage imageNamed:@"nearbywhite"] forState:UIControlStateNormal];
    [rightbutton addTarget:self action:@selector(dingwei)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbutton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIView *Statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    Statusview.backgroundColor = LabColor(0.89,0,0);
    [self.view addSubview:Statusview];
    
    [self.navigationItem setTitle:GDLocalizedString(@"FAVORITES")];
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dingwei{
    MapViewController *mapView = [[MapViewController alloc]init];
    [self.navigationController pushViewController:mapView animated:YES];
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
