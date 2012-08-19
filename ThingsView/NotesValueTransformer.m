//
//  NotesValueTransformer.m
//  ThingsView
//
//  Created by brisk on 18/09/11.
//  Copyright 2011 codefrapp. All rights reserved.
//

#import "NotesValueTransformer.h"

@implementation NotesValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

// Transformer removes urls from the Notes field

- (id)transformedValue:(id)aString
{	
    NSString *regexString       = @"(\\[url=).*(url\\])";
    NSString *replaceWithString = @"";
    NSString *replacedString    = NULL;
    replacedString = [aString stringByReplacingOccurrencesOfRegex:regexString withString:replaceWithString];
    replacedString = (NSString *)[replacedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [NSString stringWithString: replacedString];
}

@end
