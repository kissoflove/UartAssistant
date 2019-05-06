//
//  MainWindow.h
//  UartAssistant
//
//  Created by 李坚 on 14-8-19.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindow : NSWindowController {
    IBOutlet NSTextField *uartPortField;
    IBOutlet NSPopUpButton *bateRate;
    IBOutlet NSPopUpButton *dateBit;
    IBOutlet NSPopUpButton *stopBit;
    IBOutlet NSPopUpButton *validBit;
    IBOutlet NSTextView *outputView;
    IBOutlet NSTextField *inputTextField;

    IBOutlet NSTextField *recvCountField;
    IBOutlet NSTextField *sendCountField;

    IBOutlet NSSegmentedControl *openBtn;
    IBOutlet NSButton *hexShow;
    IBOutlet NSButton *hexSend;

    IBOutlet NSButton *selectPortBtn;

    NSMenu *menu;
}

- (IBAction)changeUartState:(id)sender;

- (IBAction)send:(id)sender;

- (IBAction)resetCount:(id)sender;

- (IBAction)clearSendView:(id)sender;

- (IBAction)clearRecvView:(id)sender;

- (void)openUart;

- (void)closeUart;

- (void)monitoring;

- (void)appendText:(NSString *)text;

@end
