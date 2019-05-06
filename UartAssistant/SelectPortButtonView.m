//
//  SelectPortButtonView.m
//  UartAssistant
//
//  Created by 李坚 on 14-8-21.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "SelectPortButtonView.h"
#import "Uart.h"

@implementation SelectPortButtonView

-(void)mouseUp:(NSEvent *)theEvent{
    NSLog(@"mouseUP,%@",theEvent);
    [super mouseUp:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent{
    NSLog(@"mouseDown,%@",theEvent);
    [super mouseDown:theEvent];

    NSArray *uartPorts= [Uart getAllUartPort];

    NSMenu *mContextualMenu = [[NSMenu alloc] initWithTitle:@"Menu Title"];
    NSMenuItem *menuItem;
    for (int i = 0; i < uartPorts.count; i++) {
        menuItem = [[NSMenuItem alloc] initWithTitle:[uartPorts objectAtIndex:i] action:@selector(onSelectedMenuItem:) keyEquivalent:@""];
        [mContextualMenu addItem:menuItem];
    }
    [NSMenu popUpContextMenu:mContextualMenu withEvent: theEvent forView:self withFont: [NSFont menuFontOfSize: 11]];
}

-(void) onSelectedMenuItem:(id)sender{
    NSMenuItem *item=sender;
    NSLog(@"onSelectedMenuItem:%@",item.title);

    NSDictionary* userInfo= [NSDictionary dictionaryWithObject:item.title forKey:@"port"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onSeleceUartPort" object:self userInfo:userInfo];
}

@end
