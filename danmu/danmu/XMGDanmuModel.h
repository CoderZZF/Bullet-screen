//
//  XMGDanmuModel.h
//  danmu
//
//  Created by zhangzhifu on 2017/4/12.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMGDanmuModelProtocol.h"

@interface XMGDanmuModel : NSObject <XMGDanmuModelDelegate>

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) NSTimeInterval liveTime;

@end
