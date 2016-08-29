//
//  ViewController.m
//  PYsousuo
//
//  Created by Apple on 16/7/18.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "MyTableViewCell.h"
#import "UserDTO.h"
#import "NSString+pinyin.h"
@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) NSMutableArray *PYmoxingArray;
@property(nonatomic, strong) NSMutableArray *PYsousuoArray;
@property(nonatomic, assign) BOOL isPYsousuo;//搜索状态
@end

@implementation ViewController

- (NSMutableArray *)PYmoxingArray {
    if (_PYmoxingArray == nil) {
        _PYmoxingArray = [NSMutableArray array];
    }
    return _PYmoxingArray;
}
- (NSMutableArray *)PYsousuoArray {
    if (_PYsousuoArray == nil) {
        _PYsousuoArray = [NSMutableArray array];
    }
    return _PYsousuoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    _textField.tintColor = [UIColor clearColor];//隐藏光标
    

    [self setupUI];
    [self loadData];
}

#pragma mark ======= 加载UI
- (void)setupUI {
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;

    self.myTableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    //通知中心 1  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)loadData {
    NSArray *nameArr = @[@"中国",@"上海",@"浦江",@"三鲁公路",@"传智播客",@"屌炸天",@"训练营",@"iOS2期",@"PanJinLian",@"三鲁公路1239号"];
    for (int i = 0; i < nameArr.count; i++) {
        UserDTO *userDTO = [[UserDTO alloc] init];
        
        //转拼音
        NSString *Pinyin =[nameArr[i] transformToPinyin];
        //首字母
        NSString *FirstLetter = [nameArr[i] transformToPinyinFirstLetter];
        userDTO.name = nameArr[i];
        userDTO.namePinYin = Pinyin;
        userDTO.nameFirstLetter = FirstLetter;
        
        [self.PYmoxingArray addObject:userDTO];
    }
    [self.myTableView reloadData];
    NSLog(@"%@", self.PYmoxingArray);

}

#pragma mark ======= 通知中心监听 2
- (void)textChange:(NSNotification *)tion {
    UITextField *textField = (UITextField *)[tion object];
    [self srartSearch:textField.text];
}
//开始搜索 3
- (void)srartSearch:(NSString *)string {
    //button内复制进来  4
    NSString *key = self.textField.text.lowercaseString;//小写字母
    if (![key isEqualToString:@""] && ![key isEqual:[NSNull null]] && key != nil) {
        
    } else {
        //输入框内为空,改变为未搜索状态,刷新UI
        _isPYsousuo = NO;
        [_myTableView reloadData];

    }
}

#pragma mark ======= 点击事件
- (IBAction)PYsousuoButton:(UIBarButtonItem *)sender {

    if (self.PYsousuoArray.count > 0) {
        [self.PYsousuoArray removeAllObjects];
    }
    
    //开始搜索
    NSString *key = self.textField.text.lowercaseString;//小写字母
    NSMutableArray *tempArr = [NSMutableArray array];
    
    if (![key isEqualToString:@""] && ![key isEqual:[NSNull null]] && key != nil) {
        
        [self.PYmoxingArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UserDTO *userDTO = self.PYmoxingArray[idx];
            
            NSString *name = userDTO.name.lowercaseString;
            NSString *namePinyin = userDTO.namePinYin.lowercaseString;
            NSString *nameFirstLetter = userDTO.nameFirstLetter.lowercaseString;
            
            NSRange range_1 = [name rangeOfString:key];
            if (range_1.length > 0) {
                [tempArr addObject:userDTO];
            } else {
                if ([nameFirstLetter containsString:key]) {
                    [tempArr addObject:userDTO];
                } else {
                    if ([namePinyin containsString:key]) {
                        [tempArr addObject:userDTO];
                    }
                }
            }
        }];
        
        [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.PYsousuoArray containsObject:tempArr[idx]]) {
                [self.PYsousuoArray addObject:tempArr[idx]];
            }
        }];
        self.isPYsousuo = YES;
    } else {
        self.isPYsousuo = NO;
    }
    [self.myTableView reloadData];
}


#pragma mark ===== tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //如果想自定义更多，就把noResultLab 换成一个大的BJView，里面再填充很多个小的控件

    UILabel *noResultLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    noResultLab.font = [UIFont systemFontOfSize:20];
    noResultLab.textColor = [UIColor lightGrayColor];
    noResultLab.textAlignment = NSTextAlignmentCenter;
    noResultLab.hidden = YES;
    noResultLab.text = @"抱歉! 没有搜索到相关内容";
    tableView.backgroundView = noResultLab;

    if (_isPYsousuo) {
        
        if (self.PYsousuoArray.count > 0) {
            noResultLab.hidden = YES;
            return self.PYsousuoArray.count;
        } else {
            noResultLab.hidden = NO;
            return 0;
        }
        
    } else {
        return self.PYmoxingArray.count;
    }
}
//分区个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//页眉
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"页眉";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifierCell = @"cell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell forIndexPath:indexPath];

    UserDTO *userDTO = nil;
    if (_isPYsousuo) {
        userDTO = self.PYsousuoArray[indexPath.row];
    } else {
        userDTO = self.PYmoxingArray[indexPath.row];
    }
    cell.nameLabel.text = userDTO.name;
    return cell;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
