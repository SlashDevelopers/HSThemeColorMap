//
//  ViewController.m
//  HSThemeColorMap
//
//  Created by Leo on 2018/5/17.
//  Copyright © 2018年 culeo. All rights reserved.
//

#import "ViewController.h"
#import "NSColor+Ex.h"

static NSString *const kWhiteColorCell = @"kWhiteColorCell";
static NSString *const kBlackColorCell = @"kBlackColorCell";
static NSString *const kWhiteValueCell = @"kWhiteValueCell";
static NSString *const kBlackValueCell = @"kBlackValueCell";
static NSString *const kTitleCell = @"kTitleCell";

@interface ViewController ()

@property(nonatomic, copy)NSArray *whiteDatas;
@property(nonatomic, copy)NSArray *blackDatas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.whitePathTextField.delegate = self;
    self.blackPathTextField.delegate = self;
    [self.tableView setDoubleAction:@selector(tableDoubleClick:)];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"kWhitePath"]) {
        self.whitePathTextField.stringValue = [userDefault objectForKey:@"kWhitePath"];
    }
    if ([userDefault objectForKey:@"kBlackPath"]) {
         self.blackPathTextField.stringValue = [userDefault objectForKey:@"kBlackPath"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapRefreshButton:) name:@"kRefresh" object:nil];
    [self tapRefreshButton:nil];
}

- (void)tableDoubleClick:(id)sender
{
    NSInteger rowNumber = [self.tableView clickedRow];
    NSDictionary *info = self.whiteDatas[rowNumber];
    NSString *value = [NSString stringWithFormat:@"@\"%@\"", info[@"key"]];
    [[NSPasteboard generalPasteboard]  clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[value]];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.whiteDatas.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSView *cell;
    NSDictionary *whiteInfo = self.whiteDatas[row];
    
    if (tableColumn == tableView.tableColumns[0]) {
        NSString *identifier = kWhiteColorCell;
        NSTableCellView *colorCell = [tableView makeViewWithIdentifier:identifier owner:nil];
        NSColorWell *well = [colorCell viewWithTag:100];
        well.color = [NSColor colorWithHexString:whiteInfo[@"color"]];
        cell = colorCell;
    }
    else if (tableColumn == tableView.tableColumns[1]) {
        NSString *identifier = kWhiteValueCell;
        NSTableCellView *valueCell = [tableView makeViewWithIdentifier:identifier owner:nil];
        valueCell.textField.stringValue = whiteInfo[@"color"];
        cell = valueCell;
    }
    else if (tableColumn == tableView.tableColumns[2]) {
        NSDictionary *blackInfo = self.blackDatas[row];
        NSString *identifier = kBlackColorCell;
        NSTableCellView *colorCell = [tableView makeViewWithIdentifier:identifier owner:nil];
        NSColorWell *well = [colorCell viewWithTag:100];
        well.color = [NSColor colorWithHexString:blackInfo[@"color"]];
        cell = colorCell;
    }
    else if (tableColumn == tableView.tableColumns[3]) {
        NSDictionary *blackInfo = self.blackDatas[row];
        NSString *identifier = kBlackValueCell;
        NSTableCellView *valueCell = [tableView makeViewWithIdentifier:identifier owner:nil];
        valueCell.textField.stringValue = blackInfo[@"color"];
        cell = valueCell;
    }
    else {
        NSString *identifier = kTitleCell;
        NSTableCellView *titleCell = [tableView makeViewWithIdentifier:identifier owner:nil];
        titleCell.textField.stringValue = whiteInfo[@"title"];
        cell = titleCell;
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSDictionary *info = self.whiteDatas[row];
    NSString *value = [NSString stringWithFormat:@"@\"%@\"", info[@"key"]];
    [[NSPasteboard generalPasteboard]  clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[value]];
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSLog(@"%@", self.whitePathTextField.stringValue);
    [self tapRefreshButton:nil];
}

- (IBAction)tapRefreshButton:(id)sender {
    NSString *whitePath = self.whitePathTextField.stringValue;
    NSString *blackPath = self.blackPathTextField.stringValue;
    self.whiteDatas = [self readWithFilePath:whitePath];
    self.blackDatas = [self readWithFilePath:blackPath];
    if (self.whiteDatas.count != self.blackDatas.count) {
        self.whiteDatas = @[];
        self.blackDatas = @[];
    }
    [self.tableView reloadData];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([whitePath isEqualToString:[userDefault objectForKey:@"kWhitePath"]] &&
        [blackPath isEqualToString:[userDefault objectForKey:@"kBlackPath"]]) {
        return;
    }
    
    if (whitePath.length != 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:whitePath] &&
        blackPath.length != 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:blackPath] ) {

        ChmodFileWithElevatedPrivilegesFromLocation(whitePath);
        ChmodFileWithElevatedPrivilegesFromLocation(blackPath);

        [userDefault setObject:whitePath forKey:@"kWhitePath"];
        [userDefault setObject:blackPath forKey:@"kBlackPath"];
        
        [userDefault synchronize];
    }
}

- (NSArray *)readWithFilePath:(NSString *)filePath
{
    BOOL isFile = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isFile) {
        return @[];
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (!dictionary) {
        return @[];
    }
    NSArray *datas = [self decodingData:dictionary key:nil];
    datas = [datas sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *s0 = obj1[@"title"];
        NSString *s1 = obj2[@"title"];
        return [s0 localizedCompare: s1];
    }];
    return datas;
}

- (NSArray *)decodingData:(NSDictionary *)dicrionary key:(NSString *)key
{
    __block BOOL hasSub = NO;
    [dicrionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            hasSub = YES;
            *stop = YES;
        }
    }];
    NSMutableArray *mutableArray = [NSMutableArray array];
    if (hasSub) {
        [dicrionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSArray *subArray = [self decodingData:obj key:key];
                [mutableArray addObjectsFromArray:subArray];
            }
        }];
    }
    else {
        if (!key) {
            return @[];
        }
        if (!dicrionary[@"Remark"]) {
            return @[];
        }
        [mutableArray addObject: @{ @"key" : key,
                                    @"title" : dicrionary[@"Remark"],
                                    @"color" : dicrionary[@"Color"], } ];
    }
    return mutableArray;
}


bool ChmodFileWithElevatedPrivilegesFromLocation(NSString *location)
{
    // Create authorization reference
    OSStatus status;
    AuthorizationRef authorizationRef;
    
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
    if (status != errAuthorizationSuccess)
    {
        NSLog(@"Error Creating Initial Authorization: %d", status);
        return NO;
    }
    
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
    
    status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess)
    {
        NSLog(@"Copy Rights Unsuccessful: %d", status);
        return NO;
    }
    
    // use chmod
    char *tool = "/bin/chmod";
    char *args[] = {"777", (char *)[location UTF8String], NULL};
    FILE *pipe = NULL;
    status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
    if (status != errAuthorizationSuccess)
    {
        NSLog(@"Error: %d", status);
        return NO;
    }
    
    status = AuthorizationFree(authorizationRef, kAuthorizationFlagDestroyRights);
    return YES;
}

@end
