#import <UIKit/UIKit.h>

@interface ToDoListTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

- (void)deleteItemForIndexPath:(NSIndexPath *)indexPath fromTableView:(UITableView *)tableView;

@end
