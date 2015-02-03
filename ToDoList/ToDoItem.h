#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ToDoItem : NSManagedObject

@property (nonatomic, retain) NSString *itemName;
@property (nonatomic, retain) NSNumber *completed;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSDate *lastModifiedDate;

@end
