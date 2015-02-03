#import "AddToDoItemViewController.h"
#import "CoreDataTestHelper.h"
#import "ToDoItem.h"
#import "ToDoListTableViewController.h"

#import <CoreData/CoreData.h>
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ToDoListTableViewControllerTests : XCTestCase

@property ToDoListTableViewController *toDoListTableViewController;
@property UIStoryboard *storyboard;
@property CoreDataTestHelper *coreDataTestHelper;

@end

@implementation ToDoListTableViewControllerTests

static NSString *const ITEM_NAME = @"item name";

- (void)setUp {
    [super setUp];
    [self setUpController];
    self.coreDataTestHelper = [[CoreDataTestHelper alloc] init];
    self.toDoListTableViewController.managedObjectContext = self.coreDataTestHelper.managedObjectContext;
}

- (void) setUpController {
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.toDoListTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ToDoListTableViewController"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNumberOfSectionsInTableViewIsOne {
    NSInteger numberOfSections = [self.toDoListTableViewController numberOfSectionsInTableView:self.toDoListTableViewController.tableView];
    
    XCTAssertEqual(1, numberOfSections, "Wrong number of sections");
}

- (void)testGivenOneToDoItemInTheManagedObjectContextWhenTheViewIsLoadedThenTheNumberOfRowsInSectionIsOne {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME];
    
    [self.toDoListTableViewController view];
    
    NSInteger numberOfRows = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView numberOfRowsInSection:0];
    XCTAssertEqual(1, numberOfRows, "Wrong number of rows");
}

- (void)testGivenTwoToDoItemsInTheManagedObjectContextWhenTheViewIsLoadedThenTheNumberOfRowsInSectionIsTwo {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME];
    [self.coreDataTestHelper persistToDoItem:@"item 2 name"];
    
    [self.toDoListTableViewController view];
    
    NSInteger numberOfRows = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView numberOfRowsInSection:0];
    XCTAssertEqual(2, numberOfRows, "Wrong number of rows");
}

- (void)testGivenAnItemInTheModelWhenTheCorrespondingCellIsRetrievedThenTheLabelTextIsTheSameAsTheNameOfTheItem {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME];
    [self.toDoListTableViewController view];
    
    UITableViewCell *cell = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertEqual(ITEM_NAME, cell.textLabel.text, "Wrong cell label text");
}

- (void)testGivenACompletedItemInTheModelWhenTheCorrespondingCellIsRetrievedTheTheCellHasACheckmarkAccessory {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:YES];
    [self.toDoListTableViewController view];
    
    UITableViewCell *cell = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertEqual(UITableViewCellAccessoryCheckmark, cell.accessoryType, "Wrong accessory type");
}

- (void)testGivenANonCompletedItemInTheModelWhenTheCorrespondingCellIsRetrievedTheTheCellHasNoAccessory {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    [self.toDoListTableViewController view];
    
    UITableViewCell *cell = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertEqual(UITableViewCellAccessoryNone, cell.accessoryType, "Wrong accessory type");
}

- (void)testGivenTheViewHasLoadedWhenANewItemIsAddedToTheManagedObjectContextAndTableViewIsReloadedThenThereIsACorrespondingCellForTheNewItem {
    [self.toDoListTableViewController view];
    
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    
    [self.toDoListTableViewController unwindToList:nil];

    UITableViewCell *cell = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertEqual(ITEM_NAME, cell.textLabel.text, "Wrong cell label text");
    XCTAssertEqual(UITableViewCellAccessoryNone, cell.accessoryType, "Wrong accessory type");
}

- (void)testWhenARowIsSelectedThenItIsDeselected {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    id mockTableView = OCMClassMock([UITableView class]);
    OCMExpect([mockTableView deselectRowAtIndexPath:indexPath animated:NO]);
    
    [self.toDoListTableViewController tableView:mockTableView didSelectRowAtIndexPath:indexPath];

    OCMVerifyAll(mockTableView);
}

- (void)testGivenANonCompletedItemInTheModelWhenTheCorrespondingCellIsSelectedThenTheItemSetToCompletedInTheManagedObjectContext {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    [self.toDoListTableViewController view];
    
    [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSArray *toDoItems = [self.coreDataTestHelper findPersistedToDoItemsByName:ITEM_NAME];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertFalse([toDoItems count] == 0, "ToDoItems in managed object context should not be empty for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertTrue([toDoItem.completed boolValue], "Completed should be set to true");
}

- (void)testGivenACompletedItemInTheModelWhenTheCorrespondingCellIsSelectedThenTheItemSetToNotCompletedInTheManagedObjectContext {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:YES];
    [self.toDoListTableViewController view];
    
    [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSArray *toDoItems = [self.coreDataTestHelper findPersistedToDoItemsByName:ITEM_NAME];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertFalse([toDoItems count] == 0, "ToDoItems in managed object context should not be empty for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertFalse([toDoItem.completed boolValue], "Completed should be set to false");
}

- (void)testGivenAnItemInTheModelWhenTheCorrespondingCellIsSelectedThenTheLastModifiedDateIsSetToTheCurrentDateInTheManagedObjectContext {
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    [self.toDoListTableViewController view];
    NSDate *before = [NSDate date];
    
    [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSArray *toDoItems = [self.coreDataTestHelper findPersistedToDoItemsByName:ITEM_NAME];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertFalse([toDoItems count] == 0, "ToDoItems in managed object context should not be empty for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertTrue([before compare:toDoItem.lastModifiedDate] <= NSOrderedAscending, "Last modified date should be after row was selected");
}

- (void)testWhenARowIsSelectedThenItIsReloaded {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    id mockTableView = OCMClassMock([UITableView class]);
    OCMExpect([mockTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone]);
    
    [self.toDoListTableViewController tableView:mockTableView didSelectRowAtIndexPath:indexPath];
    
    OCMVerifyAll(mockTableView);
}

- (void)testWhenPreparingForASegueToAddAToDoItemThenTheManagedObjectContextIsSetOnTheAddToDoItemViewController {
    AddToDoItemViewController *addToDoItemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToDoItemViewController"];
    id mockNavigationController = OCMClassMock([UINavigationController class]);
    OCMStub([mockNavigationController viewControllers]).andReturn([NSArray arrayWithObject:addToDoItemViewController]);
    id mockSegue = OCMClassMock([UIStoryboardSegue class]);
    OCMStub([mockSegue identifier]).andReturn(@"AddToDoItemSegue");
    OCMStub([mockSegue destinationViewController]).andReturn(mockNavigationController);
    
    [self.toDoListTableViewController prepareForSegue:mockSegue sender:nil];
    
    XCTAssertEqual(self.coreDataTestHelper.managedObjectContext, addToDoItemViewController.managedObjectContext, "Managed object context should be set");
}

- (void)testWhenGettingEditActionsForRowAtIndexPathThenTheDeleteActionIsTheLastIntheList {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    NSArray *actions = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView editActionsForRowAtIndexPath:indexPath];
    
    XCTAssertNotNil(actions, "Action array should not be nil");
    XCTAssertTrue([actions count] > 0, "Action array should not be empty");
    UITableViewRowAction *action = [actions lastObject];
    XCTAssertTrue([@"Delete" isEqualToString:action.title], "Wrong action title");
}

- (void)testGivenOneItemInTheModelWhenTheCorrespondingCellIsDeletedThenTheTableIsEmpty {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    [self.toDoListTableViewController view];

    [self.toDoListTableViewController deleteItemForIndexPath:indexPath fromTableView:self.toDoListTableViewController.tableView];

    NSInteger rowCount = [self.toDoListTableViewController tableView:self.toDoListTableViewController.tableView numberOfRowsInSection:0];
    XCTAssertEqual(0, rowCount, "Should be no rows in the table (item deleted)");
}

- (void)testWhenARowIsDeletedThenItIsDeletedFromTheTable {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    [self.toDoListTableViewController view];
    id mockTableView = OCMClassMock([UITableView class]);
    OCMExpect([mockTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]);
    
    [self.toDoListTableViewController deleteItemForIndexPath:indexPath fromTableView:mockTableView];
    
    OCMVerifyAll(mockTableView);
}

- (void)testGivenAnItemInTheModelWhenTheCorrespondingCellIsDeletedThenTheItemIsDeletedFromTheManagedObjectContext {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.coreDataTestHelper persistToDoItem:ITEM_NAME withCompleted:NO];
    [self.toDoListTableViewController view];

    [self.toDoListTableViewController deleteItemForIndexPath:indexPath fromTableView:self.toDoListTableViewController.tableView];

    NSArray *toDoItems = [self.coreDataTestHelper findPersistedToDoItemsByName:ITEM_NAME];
    
    XCTAssertEqual(0, toDoItems.count, "ToDoItems in managed object context should be empty for given name");
}

@end
