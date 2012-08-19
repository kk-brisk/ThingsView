//
//  ListValueTransformer.m
//  ThingsView
//
//  Created by brisk on 18/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import "ListValueTransformer.h"

@implementation ListValueTransformer

// Transformer displays the list images

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    
	if ([value isEqualToString:@"Next"]){
		return [NSImage imageNamed:@"next.tiff"];
	} else if ([value isEqualToString:@"Today"]){
		return [NSImage imageNamed:@"today.tiff"];
	} else if ([value isEqualToString:@"Someday"]){
		return [NSImage imageNamed:@"someday.tiff"];
	} else if ([value isEqualToString:@"Scheduled"]){
		return [NSImage imageNamed:@"scheduled.tiff"];
	}else if ([value isEqualToString:@"Inbox"]){
		return [NSImage imageNamed:@"inbox.tiff"];
	}else if ([value isEqualToString:@"Logbook"]){
		return [NSImage imageNamed:@"logbook.tiff"];
	}else{
		return [NSImage imageNamed:@"empty.tiff"];
	}	
	return nil;
}
@end
