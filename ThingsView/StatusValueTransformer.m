//
//  StatusValueTransformer.m
//  ThingsView
//
//  Created by brisk on 16/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import "StatusValueTransformer.h"

@implementation StatusValueTransformer

// Transformer displays task status images

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    
	if ([value isEqualToString:@"Open"]){
		return [NSImage imageNamed:@"open.tiff"];
	} else if ([value isEqualToString:@"Completed"]){
		return [NSImage imageNamed:@"complete.tiff"];
	} else if ([value isEqualToString:@"Canceled"]){
		return [NSImage imageNamed:@"cancel.tiff"];
	} else{
		return [NSImage imageNamed:@"empty.tiff"];
	}	
	return nil;
}
@end
