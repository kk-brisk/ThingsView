	//
	//  MGPreferencePanel.m
	//  MGPreferencePanel
	//
	//  Created by Michael on 29.03.10.
	//  Copyright 2010 MOApp Software Manufactory. All rights reserved.
	//


#define WINDOW_TOOLBAR_HEIGHT 78

#import "MGPreferencePanel.h"

	// Default panes

NSString * const View1ItemIdentifier = @"View1ItemIdentifier";
NSString * const View1IconImageName = @"PreferenceGeneral";

NSString * const View2ItemIdentifier = @"View2ItemIdentifier";
NSString * const View2IconImageName = @"View2Icon";

NSString * const View3ItemIdentifier = @"View3ItemIdentifier";
NSString * const View3IconImageName = @"View3Icon";

NSString * const View4ItemIdentifier = @"View4ItemIdentifier";
NSString * const View4IconImageName = @"View4Icon";



@implementation MGPreferencePanel


#pragma mark -
#pragma mark INIT | AWAKE


-(id)init
{
	if( self = [super init] )
	{
			//
	}	
	
	return self;
}


-(void)dealloc
{
	[super dealloc];
}


-(void)awakeFromNib
{
	[self mapViewsToToolbar];
	[self firstPane];
	[window center];
}


#pragma mark -
#pragma mark MAP | CHANGE


-(void)mapViewsToToolbar
{
	NSString *app = @"ThingsView"; // Application title
	
    NSToolbar *toolbar = [window toolbar];
	if(toolbar == nil)  
	{
		toolbar = [[[NSToolbar alloc] initWithIdentifier: [NSString stringWithFormat: @"%@.mgpreferencepanel.toolbar", app]] autorelease];
	}
	
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    
	[toolbar setDelegate: self]; 
	
	[window setToolbar: toolbar];	
	[window setTitle: NSLocalizedString(@"General", @"")];
	
	if([toolbar respondsToSelector: @selector(setSelectedItemIdentifier:)])
	{
		[toolbar setSelectedItemIdentifier: View1ItemIdentifier];
	}	
}



-(IBAction)changePanes:(id)sender
{
	NSView *view = nil;
	
	switch ([sender tag]) 
	{
		case 0:
			[window setTitle: NSLocalizedString(@"General", @"")];
			view = view1;
			break;
		case 1:
			[window setTitle: NSLocalizedString(@"View 2 Title", @"")];
			view = view2;
			break;
		case 2:
			[window setTitle: NSLocalizedString(@"View 3 Title", @"")];
			view = view3;
			break;
		case 3:
			[window setTitle: NSLocalizedString(@"View 4 Title", @"")];
			view = view4;
			break;
		default:
			break;
	}
	
	NSRect windowFrame = [window frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([window frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[contentView subviews] count] != 0)
	{
		[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	[window setFrame:windowFrame display:YES animate:YES];
	[contentView setFrame:[view frame]];
	[contentView addSubview:view];	
}


#pragma mark -
#pragma mark FIRST PANE


-(void)firstPane
{
	NSView *view = nil;
	view = view1;
	
	NSRect windowFrame = [window frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([window frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[contentView subviews] count] != 0)
	{
		[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	[window setFrame:windowFrame display:YES animate:YES];
	[contentView setFrame:[view frame]];
	[contentView addSubview:view];	
}


#pragma mark -
#pragma mark DEFAULT | ALLOWED | SELECTABLE


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:
			View1ItemIdentifier,
			View2ItemIdentifier,
			View3ItemIdentifier,
			View4ItemIdentifier,	
			nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:
			View1ItemIdentifier,
			View2ItemIdentifier,
			View3ItemIdentifier,
			View4ItemIdentifier,	
			NSToolbarSeparatorItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			nil];
}


-(NSArray*)toolbarSelectableItemIdentifiers: (NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
			View1ItemIdentifier,
			View2ItemIdentifier,
			View3ItemIdentifier,
			View4ItemIdentifier,	
			nil];
}



#pragma mark -
#pragma mark ITEM FOR IDENTIFIER


- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willBeInsertedIntoToolbar;
{
	NSToolbarItem *item = nil;
	
    if ([itemIdentifier isEqualToString:View1ItemIdentifier]) {
		
        item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [item setPaletteLabel:NSLocalizedString(@"General", @"")];
        [item setLabel:NSLocalizedString(@"General", @"")];
        [item setImage:[NSImage imageNamed:View1IconImageName]];
		[item setAction:@selector(changePanes:)];
        [item setToolTip:NSLocalizedString(@"", @"")];
		[item setTag:0];
    }
/*	else if ([itemIdentifier isEqualToString:View2ItemIdentifier]) {
		
        item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [item setPaletteLabel:NSLocalizedString(@"View 2 Title", @"")];
        [item setLabel:NSLocalizedString(@"View 2 Title", @"")];
        [item setImage:[NSImage imageNamed:View2IconImageName]];
		[item setAction:@selector(changePanes:)];
        [item setToolTip:NSLocalizedString(@"", @"")];
		[item setTag:1];
    }
	else if ([itemIdentifier isEqualToString:View3ItemIdentifier]) {
		
        item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [item setPaletteLabel:NSLocalizedString(@"View 3 Title", @"")];
        [item setLabel:NSLocalizedString(@"View 3 Title", @"")];
        [item setImage:[NSImage imageNamed:View3IconImageName]];
		[item setAction:@selector(changePanes:)];
        [item setToolTip:NSLocalizedString(@"", @"")];
		[item setTag:2];
    }
	else if ([itemIdentifier isEqualToString:View4ItemIdentifier]) {
		
        item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [item setPaletteLabel:NSLocalizedString(@"View 4 Title", @"")];
        [item setLabel:NSLocalizedString(@"View 4 Title", @"")];
        [item setImage:[NSImage imageNamed:View4IconImageName]];
		[item setAction:@selector(changePanes:)];
        [item setToolTip:NSLocalizedString(@"", @"")];
		[item setTag:3];
    }
	*/
	return [item autorelease];
}



@end
