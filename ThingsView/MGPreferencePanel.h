//
//  MGPreferencePanel.h
//  MGPreferencePanel
//
//  Created by Michael on 29.03.10.
//  Copyright 2010 MOApp Software Manufactory. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface MGPreferencePanel : NSObject <NSToolbarDelegate> 
{	
	IBOutlet NSView *view1;
	IBOutlet NSView *view2;
	IBOutlet NSView *view3;
	IBOutlet NSView *view4;	
	IBOutlet NSView *contentView;
	IBOutlet NSWindow *window;
}

-(void)mapViewsToToolbar;
-(void)firstPane;
-(IBAction)changePanes:(id)sender;

@end
