//
//  ViewController.h
//  HSThemeColorMap
//
//  Created by Leo on 2018/5/17.
//  Copyright © 2018年 culeo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *whitePathTextField;
@property (weak) IBOutlet NSTextField *blackPathTextField;

@end

