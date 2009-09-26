//
//  SWManagedObject.m
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SWManagedObject.h"


@implementation SWManagedObject

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
	if (self = [super initWithEntity:entity	insertIntoManagedObjectContext:context]) {
		// lets loop over the derivedValueKeys and register the kvo stuff...
		
		NSEnumerator *kpEnum = [[[self class] keyPathsForDerivedValues] objectEnumerator];
		NSString *keyPath = nil;
		
		while (keyPath = [kpEnum nextObject]) {
			NSLog(keyPath);
			
			NSEnumerator *derivedKpEnum = [[[self class] performSelector:NSSelectorFromString([@"keyPathsForValuesAffectingDerived" stringByAppendingString:[keyPath capitalizedString]])] objectEnumerator];
			
			NSString *derivedKeyPath = nil;
			
			while (derivedKeyPath = [derivedKpEnum nextObject]) {
				NSLog([keyPath stringByAppendingString:derivedKeyPath]);
				NSString * firstPartOfDerivedKeyPath = [[derivedKeyPath componentsSeparatedByString:@"."] objectAtIndex:0];
				NSLog([@"First part to observe: " stringByAppendingString:firstPartOfDerivedKeyPath]);
				
				// We will only observe the first part of any key. So if the key is invoiceItems.@sum.total we will only observe "invoiceItems"
				[self addObserver:self
					   forKeyPath:firstPartOfDerivedKeyPath
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:keyPath];
			}
		}
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	NSEnumerator *kpEnum = [[[self class] keyPathsForDerivedValues] objectEnumerator];
	NSString *kPath = nil;
	
	while (kPath = [kpEnum nextObject]) {
		if ([(NSString *)context isEqualToString:kPath]) {
			NSLog([NSString stringWithFormat:@"path %@ which affects %@ changed.", keyPath, kPath]);
			[self performSelector:NSSelectorFromString([@"update" stringByAppendingString:[kPath capitalizedString]])];
		}
	}
}

- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
	NSLog(@"did change set");
	
	NSEnumerator *kpEnum = [[[self class] keyPathsForDerivedValues] objectEnumerator];
	NSString *keyPath = nil;
	
	while (keyPath = [kpEnum nextObject]) {
		NSLog(keyPath);
		
		NSEnumerator *derivedKpEnum = [[[self class] performSelector:NSSelectorFromString([@"keyPathsForValuesAffectingDerived" stringByAppendingString:[keyPath capitalizedString]])] objectEnumerator];
		
		NSString *derivedKeyPath = nil;
		
		while (derivedKeyPath = [derivedKpEnum nextObject]) {
			NSArray * derivedKeyPathComponents = [derivedKeyPath componentsSeparatedByString:@"."];
			NSString * firstPartOfDerivedKeyPath = [derivedKeyPathComponents objectAtIndex:0];
			NSString * lastPartOfDerivedKeyPath = [derivedKeyPathComponents objectAtIndex:([derivedKeyPathComponents count] - 1)];
			if (firstPartOfDerivedKeyPath == inKey) {
				NSEnumerator *setEnum = [inObjects objectEnumerator];
				id  addedOrRemovedObject = nil;
				
				while (addedOrRemovedObject = [setEnum nextObject]) {
					if (inMutationKind == NSKeyValueUnionSetMutation || inMutationKind == NSKeyValueSetSetMutation) {
						NSLog(@"add set");
						[addedOrRemovedObject addObserver:self
											   forKeyPath:lastPartOfDerivedKeyPath
												  options:(NSKeyValueObservingOptionNew |
														   NSKeyValueObservingOptionOld)
												  context:keyPath];
						
					} else if (inMutationKind == NSKeyValueMinusSetMutation || inMutationKind == NSKeyValueIntersectSetMutation) {
						NSLog(@"remove set");
						[addedOrRemovedObject removeObserver:self
												  forKeyPath:lastPartOfDerivedKeyPath];
					}
				}
				[self performSelector:NSSelectorFromString([@"update" stringByAppendingString:[keyPath capitalizedString]])];
			}
		}
	}
}

@end
