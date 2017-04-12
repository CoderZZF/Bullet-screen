//
//  XMGDanmuBackView.h
//  danmu
//
//  Created by zhangzhifu on 2017/4/12.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMGDanmuModelProtocol.h"

@protocol XMGDanmuBackViewDelegate <NSObject>

@property (nonatomic, readonly) NSTimeInterval currentTime;

- (UIView *)danmuViewWithModel:(id<XMGDanmuModelDelegate>)model;

@end

@interface XMGDanmuBackView : UIView

@property (nonatomic, weak) id<XMGDanmuBackViewDelegate> delegate;
/**数据源 */
@property (nonatomic, strong) NSMutableArray<id<XMGDanmuModelDelegate>> *danmuMs;

- (void)pause;
- (void)resume;

@end
