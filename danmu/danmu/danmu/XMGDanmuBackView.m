//
//  XMGDanmuBackView.m
//  danmu
//
//  Created by zhangzhifu on 2017/4/12.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGDanmuBackView.h"
#import "CALayer+Aimate.h"

#define kDandaoCount 5
#define kSec 0.1

@interface XMGDanmuBackView ()
{
    BOOL _isPause;
}
// 等待时间
@property (nonatomic, strong) NSMutableArray *waitTimes;
// 存活时间
@property (nonatomic, strong) NSMutableArray *liveTimes;
/** 数据等待时间 */
@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *danmuViews;
@end

@implementation XMGDanmuBackView

- (NSMutableArray *)danmuViews {
    if (!_danmuViews) {
        _danmuViews = [NSMutableArray array];
    }
    return _danmuViews;
}

- (NSMutableArray<id<XMGDanmuModelDelegate>> *)danmuMs {
    if (!_danmuMs) {
        _danmuMs = [NSMutableArray array];
    }
    return _danmuMs;
}


- (NSMutableArray *)waitTimes {
    if (!_waitTimes) {
        _waitTimes = [NSMutableArray arrayWithCapacity:kDandaoCount];
        for (int i = 0; i < kDandaoCount; i++) {
            [_waitTimes addObject:@0];
        }
    }
    return _waitTimes;
}

- (NSMutableArray *)liveTimes {
    if (!_liveTimes) {
        _liveTimes = [NSMutableArray arrayWithCapacity:kDandaoCount];
        for (int i = 0; i < kDandaoCount; i++) {
            [_liveTimes addObject:@0];
        }
    }
    return _liveTimes;
}

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:kSec target:self selector:@selector(checkData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}


- (void)didMoveToSuperview {
    [self timer];
    
    self.layer.masksToBounds = YES;
}


- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

// 每隔0.1秒执行一次
- (void)checkData {
    if (_isPause) {
        return;
    }
    
    // 给弹道的存活时间&等待时间都减去0.1
    for (int i = 0; i < kDandaoCount; i++) {
        if ([self.waitTimes[i] doubleValue] <= 0.0) {
            self.waitTimes[i] = @0;
             continue;
        }
        self.waitTimes[i] = @([self.waitTimes[i] doubleValue] - kSec);
    }
    
    for (int i = 0; i < kDandaoCount; i++) {
        if ([self.liveTimes[i] doubleValue] <= 0.0) {
            self.liveTimes[i] = @0;
            continue;
        }
        self.liveTimes[i] = @([self.liveTimes[i] doubleValue] - kSec);
    }
    
    
    // 遍历所有的弹幕模型,检测是否应该发送该条弹幕.
    // 对弹幕模型数组进行排序(begintime从小到大)
    [self.danmuMs sortUsingComparator:^NSComparisonResult(id<XMGDanmuModelDelegate>  _Nonnull obj1, id<XMGDanmuModelDelegate>  _Nonnull obj2) {
        if (obj1.beginTime < obj2.beginTime) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    NSInteger count = self.danmuMs.count;
    NSMutableArray *removeDanmuMs = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        id<XMGDanmuModelDelegate> model = self.danmuMs[i];
        
        if (model.beginTime > self.delegate.currentTime) {
            NSLog(@"没有必要继续往下执行了,因为还没有达到发送时间");
            break;
        }
        
        // 真正去做判断.
        // 弹幕发送条件:1. 开始时间 <= 当前时间
        BOOL result = [self checkAndSendDanmu:model];
        
        // 这个弹幕可以发送了.
        if (result) {
            [removeDanmuMs addObject:model];
        }
    }
    
    [self.danmuMs removeObjectsInArray:removeDanmuMs];
}


- (BOOL)checkAndSendDanmu:(id<XMGDanmuModelDelegate>)model {
    // 拿到弹幕模型放在每一个弹道里面进行对比查看是否可以发送了.
    // 2. 该弹道不应该有绝对等待时间.
    // 3. 防止追尾.(按照当前弹幕的速度,在弹幕存活时间内移动的距离应该 <= backView.width)
    
    CGFloat dandaoH = self.bounds.size.height / kDandaoCount;
    
    UIView *danmuView = [self.delegate danmuViewWithModel:model];
    
    BOOL canShow = NO;
    
    for (int i = 0; i < kDandaoCount; i++) {
        NSTimeInterval waitTime = [self.waitTimes[i] doubleValue];
        if (waitTime > 0) {
            continue;
        }
        
        // 可能可以发送.
        // 检测在剩余的存活时间内,按照当前的速度来看,会不会超过backView.width
        // 1. 计算这个弹幕的速度.
        // 距离
        CGFloat distance = self.bounds.size.width + danmuView.bounds.size.width;
        
        // livetime
        CGFloat speed = distance / model.liveTime;
        
        // 2. 计算按照当前的速度,在弹道剩余存活时间内能跑多远
        NSTimeInterval leftLiveTime = [self.liveTimes[i] doubleValue];
        CGFloat leftDistance = leftLiveTime * speed;
        
        if (leftDistance > self.bounds.size.width) {
            continue;
        }
        
        // 3. 弹幕可以被发送了.
        CGRect frame = danmuView.frame;
        frame.origin.x = self.bounds.size.width;
        frame.origin.y = i * dandaoH;
        danmuView.frame = frame;
        [self addSubview:danmuView];
        
        [self.danmuViews addObject:danmuView];
        
        [UIView animateWithDuration:model.liveTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect frame = danmuView.frame;
            frame.origin.x = -danmuView.bounds.size.width;
            danmuView.frame = frame;
        } completion:^(BOOL finished){
            [danmuView removeFromSuperview];
            [self.danmuViews removeObject:danmuView];
        }];
        
        // 4. 重置该弹道的所有参数.
        self.waitTimes[i] = @(danmuView.bounds.size.width / speed);
        self.liveTimes[i] = @(model.liveTime);
        
        canShow = YES;
        break;
    }
    
    return canShow;
}

- (void)pause {
    if (!_isPause) {
        _isPause = YES;
        [[self.danmuViews valueForKeyPath:@"layer"] makeObjectsPerformSelector:@selector(pauseAnimate)];
    };
}


- (void)resume {
    if (_isPause) {
        _isPause = NO;
        [[self.danmuViews valueForKeyPath:@"layer"] makeObjectsPerformSelector:@selector(resumeAnimate)];
    }
}

@end
