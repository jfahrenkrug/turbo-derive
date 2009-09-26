//
//  DynamicProperties_AppDelegate.m
//  DynamicProperties
//
//  Created by Johannes Fahrenkrug on 9/26/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "DynamicProperties_AppDelegate.h"
#import "InvoiceItem.h"
#import "Invoice.h"

@implementation DynamicProperties_AppDelegate


/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "DynamicProperties" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"DynamicProperties"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"did finish launching...");
	
	
	NSManagedObjectContext *context = [self managedObjectContext];
	NSEntityDescription *invoiceItemEntity = [NSEntityDescription
										   entityForName:@"InvoiceItem"
										   inManagedObjectContext:context];
	
	NSEntityDescription *invoiceEntity = [NSEntityDescription
											  entityForName:@"Invoice"
											  inManagedObjectContext:context];

	InvoiceItem *newInvoiceItem = [[InvoiceItem alloc]
									initWithEntity:invoiceItemEntity
									insertIntoManagedObjectContext:context];
	
	
	InvoiceItem *newInvoiceItem2 = [[InvoiceItem alloc]
								   initWithEntity:invoiceItemEntity
								   insertIntoManagedObjectContext:context];
	
	newInvoiceItem.itemPrice = [NSNumber numberWithDouble:10.99];
	newInvoiceItem.quantity = [NSNumber numberWithInt:5];
	NSLog(@"Total1: %@", newInvoiceItem.total);
	newInvoiceItem.quantity = [NSNumber numberWithInt:9];
	NSLog(@"Total2: %@", newInvoiceItem.total);
	
	newInvoiceItem.itemPrice = [NSNumber numberWithDouble:5.0];
	NSLog(@"Total3: %@", newInvoiceItem.total);
	
	newInvoiceItem2.itemPrice = [NSNumber numberWithDouble:99.0];
	newInvoiceItem2.quantity = [NSNumber numberWithInt:6];
	
	Invoice *newInvoice = [[Invoice alloc]
								   initWithEntity:invoiceEntity
								   insertIntoManagedObjectContext:context];
	
	[newInvoice addItems:[NSSet setWithObjects:newInvoiceItem, newInvoiceItem2, nil]];
	
	NSLog(@"Invoice Total: %@", newInvoice.total);
	newInvoiceItem.itemPrice = [NSNumber numberWithDouble:8.78];
	NSLog(@"Invoice Total2: %@", newInvoice.total);
	[newInvoice removeItems:[NSSet setWithObject:newInvoiceItem2]];
	NSLog(@"Invoice Total3: %@", newInvoice.total);
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"DynamicProperties.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


@end
