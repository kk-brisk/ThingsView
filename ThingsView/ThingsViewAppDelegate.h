//
//  ThingsView.h
//  ThingsView
//
//  Created by brisk on 10/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ThingsViewAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSMutableArray *projects;
    NSMutableArray *areas;
    NSMutableArray *delegates;
    IBOutlet NSTableView *tableView;
    IBOutlet NSTableView *testTable;
    IBOutlet NSArrayController *arrayController;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSPopUpButton *popupList;
    IBOutlet NSPopUpButton *popupPriority;
    IBOutlet NSPopUpButton *popupTags;
    IBOutlet NSPopUpButton *popupDelegates;
    IBOutlet NSPopUpButton *popupProjectArea;
    IBOutlet NSMenu *menuList;
    IBOutlet NSTextField *importStatusBarLabel;
    IBOutlet NSMenu *menuViewColumns;
}
- (NSDate *)dateFromEventDescriptor:(NSAppleEventDescriptor *)descriptor;
- (NSMutableArray *)createListArray:(NSAppleEventDescriptor *)descriptor;
- (NSMutableArray *)createTodayArray:(NSAppleEventDescriptor *)descriptor;
- (NSString *)getNameFromArray:(NSMutableArray *)descriptor forId: (NSString *)listId;
- (NSMutableArray *)createTodoArray:(NSAppleEventDescriptor *)descriptor forList:(NSString *)list listNumber:(NSString *)listNum;
- (void)runScriptsAndImport;
- (NSString *)convertArraytoCsv;
- (NSString *)convertArrayToString:(NSArray *)array;
- (void)updatePopupMenu:(NSPopUpButton *)popup withArray:(NSArray *)array withTitle:(NSString *)itemTitle;
- (void)updatePopupMenuProjectArea;
- (void)doubleClickHandler;
- (void)clearImportStatusLabel;
- (void)setViewColumnMenuItemState;
- (void)applicationShouldHandleReopen:(NSNotification *)aNotification hasVisibleWindows:(BOOL)flag;
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard;
@property (assign) IBOutlet NSWindow *window;
//@property (assign) IBOutlet NSTableView *tableView;
//@property (assign) IBOutlet NSArrayController *arrayController;

- (IBAction)importTodos:(id)sender;
- (IBAction)filterTable:(id)sender;
- (IBAction)filterReset:(id)sender;
- (IBAction)searchFieldSelect:(id)sender;
- (IBAction)revealInThings:(id)sender;
- (IBAction)saveAsCsv:(id)sender;
- (IBAction)searchFieldResetPopups:(id)sender;
- (IBAction)toggleColumnVisibility:(id)sender;
- (IBAction)checkListPopup:(id)sender;
- (void) copy:(id)sender;

@end
