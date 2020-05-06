//
//  NSString+Handler.m
//  FliterSample
//
//  Created by apple on 2020/5/6.
//  Copyright © 2020 fly. All rights reserved.
//

#import "NSString+Handler.h"

@implementation NSString (Handler)


- (instancetype)sl_stringByRemovingSpace{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}


- (NSArray *)sl_componentsSeparatedBySpace
{
    if (self.sl_stringByRemovingSpace.length == 0) return nil;
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
