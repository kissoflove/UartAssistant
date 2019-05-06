//
//  MainWindow.m
//  UartAssistant
//
//  Created by 李坚 on 14-8-19.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "MainWindow.h"
#import "Uart.h"


#include <termios.h>
#import "CharChangeUtil.h"

int buadRates[] = {B1200, B1800, B2400,
        B4800, B9600, B19200, B38400, B57600, B115200};

@interface MainWindow () {
    BOOL uartOpened;
    Uart *uart;
    NSThread *monitorThread;
}
- (void)initComboBox;
@end

@implementation MainWindow

- (id)init {
    if (![super initWithWindowNibName:@"MainWindow"])
        return nil;
    uart = [[Uart alloc] init];
    uartOpened = false;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:NSApp selector:@selector(terminate:) name:NSWindowWillCloseNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelectUartPort:) name:@"onSeleceUartPort" object:selectPortBtn];
    [self initComboBox];
}

- (void)initComboBox {
    for (int i = 0; i < sizeof(buadRates) / sizeof(int); i++) {
        int buda = buadRates[i];
        NSString *str = [[NSString alloc] initWithFormat:@"%d", buda];
        [bateRate addItemWithTitle:str];
    }
}

- (IBAction)changeUartState:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *) sender;
    long selected = [control selectedSegment];

    if (!uartOpened && selected == 0) {
        [self openUart];
    } else if (uartOpened && selected == 1) {
        [self closeUart];
        uartOpened = false;
    }
}

- (void)openUart {
    @try {
        UartConfig config;

        NSString *port = uartPortField.stringValue;
        config.port = [port UTF8String];

        NSString *key = [bateRate selectedItem].title;
        config.buadRate = (unsigned int) [key intValue];

        key = [dateBit selectedItem].title;
        config.dataBits = (unsigned char) [key intValue];

        key = [stopBit selectedItem].title;
        config.stopBits = (unsigned char) [key intValue];

        NSInteger index = [validBit indexOfSelectedItem];
        switch (index) {
            case 0:
                config.parity = 'N';
                break;
            case 1:
                config.parity = 'O';
                break;
            case 2:
                config.parity = 'E';
                break;
            case 3:
                config.parity = 'S';
                break;
        }

        [uart open:config];
        uartOpened = true;

        [uartPortField setEditable:false];

        monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(monitoring) object:nil];
        [monitorThread setName:@"uartMonitor"];
        [monitorThread start];
    } @catch (NSException *exception) {

        NSString *msg = [NSString stringWithFormat:@"无法打开串口 %@", uartPortField.stringValue];
        NSRunAlertPanel(@"错误", msg, @"确定", nil, nil);
        [openBtn setSelectedSegment:1];
    }
}

- (void)monitoring {
    unsigned char buff[2048];
    while (uartOpened) {
        int len = [uart readBytes:buff Len:2048];
        if (len > 0) {
            NSString *str = nil;
            if (hexShow.intValue) {
                str = [CharChangeUtil hexToString:buff Size:len];
            } else {
                str = [[NSString alloc] initWithBytes:buff length:len encoding:NSASCIIStringEncoding];
            }

            [self performSelectorOnMainThread:@selector(appendText:) withObject:str waitUntilDone:YES];
        }
    }

    [uart close];
}

- (void)appendText:(NSString *)text {
    NSLog(text);
    [outputView insertText:text];

    [recvCountField setIntValue:uart.recvCount];
}


- (void)closeUart {
    uartOpened=false;
    [uartPortField setEditable:true];
}

- (void)onSelectUartPort:(id)sender {
    NSNotification *notification = sender;

    NSString *port = [notification.userInfo objectForKey:@"port"];
    [uartPortField setStringValue:port];
}

- (IBAction)send:(id)sender {
    NSString *text = inputTextField.stringValue;

    if (hexSend.intValue) {
        unsigned char buff[2048];
        int size = [CharChangeUtil stringToHex:text Hex:buff];
        [uart sendBytes:buff Len:size];
    } else {
        [uart sendBytes:text.UTF8String Len:text.length];
    }

    [sendCountField setIntValue:uart.sendCount];
}

- (IBAction)resetCount:(id)sender {
    [uart resetCount];

    [sendCountField setIntValue:0];
    [recvCountField setIntValue:0];
}

- (IBAction)clearSendView:(id)sender {
    [inputTextField setStringValue:@""];
}

- (IBAction)clearRecvView:(id)sender {
    [outputView setString:@""];
}


- (void)close {
    [super close];
    [NSApp terminate:nil];
}

@end
