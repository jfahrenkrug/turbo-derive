//
//  Invoice.h
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SWManagedObject.h"

@class InvoiceItem;

@interface Invoice :  SWManagedObject <SWManagedObjectDelegate>
{
	NSNumber * total;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * paid;
@property (nonatomic, retain) NSSet* items;
@property (readonly) NSNumber * total;

@end


@interface Invoice (CoreDataGeneratedAccessors)
- (void)addItemsObject:(InvoiceItem *)value;
- (void)removeItemsObject:(InvoiceItem *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end

