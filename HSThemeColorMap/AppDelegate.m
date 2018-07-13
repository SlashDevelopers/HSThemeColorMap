//
//  AppDelegate.m
//  HSThemeColorMap
//
//  Created by Leo on 2018/5/17.
//  Copyright © 2018年 culeo. All rights reserved.
//

#import "AppDelegate.h"
#import "AddColorViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (IBAction)tapAddColorItem:(id)sender
{
    NSWindowController *windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AddColorWindow"];
    NSWindow *window = windowController.window;
    [[NSApplication sharedApplication] runModalForWindow:window];
    [window close];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
