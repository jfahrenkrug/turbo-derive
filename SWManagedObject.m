//
//  SWManagedObject.m
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SWManagedObject.h"


@interface NSString (SWManagedObject)

- (NSString *)cappedString;

@end


@interface SWManagedObjectObserver : NSObject
{
	__weak id _observee;
	NSString *_keyPath;
	__weak id _target;
	NSString *_derivedKey;
}

+ (SWManagedObjectObserver*)observerWithObservedObject:(id)observee
											   keyPath:(NSString*)keyPath
												target:(id)target
											derivedKey:(NSString*)derivedKey;

- (SWManagedObjectObserver*)initWithObservedObject:(id)observee
										   keyPath:(NSString*)keyPath
											target:(id)target
										derivedKey:(NSString*)derivedKey;

@end


@interface SWManagedObject ()

- (void)setupDerivedValues;

- (void)tearDownDerivedValues;

@end


@implementation SWManagedObject

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setupDerivedValues];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	
	[self setupDerivedValues];
}

- (void)didTurnIntoFault
{
	[self tearDownDerivedValues];
	
	[super didTurnIntoFault];
}

- (void)dealloc
{
	[self tearDownDerivedValues];
	
	[super dealloc];
}

- (void)setupDerivedValues
{
	if ([self conformsToProtocol:NSProtocolFromString(@"SWDerivedValues")]) {
		NSMutableArray *observers = [NSMutableArray array];
		NSSet *keysToDerivedValues = [[self class] keysToDerivedValues];
		
		for (NSString *derivedKey in keysToDerivedValues) {
			NSString *capitalizedKey = [derivedKey capitalizedString];
			SEL selector= NSSelectorFromString([@"keyPathsForValuesAffectingDerived" stringByAppendingString:capitalizedKey]);
			NSArray *keyPathsForBaseValues = [[self class] performSelector:selector];
			
			for (NSString *baseKeyPath in keyPathsForBaseValues) {
				NSInteger location = [baseKeyPath rangeOfString:@"."].location;
				NSString *observedKeyPath = (location != NSNotFound) ? [baseKeyPath substringToIndex:location] : baseKeyPath;
				
				[observers addObject:[SWManagedObjectObserver observerWithObservedObject:self
																				 keyPath:observedKeyPath
																				  target:self
																			  derivedKey:derivedKey]];
			}
		}
		
		_observersByObject = [[NSMutableDictionary dictionaryWithObject:observers forKey:[NSNull null]] retain];
	}
}

- (void)tearDownDerivedValues
{
	[_observersByObject release], _observersByObject = nil;
}

- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects
{
	NSSet *keysToDerivedValues = [[self class] keysToDerivedValues];
	
	for (NSString *derivedKey in keysToDerivedValues) {
		NSString *capitalizedKey = [derivedKey capitalizedString];
		SEL selector = NSSelectorFromString([@"keyPathsForValuesAffectingDerived" stringByAppendingString:capitalizedKey]);
		NSArray *keyPathsForBaseValues = [[self class] performSelector:selector];
		
		for (NSString *baseKeyPath in keyPathsForBaseValues) {
			NSArray *baseKeyPathComponents = [baseKeyPath componentsSeparatedByString:@"."];
			NSString *firstPartOfBaseKeyPath = [baseKeyPathComponents objectAtIndex:0];
			NSString *lastPartOfBaseKeyPath = [baseKeyPathComponents objectAtIndex:([baseKeyPathComponents count] - 1)];
			
			if ([firstPartOfBaseKeyPath isEqual:inKey]) {				
				for (NSManagedObject *addedOrRemovedObject in inObjects) {
					if ((inMutationKind == NSKeyValueUnionSetMutation) || (inMutationKind == NSKeyValueSetSetMutation)) {
						SWManagedObjectObserver *observer = [SWManagedObjectObserver observerWithObservedObject:addedOrRemovedObject
																										keyPath:lastPartOfBaseKeyPath
																										 target:self
																									 derivedKey:derivedKey];
						
						NSMutableDictionary *observerDictionary = [_observersByObject objectForKey:addedOrRemovedObject];
						
						if (observerDictionary == nil) {
							observerDictionary = [NSMutableDictionary dictionary];
							
							[_observersByObject setObject:observerDictionary forKey:[addedOrRemovedObject objectID]];
						}
						
						[observerDictionary setObject:observer forKey:lastPartOfBaseKeyPath];
					}
					else if ((inMutationKind == NSKeyValueMinusSetMutation) || (inMutationKind == NSKeyValueIntersectSetMutation)) {
						NSMutableDictionary *observerDictionary = [_observersByObject objectForKey:addedOrRemovedObject];

						[observerDictionary removeObjectForKey:lastPartOfBaseKeyPath];
						
						if ([observerDictionary count] == 0) {
							[_observersByObject removeObjectForKey:[addedOrRemovedObject objectID]];
						}

						[self performSelector:NSSelectorFromString([@"update" stringByAppendingString:capitalizedKey])];
					}
				}
			}
		}
	}
}

@end


@implementation SWManagedObjectObserver

+ (SWManagedObjectObserver*)observerWithObservedObject:(id)observee
											   keyPath:(NSString*)keyPath
												target:(id)target
											derivedKey:(NSString*)derivedKey
{
	SWManagedObjectObserver *observer = [[SWManagedObjectObserver alloc] initWithObservedObject:observee
																						keyPath:keyPath
																						 target:target
																					 derivedKey:derivedKey];
	
	return [observer autorelease];
}

- (SWManagedObjectObserver*)initWithObservedObject:(id)observee
										   keyPath:(NSString*)keyPath
											target:(id)target
										derivedKey:(NSString*)derivedKey
{
	if ((self = [super init]) != nil) {
		_observee = observee;
		_keyPath = [keyPath copy];
		_target = target;
		_derivedKey = [derivedKey copy];
		
		[_observee addObserver:self forKeyPath:_keyPath options:NSKeyValueObservingOptionInitial context:self];
	}
	
	return self;
}

- (void)dealloc
{
	[_observee removeObserver:self forKeyPath:_keyPath];
	
	_observee = nil;
	[_keyPath release], _keyPath = nil;
	_target = nil;
	[_derivedKey release], _derivedKey = nil;
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if (context == self) {
		[_target performSelector:NSSelectorFromString([@"update" stringByAppendingString:[_derivedKey cappedString]])];
	}
	else {
		[super observeValueForKeyPath:keyPath
							 ofObject:object
							   change:change
							  context:context];
	}
}

@end


@implementation NSString (SWManagedObject)

- (NSString *)cappedString
{
	if ([self length] > 0) {
		NSString *firstCapChar = [[self substringToIndex:1] capitalizedString];
		
		return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
	}
	
	return self;
}

@end