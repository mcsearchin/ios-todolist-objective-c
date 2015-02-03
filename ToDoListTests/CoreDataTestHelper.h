#import <CoreData/CoreData.h>

@interface CoreDataTestHelper : NSObject

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

- (void)persistToDoItem:(NSString *)itemName;
- (void)persistToDoItem:(NSString *)itemName withCompleted:(BOOL)completed;
- (NSArray *)findAllPersistedToDoItems;
- (NSArray *)findPersistedToDoItemsByName:(NSString *)name;
- (NSArray *)findPersistedToDoItems:(NSPredicate *)predicate;

@end