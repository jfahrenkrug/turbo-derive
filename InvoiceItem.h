//
//  InvoiceItem.h
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SWManagedObject.h"


@interface InvoiceItem :  SWManagedObject  <SWDerivedValues>
{
	NSNumber * total;
}

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * itemPrice;
@property (nonatomic, retain) NSManagedObject * invoice;
@property (readonly) NSNumber * total;

@end



