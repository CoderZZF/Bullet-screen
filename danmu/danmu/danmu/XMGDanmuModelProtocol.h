//
//  XMGDanmuModelProtocol.h
//  danmu
//
//  Created by zhangzhifu on 2017/4/12.
//  Copyright © 2017年 seemygo. All rights reserved.
//

@protocol XMGDanmuModelDelegate <NSObject>

@property (nonatomic, readonly) NSTimeInterval beginTime;
@property (nonatomic, readonly) NSTimeInterval liveTime;

@end
