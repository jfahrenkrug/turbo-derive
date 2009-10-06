//
//  SWManagedObject.h
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol SWDerivedValues

+ (NSSet *)keysToDerivedValues;

@end


@interface SWManagedObject : NSManagedObject
{
	NSMutableDictionary *_observersByObject;
}

@end