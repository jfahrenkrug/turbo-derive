//
//  SWManagedObject.h
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SWManagedObjectDelegate
+ (NSSet *)keyPathsForDerivedValues;
@end

@interface SWManagedObject : NSManagedObject {
}

- (id)initWithEntity:(NSEntityDescription *)invoiceItemEntity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
