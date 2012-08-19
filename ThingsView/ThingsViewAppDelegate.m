//
//  ThingsViewAppDelegate.m
//  ThingsView
//
//  Created by brisk on 10/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import "ThingsViewAppDelegate.h"

@implementation ThingsViewAppDelegate

@synthesize window;

# pragma mark - Init

+ (void)initialize
{    
    /* App default preferences */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *objects = [NSArray arrayWithObjects:@"YES",@"NO",@"NO", nil];
    NSArray *keys = [NSArray arrayWithObjects:@"csvHeader", @"doubleclickEditShow", @"logbookImport", nil];
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObjects:objects forKeys:keys];
    [defaults registerDefaults:appDefaults];
}

- (void)awakeFromNib
{
	[tableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
	[tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [tableView registerForDraggedTypes: [NSArray arrayWithObjects: NSPasteboardTypeString, nil]];
    [tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [tableView setDoubleAction:@selector(doubleClickHandler)];
    [self setViewColumnMenuItemState];
    [self runScriptsAndImport];    
}

# pragma mark - Import Methods

- (void)runScriptsAndImport
{
    NSAppleScript *script;
    NSAppleEventDescriptor *descriptor;
    NSMutableArray *todayIds;
    NSMutableArray *tags;
    NSMutableArray *todos;
    
    [importStatusBarLabel setStringValue:@"Importing..."];
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set projectsProperties to properties of every project\n"
              "end tell\n"
              "return projectsProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    projects = [[[NSMutableArray alloc]initWithArray:[self createListArray:descriptor]]autorelease];
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set areasProperties to properties of every area\n"
              "end tell\n"
              "return areasProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    areas = [[[NSMutableArray alloc]initWithArray:[self createListArray:descriptor]]autorelease];
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set delegateProperties to properties of every person\n"
              "end tell\n"
              "return delegateProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    delegates = [[[NSMutableArray alloc]initWithArray:[self createListArray:descriptor]]autorelease];
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set tagProperties to properties of every tag\n"
              "end tell\n"
              "return tagProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    tags = [[[NSMutableArray alloc]initWithArray:[self createListArray:descriptor]]autorelease];
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set todayIds to id of every to do in list \"Today\"\n"
              "end tell\n"
              "return todayIds\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    todayIds = [[[NSMutableArray alloc]initWithArray:[self createTodayArray:descriptor]]autorelease];
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set todoProperties to properties of every to do in list \"Next\"\n"
              "end tell\n"
              "return todoProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    todos = [[[NSMutableArray alloc]initWithArray:[self createTodoArray:descriptor forList:@"Next" listNumber:@"2"]]autorelease];
    
    for (NSMutableDictionary *todo in todos){
        for (NSString *todayId in todayIds){
            if ([[todo objectForKey:@"id"] isEqualToString:todayId]){
                [todo setObject:@"Today" forKey:@"list"];
                [todo setObject:@"1" forKey:@"listnumber"];
            }
        }        
    }
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set todoProperties to properties of every to do in list \"Scheduled\"\n"
              "end tell\n"
              "return todoProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    [todos addObjectsFromArray:[self createTodoArray:descriptor forList:@"Scheduled" listNumber:@"3"]];
    
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set todoProperties to properties of every to do in list \"Someday\"\n"
              "end tell\n"
              "return todoProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    [todos addObjectsFromArray:[self createTodoArray:descriptor forList:@"Someday" listNumber:@"4"]];
   
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set todoProperties to properties of every to do in list \"Inbox\"\n"
              "end tell\n"
              "return todoProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    [todos addObjectsFromArray:[self createTodoArray:descriptor forList:@"Inbox" listNumber:@"0"]];
    
    /* Check user defaults for logbook import preference */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"logbookImport"]){
    script = [[NSAppleScript alloc] initWithSource:@"\ntell application \"Things\"\n"
              "set todoProperties to properties of every to do in list \"Logbook\"\n"
              "end tell\n"
              "return todoProperties\n"];
    descriptor = [script executeAndReturnError:nil];
    [script release];
    [todos addObjectsFromArray:[self createTodoArray:descriptor forList:@"Logbook" listNumber:@"5"]];
    }
    
    [self updatePopupMenu:popupTags withArray:tags withTitle:@"All Tags"];
    [self updatePopupMenu:popupDelegates withArray:delegates withTitle:@"All People"];
    [self updatePopupMenuProjectArea];
    [arrayController setContent:todos];
    
    [importStatusBarLabel setStringValue:@"Importing...Done."];
    /* Remove import message after 3 seconds */
    [self performSelector:@selector(clearImportStatusLabel) withObject:nil afterDelay:3];
}

- (NSMutableArray *)createListArray:(NSAppleEventDescriptor *)descriptor
{
    NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
    NSInteger descriptorCount = [descriptor numberOfItems];
    NSDictionary *dict;
    NSString *listName;
    NSString *listId;
    int i;
    for ( i=1; i<=descriptorCount; i++) {
        listName = [[[descriptor descriptorAtIndex:i]descriptorForKeyword:'pnam']stringValue];
        listId = [[[descriptor descriptorAtIndex:i] descriptorForKeyword:'ID  ']stringValue];
        dict = [NSDictionary dictionaryWithObjectsAndKeys: listName, @"name", listId, @"id", nil];
        [array addObject:dict];
    }
    return array;
}

- (NSMutableArray *)createTodayArray:(NSAppleEventDescriptor *)descriptor
{
    NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
    NSInteger descriptorCount = [descriptor numberOfItems];
    NSString *todayId;
    int i;
    for ( i=1; i<=descriptorCount; i++) {
        todayId = [[descriptor descriptorAtIndex:i]stringValue];
        [array addObject:todayId];
    }
    return array;
}

- (NSString *)getNameFromArray:(NSMutableArray *)array forId: (NSString *)listId
{
    NSString *listName = @"";
    NSString *idToCheck;
    for (NSDictionary *record in array){
        idToCheck = [record objectForKey:@"id"];
        if ([listId isEqualToString:idToCheck]){
            listName = [record objectForKey:@"name"];
            break; /* Exit loop */          
        }
    } 
    return listName;
}

- (NSMutableArray *)createTodoArray:(NSAppleEventDescriptor *)descriptor forList:(NSString *)list listNumber:(NSString *)listNum
{
    NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
    NSInteger descriptorCount = [descriptor numberOfItems];
    NSString *theName;
    NSString *theId;
    NSString *theTag;
    NSString *thePriority;
    NSString *thePriorityNum;
    NSString *theStatus;
    NSString *theNote;
    NSString *theProjectAreaName;
    NSString *theProjectAreaType;
    NSString *theDelegateName;
    NSMutableDictionary *dict;
    NSAppleEventDescriptor *descriptorCreateDate;
    NSAppleEventDescriptor *descriptorDueDate;
    NSAppleEventDescriptor *descriptorSchedDate;
    NSAppleEventDescriptor *descriptorCompDate;
    NSAppleEventDescriptor *descriptorProject;
    NSAppleEventDescriptor *descriptorArea;
    NSAppleEventDescriptor *descriptorDelegate;
    NSDate *createDate = nil;
    int x;
    
    for ( x=1; x<=descriptorCount; x++) {
        NSString *theProjectID = @"";
        NSString *theAreaID = @"";
        NSString *theDelegateID = @"";
        NSDate *dueDate;
        NSDate *schedDate;
        NSDate *compDate;

        theName = [[[descriptor descriptorAtIndex:x]descriptorForKeyword:'pnam']stringValue];
        theId = [[[descriptor descriptorAtIndex:x]descriptorForKeyword:'ID  ']stringValue]; 
        theTag = [[[descriptor descriptorAtIndex:x]descriptorForKeyword:'tnam']stringValue]; 
        theStatus = [[[descriptor descriptorAtIndex:x]descriptorForKeyword:'tdst']stringValue];
        theNote = [[[descriptor descriptorAtIndex:x]descriptorForKeyword:'note']stringValue];
        descriptorCreateDate = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'cred'];
        createDate = [self dateFromEventDescriptor:descriptorCreateDate];
        descriptorDueDate = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'dued'];
        dueDate = [self dateFromEventDescriptor:descriptorDueDate];
        descriptorSchedDate = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'actd'];
        schedDate = [self dateFromEventDescriptor:descriptorSchedDate];
        descriptorCompDate = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'cmpd'];
        compDate = [self dateFromEventDescriptor:descriptorCompDate];
        descriptorProject = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'tspt'];
        theProjectID = [[descriptorProject descriptorForKeyword:'seld']stringValue];
        descriptorArea = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'tsaa'];
        theAreaID = [[descriptorArea descriptorForKeyword:'seld']stringValue];
        descriptorDelegate = [[descriptor descriptorAtIndex:x]descriptorForKeyword:'delg'];
        theDelegateID = [[descriptorDelegate descriptorForKeyword:'seld']stringValue];
        
        if ([theStatus isEqualToString:@"tdio"]){
            theStatus = @"Open";
        } else if ([theStatus isEqualToString:@"tdcm"]){
            theStatus = @"Completed";
        } else if ([theStatus isEqualToString:@"tdcl"]){
            theStatus = @"Canceled";
        }
        
        thePriority = @"";
        thePriorityNum = @"0";
        if ([theTag rangeOfString:@"High"].location != NSNotFound) {
         thePriority = @"High";
         thePriorityNum = @"3";   
        } else if ([theTag rangeOfString:@"Medium"].location != NSNotFound) {
            thePriority = @"Medium";
            thePriorityNum = @"2";   
        } else if ([theTag rangeOfString:@"Low"].location != NSNotFound) {
            thePriority = @"Low";
            thePriorityNum = @"1";   
        }
        
        theProjectAreaName = @"";
        theProjectAreaType = @"";
        if (theProjectID != nil){
            theProjectAreaName = [self getNameFromArray:projects forId:theProjectID];
            theProjectAreaType = @"Project";
        } else if (theAreaID != nil){
            theProjectAreaName = [self getNameFromArray:areas forId:theAreaID];
            theProjectAreaType = @"Area";
        }
        
        theDelegateName = @"";
        if (theDelegateID != nil){
            theDelegateName = [self getNameFromArray:delegates forId:theDelegateID];
        }
       
        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys: theName, @"name", theId, @"id",theTag, @"tags", thePriority, @"priority", thePriorityNum, @"priorityNum", theStatus, @"status",theNote, @"notes", createDate, @"created", list, @"list", listNum, @"listnumber", theProjectAreaName, @"projectArea", theProjectAreaType, @"projectAreaType", theDelegateName, @"delegate", nil];
        /* Null dates cause issues with the Dictionary, so add these entries only if date exists */
        if (schedDate != nil){
            [dict setObject:schedDate forKey:@"scheduled"];
        }
        if (dueDate != nil){
            [dict setObject:dueDate forKey:@"due"];
        }
        if (compDate != nil){
            [dict setObject:compDate forKey:@"completed"];
        }
        [array addObject:dict];
    }
    return array;
}

- (NSDate *)dateFromEventDescriptor:(NSAppleEventDescriptor *)descriptor
/* Method by StefanK http://macscripter.net/profile.php?id=14351 */
{
    NSDate *resultDate = nil;
    OSStatus status;
    CFAbsoluteTime absoluteTime;
    LongDateTime longDateTime;
    if ([descriptor descriptorType] == typeLongDateTime) {
        [[descriptor data] getBytes:&longDateTime length:sizeof(longDateTime)];
        status = UCConvertLongDateTimeToCFAbsoluteTime(longDateTime, &absoluteTime);
        if (status == noErr) {
            resultDate = [(NSDate *)CFDateCreate(NULL, absoluteTime) autorelease];
        }
    }
    return resultDate;
}

# pragma mark - Export Methods

- (NSString *)convertArraytoCsv
{
    NSMutableString *csv = [NSMutableString stringWithString:@""];
    NSMutableArray *data = [[[NSMutableArray alloc]initWithArray:[arrayController arrangedObjects]]autorelease];
    /* Check user defaults for csv header preference */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"csvHeader"]){
        [csv appendString:@"List,Name,Status,Priority,Tags,Project/Area Type,Project/Area Name,Person,Create Date,Schedule Date,Due Date,Complete Date\n"];
    }
    for (NSDictionary *record in data){
        /* Get values */
        NSString *list = [record objectForKey:@"list"];
        NSString *name = [record objectForKey:@"name"];
        NSString *status = [record objectForKey:@"status"];
        NSString *priority = [record objectForKey:@"priority"];
        NSString *tags = [record objectForKey:@"tags"];
        NSString *projectArea = [record objectForKey:@"projectArea"];
        NSString *projectAreaType = [record objectForKey:@"projectAreaType"];
        NSString *delegate = [record objectForKey:@"delegate"];
        NSDate *createDate = [record objectForKey:@"created"];
        NSDate *scheduleDate = [record objectForKey:@"scheduled"];
        NSDate *dueDate = [record objectForKey:@"due"];
        NSDate *compDate = [record objectForKey:@"completed"];

        /* Format strings */
        name = [name stringByReplacingOccurrencesOfString:@"," withString:@";"];
        tags = [tags stringByReplacingOccurrencesOfString:@"," withString:@";"];
        projectArea = [projectArea stringByReplacingOccurrencesOfString:@"," withString:@";"];
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        NSString *created = [dateFormat stringFromDate:createDate];
        NSString *scheduled = @"";
        if (scheduleDate !=nil) {
              scheduled = [dateFormat stringFromDate:scheduleDate];
        } 
        NSString *due = @"";
        if (dueDate !=nil) {
            due = [dateFormat stringFromDate:dueDate];
        }  
        NSString *completed = @"";
        if (compDate !=nil) {
            completed = [dateFormat stringFromDate:compDate];
        }  
        [csv appendFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",list,name,status,priority,tags,projectAreaType,projectArea,delegate,created,scheduled,due,completed];
    }
    return csv;
}

- (NSString *)convertArrayToString:(NSArray *)array
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSDictionary *record in array){
        /* Get values */
        NSString *name = [record objectForKey:@"name"];
        NSString *tags = [record objectForKey:@"tags"];
        NSString *projectArea = [record objectForKey:@"projectArea"];
        NSString *delegate = [record objectForKey:@"delegate"];
        NSDate *scheduleDate = [record objectForKey:@"scheduled"];
        NSDate *dueDate = [record objectForKey:@"due"];
        NSDate *completeDate = [record objectForKey:@"completed"];
        /* Add fields to output string */
        if (![projectArea isEqualToString:@""]) {
            [string appendFormat:@"%@: ",projectArea];
        }
        [string appendFormat:@"%@",name];
        if (![tags isEqualToString:@""]) {
            tags = [tags stringByReplacingOccurrencesOfString:@", " withString:@" @"];
            [string appendFormat:@" @%@",tags];
        }
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        if (scheduleDate !=nil) {
            NSString *scheduled = [dateFormat stringFromDate:scheduleDate];
            [string appendFormat:@", Scheduled: %@",scheduled];
        } 
        if (dueDate !=nil) {
            NSString *due = [dateFormat stringFromDate:dueDate];
            [string appendFormat:@", Due: %@",due];
        }   
        if (completeDate !=nil) {
            NSString *completed = [dateFormat stringFromDate:completeDate];
            [string appendFormat:@", Completed: %@",completed];
        }   
        if (![delegate isEqualToString:@""]){
            [string appendFormat:@", Person: %@",delegate];
        }
        [string appendString:@"\n"];
    }
    return string;
}

# pragma mark - UI Methods

- (void)doubleClickHandler
{
    /* Get the selected row from the table. */
    NSInteger theRow = [arrayController selectionIndex];
    
    if ( NSNotFound != theRow) {  /* if there is selected row... */
        NSAppleScript *script;
        NSString *thingsAction;
        NSArray *selectedTodo = [arrayController selectedObjects];
        NSString *todoId = [[selectedTodo objectAtIndex:0]objectForKey:@"id"];
        /* Get user pref for show or edit */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"doubleclickEditShow"]){
            thingsAction = @"show";
        } else {
            thingsAction = @"edit";
        }
        script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"\ntell application \"Things\"\n"
                                                        "activate\n"
                                                        "%@ to do id \"%@\"\n"
                                                        "end tell\n",thingsAction,todoId]];
        [script executeAndReturnError:nil];
        [script release];
    }
}

- (void)updatePopupMenu:(NSPopUpButton *)popup withArray:(NSArray *)array withTitle:(NSString *)itemTitle
{
    NSString *prevSelection = [popup titleOfSelectedItem];
    NSMutableArray *menuItems = [[[NSMutableArray alloc]initWithObjects:itemTitle, nil]autorelease];
    for (NSDictionary *record in array){
        [menuItems addObject:[record objectForKey:@"name"]];
    }
    if (popup != popupTags){
        [menuItems sortUsingSelector:@selector(compare:)];
    }
    [popup removeAllItems];
    [popup addItemsWithTitles:menuItems];
    if (prevSelection != nil){
        [popup selectItemWithTitle:prevSelection];
    }
   
}

- (void)clearImportStatusLabel
{
    [importStatusBarLabel setStringValue:@""];
}

- (void)updatePopupMenuProjectArea
{
    NSString *prevSelection = [popupProjectArea titleOfSelectedItem];
    NSMutableArray *menuItems = [[[NSMutableArray alloc]initWithObjects:@"All Project/Area", nil]autorelease];
    /* Add projects to menu */
    for (NSDictionary *record in projects){
        [menuItems addObject:[record objectForKey:@"name"]];
    }
    [menuItems sortUsingSelector:@selector(compare:)];
    [menuItems insertObject:@"PROJECTS" atIndex:1];
    [popupProjectArea removeAllItems];
    [popupProjectArea addItemsWithTitles:menuItems];
    NSMenuItem *menuItem = [popupProjectArea itemWithTitle:@"PROJECTS"];
    [menuItem setEnabled:NO];
    /* Add areas to menu */
    [menuItems removeAllObjects];
    for (NSDictionary *record in areas){
        [menuItems addObject:[record objectForKey:@"name"]];
    }
    [menuItems sortUsingSelector:@selector(compare:)];
    [menuItems insertObject:@"AREAS" atIndex:0];
    [popupProjectArea addItemsWithTitles:menuItems];
    menuItem = [popupProjectArea itemWithTitle:@"AREAS"];
    [menuItem setEnabled:NO];
    /* Retain previous menu selection */
    if (prevSelection != nil){
        [popupProjectArea selectItemWithTitle:prevSelection];
    }
}

- (void)setViewColumnMenuItemState
{
  for (NSMenuItem *menuItem  in [menuViewColumns itemArray]){
      /* Get table column by its identifier, removing the "/" from the menu item name */
      NSTableColumn *column = [tableView tableColumnWithIdentifier:[[menuItem title] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
      [menuItem setState:![column isHidden]];                   
  }
}

- (void)applicationShouldHandleReopen:(NSNotification *)aNotification hasVisibleWindows:(BOOL)flag
{
    if(!flag){
        [window makeKeyAndOrderFront:self];
    } 
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard
{    
    NSArray *selectedRows = [[arrayController arrangedObjects] objectsAtIndexes:rowIndexes];
    NSString *export = [self convertArrayToString:selectedRows];
    NSArray *pboardTypes = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pboard declareTypes:pboardTypes owner:self];
    /* Add the data of to the pasteboard */
    [pboard setString:export forType:NSStringPboardType];
    return YES;
}

# pragma mark - IBActions

- (IBAction)importTodos:(id)sender {
    [self runScriptsAndImport];
}

- (IBAction)searchFieldSelect:(id)sender {
    [window makeFirstResponder:searchField];
}

- (IBAction)revealInThings:(id)sender {
    NSString *thingsCommand;
    if ([[sender title] isEqualToString:@"Edit in Things"]){
        thingsCommand = @"edit";
    } else {
        thingsCommand = @"show";
    }
    NSAppleScript *script;
    NSArray *selectedTodo = [arrayController selectedObjects];
    NSString *todoId = [[selectedTodo objectAtIndex:0]objectForKey:@"id"];
    script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"\ntell application \"Things\"\n"
                                                    "activate\n"
                                                    "%@ to do id \"%@\"\n"
                                                    "end tell\n",thingsCommand, todoId]];
    [script executeAndReturnError:nil];
    [script release];
}

- (IBAction)filterTable:(id)sender {
    NSString *listFilter = [popupList titleOfSelectedItem];
    NSString *priorityFilter = [popupPriority titleOfSelectedItem];
    NSString *tagsFilter = [popupTags titleOfSelectedItem];
    NSString *projectAreaFilter = [popupProjectArea titleOfSelectedItem];
    NSString *delegateFilter = [popupDelegates titleOfSelectedItem];
    tagsFilter = [NSString stringWithFormat:@"*%@*",tagsFilter];
    if ([listFilter isEqualToString:@"All Lists"]) {
        listFilter = @"*";
    }
    if ([priorityFilter isEqualToString:@"All Priority"]) {
        priorityFilter = @"*";
    }
    if ([tagsFilter isEqualToString:@"*All Tags*"]) {
        tagsFilter = @"*";
    }
    if ([projectAreaFilter isEqualToString:@"All Project/Area"]) {
        projectAreaFilter = @"*";
    }
    if ([delegateFilter isEqualToString:@"All People"]) {
        delegateFilter = @"*";
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(list like %@)And(priority like %@)And(tags like %@)And(projectArea like %@)And(delegate like %@)",listFilter, priorityFilter,tagsFilter,projectAreaFilter,delegateFilter];
    [arrayController setFilterPredicate:predicate];
}

- (IBAction)filterReset:(id)sender {
    [popupList selectItemWithTitle:@"All Lists"];
    [popupPriority selectItemWithTitle:@"All Priority"];
    [popupTags selectItemWithTitle:@"All Tags"];
    [popupProjectArea selectItemWithTitle:@"All Project/Area"];
    [popupDelegates selectItemWithTitle:@"All People"];
    [arrayController setFilterPredicate:nil];
}

- (IBAction)searchFieldResetPopups:(id)sender {
    /* Using the search field overrides the array filter predicate - so reset filter popups */
    [popupList selectItemWithTitle:@"All Lists"];
    [popupPriority selectItemWithTitle:@"All Priority"];
    [popupTags selectItemWithTitle:@"All Tags"];
    [popupProjectArea selectItemWithTitle:@"All Project/Area"];
    [popupDelegates selectItemWithTitle:@"All People"];
}

- (IBAction)toggleColumnVisibility:(id)sender {
    /* Get table column by its identifier, removing the "/" from the menu item name */
    NSTableColumn *column = [tableView tableColumnWithIdentifier:[[sender title] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
    /* Set column visibility to opposite of current state */
    [column setHidden:![column isHidden]];                         
    /* Update menu item state */
    [sender setState:![column isHidden]];
}

- (IBAction)saveAsCsv:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"csv",nil]];
    [panel setMessage:@"Export tasks as csv"];
    [panel setNameFieldStringValue:@"tasks.csv"];
    [panel setAllowsOtherFileTypes:NO];
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger returnCode)
     {
         if (returnCode == NSOKButton) {
             NSString *export = [self convertArraytoCsv];
             [export writeToURL:[panel URL] atomically:YES encoding:1 error:NULL];
         }
     }];
}

- (IBAction)checkListPopup:(id)sender {
    /* If pref to exclude logbook import is selected, then check if Logbook list popup filter is currently selected and change to All Lists */
    if (![sender state]){
        if ([[popupList titleOfSelectedItem]isEqualToString:@"Logbook"]){
            [popupList selectItemWithTitle:@"All Lists"];
            [self filterTable:nil];
        }
    }    
}

- (void) copy:(id)sender
{
    NSMutableArray *selectedRows = [[[NSMutableArray alloc]initWithArray:[arrayController selectedObjects]]autorelease];
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *export = [self convertArrayToString:selectedRows];
    NSArray *pboardTypes = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pboard declareTypes:pboardTypes owner:self];
    // Add the data of to the pasteboard
    [pboard setString:export forType:NSStringPboardType];
}

@end
