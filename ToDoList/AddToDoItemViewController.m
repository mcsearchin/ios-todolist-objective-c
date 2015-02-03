#import "AddToDoItemViewController.h"

@interface AddToDoItemViewController ()

@end

@implementation AddToDoItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)viewDidAppear:(BOOL)animated {
    [self.nameTextField becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.saveButton) {
        NSString *trimmedNameText = [self.nameTextField.text stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceCharacterSet]];
        if (trimmedNameText.length > 0) {
            ToDoItem *toDoItem = [self initializeToDoItem:trimmedNameText];
            [self saveToDoItem:toDoItem];
        }
    }
}

- (ToDoItem *)initializeToDoItem:(NSString *)itemName {
    ToDoItem *toDoItem = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    toDoItem.itemName = itemName;
    toDoItem.completed = [NSNumber numberWithBool:NO];
    NSDate *now = [NSDate date];
    toDoItem.createdDate = now;
    toDoItem.lastModifiedDate = now;

    return toDoItem;
}

- (void)saveToDoItem:(ToDoItem *)toDoItem {
    NSError *error = nil;
    if (![toDoItem.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context : %@, %@", error, error.localizedDescription);
    }
}

@end