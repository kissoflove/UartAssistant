//
//  AppDelegate.m
//  UartAssistant
//
//  Created by 李坚 on 14-5-28.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (!mainWin) {
        mainWin=[[MainWindow alloc] init];
    }
    
    [mainWin showWindow:nil];
}

@end
