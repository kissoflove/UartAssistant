//
//  Uart.h
//  helloWorld
//
//  Created by 李坚 on 14-8-13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    const char *port;
    unsigned int buadRate;
    unsigned char dataBits;
    unsigned char stopBits;
    char parity;
} UartConfig;

@interface Uart : NSObject {
    UartConfig uartConfig;
    long sendCount;
    long recvCount;
    bool opened;
}

@property(readonly) long sendCount;

@property(readonly) long recvCount;

- (void)open:(UartConfig)config;

- (void)close;

- (void)configUart;

- (int)sendBytes:(void *)bytes Len:(int)len;

- (int)readBytes:(void *)buff Len:(int)len;

- (void)resetCount;

+ (NSArray *)getAllUartPort;


@end
