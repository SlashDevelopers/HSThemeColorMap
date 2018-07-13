//
//  AddColorViewController.m
//  HSThemeColorMap
//
//  Created by Leo on 2018/6/11.
//  Copyright © 2018年 culeo. All rights reserved.
//

#import "AddColorViewController.h"

@interface AddColorViewController ()
@property (weak) IBOutlet NSTextField *keyTextField;
@property (weak) IBOutlet NSTextField *remarkTextField;
@property (weak) IBOutlet NSTextField *whiteTextField;
@property (weak) IBOutlet NSTextField *blackTextField;
@property (weak) IBOutlet NSTextField *errorLabel;
@end

@implementation AddColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
   
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)taoAddColorButton:(id)sender
{
    NSString *key = self.keyTextField.stringValue;
    NSString *remark = self.remarkTextField.stringValue;
    NSString *white = self.whiteTextField.stringValue;
    NSString *black = self.blackTextField.stringValue;

    if (key.length < 1 || remark.length < 1 || white.length < 1 || black.length < 1) {
        self.errorLabel.stringValue = @"参数错误";
        return;
    }
    
    if (![white hasPrefix:@"#"] || ![white hasPrefix:@"#"]) {
        self.errorLabel.stringValue = @"颜色值请以#开头的";
        return;
    }
    if ((white.length != 7 && white.length != 9) || (black.length != 7 && black.length != 9)) {
        self.errorLabel.stringValue = @"颜色值错误";
        return;
    }
    
    NSArray *componenet = [key componentsSeparatedByString:@"_"];
    NSString *prefix = componenet.firstObject;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:@"kWhitePath"]) {
        self.errorLabel.stringValue = @"没有白色皮肤路径";
        return;
    }
    if (![userDefault objectForKey:@"kBlackPath"]) {
        self.errorLabel.stringValue = @"没有黑色皮肤路径";
        return;
    }
    
    NSMutableDictionary *whiteDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[userDefault objectForKey:@"kWhitePath"]];
    if (!whiteDictionary) {
        self.errorLabel.stringValue = @"白色皮肤路径有误";
        return;
    }
    NSMutableDictionary *blackDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[userDefault objectForKey:@"kBlackPath"]];
    if (!blackDictionary) {
        self.errorLabel.stringValue = @"黑色皮肤路径有误";
        return;
    }
    NSMutableDictionary *whitSub = [whiteDictionary[prefix] mutableCopy];
    NSMutableDictionary *blackSub = [blackDictionary[prefix] mutableCopy];
    if (!whitSub || !blackSub) {
        self.errorLabel.stringValue = @"key值有误";
        return;
    }
    if (whitSub[key] || blackSub[key]) {
        self.errorLabel.stringValue = @"key已存在";
        return;
    }
    {
        NSDictionary *item = @{ @"Color": white,
                                @"Remark": remark};
        whitSub[key] = item;
        whiteDictionary[prefix] = whitSub;
        [whiteDictionary writeToFile:[userDefault objectForKey:@"kWhitePath"] atomically:YES];
    }
    {
        NSDictionary *item = @{ @"Color": white,
                                @"Remark": remark};
        blackSub[key] = item;
        blackDictionary[prefix] = blackSub;
        [blackDictionary writeToFile:[userDefault objectForKey:@"kBlackPath"] atomically:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRefresh" object:nil];
    [[NSApplication sharedApplication] stopModal];
}

@end
