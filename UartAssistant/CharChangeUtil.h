//
// Created by 李坚 on 14-8-19.
// Copyright (c) 2014 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CharChangeUtil : NSObject
+ (int) stringToHex:(NSString *)str Hex:(unsigned char*) hex;

+ (NSString *) hexToString:(unsigned char*) hex Size:(int) size;

@end