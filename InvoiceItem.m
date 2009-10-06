// 
//  InvoiceItem.m
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InvoiceItem.h"


@implementation InvoiceItem 

@dynamic quantity;
@dynamic itemPrice;
@dynamic invoice;
@dynamic total;

- (NSNumber *)total {
	return total;
}

- (void)updateTotal {
	[self willChangeValueForKey:@"total"];
	NSNumber *oldTotal = total;
	total = [[NSNumber numberWithDouble:([self.itemPrice doubleValue] * [self.quantity intValue])] retain];
	[oldTotal release];
	[self didChangeValueForKey:@"total"];
}

+ (NSSet *)keysToDerivedValues
{
	return [NSSet setWithObjects:@"total", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDerivedTotal
{
	return [NSSet setWithObjects:@"itemPrice", @"quantity", nil];
}



@end
