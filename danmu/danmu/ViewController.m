//
//  ViewController.m
//  danmu
//
//  Created by zhangzhifu on 2017/4/12.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "ViewController.h"
#import "XMGDanmuBackView.h"
#import "XMGDanmuModel.h"

@interface ViewController ()<XMGDanmuBackViewDelegate>
@property (nonatomic, weak) XMGDanmuBackView *danmuBackView;
@end

@implementation ViewController

- (NSTimeInterval)currentTime {
    static NSTimeInterval _currentTime = 0;
    _currentTime += 0.1;
    return _currentTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    XMGDanmuBackView *backView = [[XMGDanmuBackView alloc] initWithFrame:CGRectMake(50, 200, 300, 300)];
    self.danmuBackView = backView;
    self.danmuBackView.backgroundColor = [UIColor brownColor];
    
    [self.view addSubview:backView];
    
    backView.delegate = self;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    XMGDanmuModel *model1 = [XMGDanmuModel new];
    model1.beginTime = 1.2;
    model1.liveTime = 3;
    model1.title = @"hello world";
    
    XMGDanmuModel *model2 = [XMGDanmuModel new];
    model2.beginTime = 1;
    model2.liveTime = 4;
    model2.title = @"你好,世界";
    
    [self.danmuBackView.danmuMs addObjectsFromArray:@[model1, model2]];
}

- (UIView *)danmuViewWithModel:(XMGDanmuModel *)model {
    NSString *title = model.title;
    UILabel *label = [UILabel new];
    label.text = title;
    [label sizeToFit];
    return label;
}


- (IBAction)pause:(id)sender {
    [self.danmuBackView pause];
}


- (IBAction)resume:(id)sender {
    [self.danmuBackView resume];
}

@end
