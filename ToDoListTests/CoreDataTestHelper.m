#import "CoreDataTestHelper.h"
#import "ToDoItem.h"

#import <CoreData/CoreData.h>
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface CoreDataTestHelper()

@end

@implementation CoreDataTestHelper

- (id)init {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ToDoList" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        [NSException raise:@"Unable to add in-memory store" format:@"Error : %@, %@", error, error.localizedDescription];
    }
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;

    return self;
}

- (void)persistToDoItem:(NSString *)itemName {
    [self persistToDoItem:itemName withCompleted:NO];
}

- (void)persistToDoItem:(NSString *)itemName withCompleted:(BOOL)completed {
    ToDoItem *toDoItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    toDoItem.itemName = itemName;
    toDoItem.completed = [NSNumber numberWithBool:completed];
    toDoItem.createdDate = [NSDate date];
    toDoItem.lastModifiedDate = [NSDate date];
    NSError *error = nil;
    if (![toDoItem.managedObjectContext save:&error]) {
        [NSException raise:@"Unable to save managed object context" format:@"Error : %@, %@", error, error.localizedDescription];
    }
}

- (NSArray *)findAllPersistedToDoItems {
    NSFetchRequest *fetchRequest = [self createToDoItemFetchRequest];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (NSArray *)findPersistedToDoItemsByName:(NSString *)name {
    return [self findPersistedToDoItems:[NSPredicate predicateWithFormat:@"itemName == %@", name]];
}

- (NSArray *)findPersistedToDoItems:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [self createToDoItemFetchRequest];
    [fetchRequest setPredicate:predicate];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (NSFetchRequest *)createToDoItemFetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext]];
    return fetchRequest;
}

@end
