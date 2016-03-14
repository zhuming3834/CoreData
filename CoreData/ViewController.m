//
//  ViewController.m
//  CoreData
//
//  Created by myhg on 15/11/17.
//  Copyright © 2015年 zhuming. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Person+CoreDataProperties.h"
#import "Person.h"
@interface ViewController ()

@property (nonatomic,strong)NSManagedObjectContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCoreDataModel];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createCoreDataModel{
    // 1.取文件路径
    NSString * corDataPath = [[NSBundle mainBundle] pathForResource:@"Person" ofType:@"momd"];
    // 2.取出CoreData在工程中的模型
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL URLWithString:corDataPath]];
    // 3.制作一个关联层 CoreData和sqlite关联
    NSPersistentStoreCoordinator *coor = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    // 4.创建一个数据库地址
    NSString * dbPath = [NSString stringWithFormat:@"%@/Documents/data.sqlite",NSHomeDirectory()];
    NSLog(@"dbPath = %@",dbPath);
    // 5.关联层创建数据库返回的对象  创建失败store = nil
    NSPersistentStore * store = [coor addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dbPath] options:0 error:nil];
    NSLog(@"store = %@",store);
    //制作一个操作对象
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.persistentStoreCoordinator = coor;
}

/**
 *  插入数据
 */
- (void)insterData{
    Person * p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
    p1.name = [NSString stringWithFormat:@"张三%u",arc4random()%30];
    p1.age = [NSString stringWithFormat:@"%u",arc4random()%30];
    p1.height = [NSString stringWithFormat:@"1.%u",arc4random()%100];
    p1.sex = @"男";
    BOOL isInsret = [self.context save:nil];  //ret = 1插入成功
    NSLog(@"isInsret = %d",isInsret);
}
/**
 *  删除数据
 */
- (void)deleteData{ //包含查询操作
    //创建一个查询  返回结果的对象
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    //获取sqlite里面的所有对象 相当于是查询
    NSArray * dataArr = [self.context executeFetchRequest:request error:nil];
    [self.context deleteObject:dataArr[0]]; //删除一条数据  全部删除就遍历数组dataArr 逐条删除
    BOOL isDelete = [self.context save:nil];  //回写
    NSLog(@"isDelete = %d",isDelete);
}
/**
 *  修改和查询
 */
- (void)modifyData{
    //创建一个查询  返回结果的对象
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    NSArray * dataArr = [self.context executeFetchRequest:request error:nil]; //  获取数据库里面的全部数据模型
    Person * p1 = (Person *)dataArr[0];
    p1.name = @"CFire";
    BOOL isModify = [self.context save:nil]; // 修改第0个模型的姓名
    NSLog(@"isModify = %d",isModify);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name like %@",@"小明"];//查询全部名字叫小明的人
    [request setPredicate:predicate];
    NSArray * arr1 = [self.context executeFetchRequest:request error:nil];
    for (Person * p in arr1) {
        NSLog(@"name = %@",p.name);
    }
}

- (IBAction)insterData:(id)sender {
    [self insterData];
}


- (IBAction)deldte:(UIButton *)sender {
    [self deleteData];
}

- (IBAction)select:(UIButton *)sender {
    [self modifyData];
}
@end
