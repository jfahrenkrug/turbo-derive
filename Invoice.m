// 
//  Invoice.m
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Invoice.h"

#import "InvoiceItem.h"

@implementation Invoice 

@dynamic name;
@dynamic number;
@dynamic paid;
@dynamic items;
@dynamic total;

- (NSNumber *)total {
	return total;
}

- (void)updateTotal {
	NSNumber *oldTotal = total;
	total = [[self valueForKeyPath:@"items.@sum.total"] retain];
	[oldTotal release];
}


+ (NSSet *)keysToDerivedValues
{
	return [NSSet setWithObjects:@"total", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDerivedTotal
{
	return [NSSet setWithObjects:@"items.@sum.total", nil];
}

@end
