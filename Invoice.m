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
@dynamic totalSum;

- (NSNumber *)totalSum {
	return totalSum;
}

- (void)updateTotalSum {
	NSNumber *oldTotalSum = totalSum;
	totalSum = [[self valueForKeyPath:@"items.@sum.total"] retain];
	[oldTotalSum release];
}


+ (NSSet *)keysToDerivedValues
{
	return [NSSet setWithObjects:@"totalSum", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDerivedTotalSum
{
	return [NSSet setWithObjects:@"items.@sum.total", nil];
}

@end
