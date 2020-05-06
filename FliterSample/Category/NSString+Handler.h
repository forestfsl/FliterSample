//
//  NSString+Handler.h
//  FliterSample
//
//  Created by apple on 2020/5/6.
//  Copyright © 2020 fly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Handler)

//移除空白
- (instancetype)sl_stringByRemovingSpace;
//分隔
- (NSArray *)sl_componentsSeparatedBySpace;

@end

NS_ASSUME_NONNULL_END
