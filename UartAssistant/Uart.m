//
//  Uart.m
//  helloWorld
//
//  Created by 李坚 on 14-8-13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "Uart.h"

#include <fcntl.h>
#include <unistd.h>
#include <sys/errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <termios.h>

#define MAJOR(dev)    ((dev)>>24)
#define MINOR(dev)    ((dev) & 0xff)

@implementation Uart {
    int fd;
}

@synthesize recvCount;

@synthesize sendCount;

- (id)init {
    self = [super init];
    if (self) {
        sendCount = 0;
        recvCount = 0;
        opened = false;
    }

    return self;
}


- (void)open:(UartConfig)config {
    uartConfig = config;

    fd = open(uartConfig.port, O_RDWR | O_NOCTTY | O_NDELAY);
    if (-1 == fd) {
        NSString *info = [[NSString alloc] initWithFormat:@"unable open uart port:%s,error:%s",
                                                          uartConfig.port, strerror(errno)];
        @throw [[NSException alloc] initWithName:@"open Uart Error" reason:@"unable open port" userInfo:[NSDictionary dictionaryWithObject:info forKey:@"message"] ];
    }

    if (fcntl(fd, F_SETFL, 0) < 0) {
        @throw [[NSException alloc] initWithName:@"fcntl failed!" reason:@"fcntl failed!" userInfo:nil];
    }

    if (isatty(fd) == 0) {
        @throw [[NSException alloc] initWithName:@"standard input is not a terminal device!"
                                          reason:@"isatty" userInfo:nil];
    }
    fcntl(fd, F_SETFL, 0);
    [self configUart];
}

- (void)close {
    if (fd != 0) {
        close(fd);
        fd = 0;
    }
}

- (void)configUart {

    fd = open(uartConfig.port, O_RDWR | O_NOCTTY | O_NDELAY);

    struct termios newtio, oldtio;
    if (tcgetattr(fd, &oldtio) != 0) {
        @throw [[NSException alloc] initWithName:@"uart get attr error" reason:@"tcgetattr" userInfo:nil];
    }
    bzero(&newtio, sizeof( newtio ));
    newtio.c_cflag |= CLOCAL | CREAD;
    newtio.c_cflag &= ~CSIZE;

    switch (uartConfig.dataBits) {
        case 7:
            newtio.c_cflag |= CS7;
            break;
        case 8:
            newtio.c_cflag |= CS8;
            break;
    }

//    switch (uartConfig.parity) {
//            NSLog(@"parity is:%c",uartConfig.parity);
//        case 'O':
//            newtio.c_cflag |= PARENB;
//            newtio.c_cflag |= PARODD;
//            newtio.c_iflag |= (INPCK | ISTRIP);
//            break;
//        case 'E':
//            newtio.c_iflag |= (INPCK | ISTRIP);
//            newtio.c_cflag |= PARENB;
//            newtio.c_cflag &= ~PARODD;
//            break;
//        case 'N':
//            newtio.c_cflag &= ~PARENB;
//            break;
//    }
    
    
    switch (uartConfig.parity) {
        case 'O':
            newtio.c_cflag |= (PARODD | PARENB); /* 设置为奇效验*/
            newtio.c_iflag |= INPCK; /* Disnable parity checking */
            break;
        case 'E':
            newtio.c_cflag |= PARENB; /* Enable parity */
            newtio.c_cflag &= ~PARODD; /* 转换为偶效验*/
            newtio.c_iflag |= INPCK; /* Disnable parity checking */
            break;
        case 'N':
            newtio.c_cflag &= ~PARENB; /* Clear parity enable */
            newtio.c_iflag &= ~INPCK; /* Enable parity checking */
            break;
    }

    cfsetispeed(&newtio, uartConfig.buadRate);
    cfsetospeed(&newtio, uartConfig.buadRate);

    if (uartConfig.stopBits == 1)
        newtio.c_cflag &= ~CSTOPB;
    else if (uartConfig.stopBits == 2)
        newtio.c_cflag |= CSTOPB;
    newtio.c_cc[VTIME] = 1;
    newtio.c_cc[VMIN] = 0;
    tcflush(fd, TCIFLUSH);
    if ((tcsetattr(fd, TCSANOW, &newtio)) != 0) {
        @throw [[NSException alloc] initWithName:@"uart set attr error" reason:@"tcsetattr" userInfo:nil];
    }
    newtio.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG); /*Input*/
    newtio.c_oflag &= ~OPOST;   /*Output*/
}

- (int)sendBytes:(void *)bytes Len:(int)len {
    if(fd<=0){
        return 0;
    }

    int ret = 0;
    ret = (int) write(fd, bytes, len);
    if (ret < 0) {
        @throw [NSException exceptionWithName:@"sendException" reason:@"uart send" userInfo:nil];
    }
    sendCount += ret;
    return ret;
}

- (int)readBytes:(void *)buff Len:(int)len {
    if(fd<=0){
        return 0;
    }

    int ret = (int)read(fd, buff, len);
    if (ret < 0) {
        @throw [NSException exceptionWithName:@"recv Exception" reason:@"recv send" userInfo:nil];
    }
    recvCount += ret;
    return ret;
}

- (void)resetCount {
    sendCount=0;
    recvCount=0;
}


+ (NSArray *)getAllUartPort {
    NSMutableArray *uarts = [NSMutableArray arrayWithCapacity:5];

    NSString *path = @"/dev/";
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDIR;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDIR] || !isDIR) {
        NSLog(@"path %@ not invalidate", path);
        return uarts;
    }

    NSArray *subFiles = [fileManager subpathsAtPath:path];

    for (NSString *file in subFiles) {
        if (![file hasPrefix:@"tty"]) {
            continue;
        }

        NSString *fullPath = [[NSString alloc] initWithFormat:@"/dev/%@", file];
        NSError *error;
        NSDictionary *attr = [fileManager attributesOfItemAtPath:fullPath error:&error];

        NSNumber *dev = [attr objectForKey:@"NSFileDeviceIdentifier"];

        struct stat m_stat;
        stat([fullPath UTF8String], &m_stat);
        int major = MAJOR([dev intValue]);

        NSLog(@"%@, dev:%@,rdev:%d,major:%d",fullPath,dev,m_stat.st_rdev,major);

        if (major == 17 || major == 33) {
//            NSLog(@"%@", fullPath);
            [uarts addObject:fullPath];
        }
    }

    return uarts;
}
@end
