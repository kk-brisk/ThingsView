//
//  ProjectAreaValueTransformer.m
//  ThingsView
//
//  Created by brisk on 18/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import "ProjectAreaValueTransformer.h"

@implementation ProjectAreaValueTransformer

// Transformer displays project or area images

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    
	if ([value isEqualToString:@"Project"]){
		return [NSImage imageNamed:@"project.tiff"];
	} else if ([value isEqualToString:@"Area"]){
		return [NSImage imageNamed:@"area.tiff"];
	} else{
		return [NSImage imageNamed:@"empty.tiff"];
	}	
	return nil;
}

@end
