//
//  PriorityValueTransformer.m
//  ThingsView
//
//  Created by brisk on 18/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import "PriorityValueTransformer.h"

@implementation PriorityValueTransformer

// Transformer replaces priority text with images

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    
	if ([value isEqualToString:@"High"]){
		return [NSImage imageNamed:@"priority3.tiff"];
	} else if ([value isEqualToString:@"Medium"]){
		return [NSImage imageNamed:@"priority2.tiff"];
	} else if ([value isEqualToString:@"Low"]){
		return [NSImage imageNamed:@"priority1.tiff"];
	} else{
		return [NSImage imageNamed:@"empty.tiff"];
	}	
	return nil;
}

@end
