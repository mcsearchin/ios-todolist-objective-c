#import "CoreDataTestHelper.h"
#import "AddToDoItemViewController.h"
#import "ToDoItem.h"

#import <CoreData/CoreData.h>
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface AddToDoItemViewControllerTests : XCTestCase

@property AddToDoItemViewController *addToDoItemViewController;
@property UIStoryboard *storyboard;
@property CoreDataTestHelper *coreDataTestHelper;

@end

@implementation AddToDoItemViewControllerTests

static NSString *const ITEM_NAME = @"item name";

- (void)setUp {
    [super setUp];
    [self setUpController];
    self.coreDataTestHelper = [[CoreDataTestHelper alloc] init];
    self.addToDoItemViewController.managedObjectContext = self.coreDataTestHelper.managedObjectContext;
    [self.addToDoItemViewController view];
}

- (void)setUpController {
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.addToDoItemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToDoItemViewController"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGivenTheNameTextFieldIsSetWhenPreparingForSaveSegueThenAToDoItemWithTheSameNameIsSavedToTheManagedObjectContext {
    self.addToDoItemViewController.nameTextField.text = ITEM_NAME;

    [self.addToDoItemViewController prepareForSegue:nil sender:self.addToDoItemViewController.saveButton];
    
    NSArray *toDoItems = [self.coreDataTestHelper findAllPersistedToDoItems];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should not be nil for given name");
    XCTAssertEqual(1, [toDoItems count], "Should have found one ToDoItem in managed object context for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertTrue([ITEM_NAME isEqualToString:toDoItem.itemName], "Wrong item name");
}

- (void)testWhenPreparingForSaveSegueThenTheNewSavedToDoItemIsNotCompleted {
    self.addToDoItemViewController.nameTextField.text = ITEM_NAME;
    
    [self.addToDoItemViewController prepareForSegue:nil sender:self.addToDoItemViewController.saveButton];
    
    NSArray *toDoItems = [self.coreDataTestHelper findAllPersistedToDoItems];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should not be nil for given name");
    XCTAssertEqual(1, [toDoItems count], "Should have found one ToDoItem in managed object context for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertFalse([toDoItem.completed boolValue], "ToDoItem should not be completed");
}

- (void)testWhenPreparingForSaveSegueThenTheNewSavedToDoItemCreatedAndLastModifiedDateAreTheCurrentDate {
    NSDate *before = [NSDate date];
    self.addToDoItemViewController.nameTextField.text = ITEM_NAME;
    
    [self.addToDoItemViewController prepareForSegue:nil sender:self.addToDoItemViewController.saveButton];
    
    NSArray *toDoItems = [self.coreDataTestHelper findAllPersistedToDoItems];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertEqual(1, [toDoItems count], "Should have found one ToDoItem in managed object context for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertTrue([before compare:toDoItem.createdDate] <= NSOrderedAscending, "Created date should be after test began");
    XCTAssertTrue([before compare:toDoItem.lastModifiedDate] <= NSOrderedAscending, "Last modified date should be after test began");
}

- (void)testGivenTheNameTextFieldIsSetWhenPreparingForASegueOtherThanSaveThenNoToDoItemIsSaved {
    self.addToDoItemViewController.nameTextField.text = ITEM_NAME;
    
    [self.addToDoItemViewController prepareForSegue:nil sender:nil];
    
    NSArray *toDoItems = [self.coreDataTestHelper findAllPersistedToDoItems];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertEqual(0, [toDoItems count], "Should not have found any ToDoItems in managed object context");
}

- (void)testGivenTheNameTextFieldIsSetWithLeadingAndTrailingWhiteSpaceWhenPreparingForSaveSegueThenAToDoItemWithTheTrimmedNameIsSavedToTheManagedObjectContext {
    self.addToDoItemViewController.nameTextField.text = [[@" " stringByAppendingString:ITEM_NAME] stringByAppendingString:@"   "];
    
    [self.addToDoItemViewController prepareForSegue:nil sender:self.addToDoItemViewController.saveButton];
    
    NSArray *toDoItems = [self.coreDataTestHelper findAllPersistedToDoItems];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertEqual(1, [toDoItems count], "Should have found one ToDoItem in managed object context for given name");
    ToDoItem *toDoItem = toDoItems[0];
    XCTAssertTrue([ITEM_NAME isEqualToString:toDoItem.itemName], "Wront item name");
}

- (void)testGivenTheNameTextFieldIsBlankWhenPreparingForSaveSegueThenNoToDoItemIsSaved {
    self.addToDoItemViewController.nameTextField.text = @"    ";
    
    [self.addToDoItemViewController prepareForSegue:nil sender:self.addToDoItemViewController.saveButton];
    
    NSArray *toDoItems = [self.coreDataTestHelper findAllPersistedToDoItems];
    XCTAssertNotNil(toDoItems, "ToDoItems in managed object context should never be nil");
    XCTAssertEqual(0, [toDoItems count], "Should not have found any ToDoItems in managed object context");
}

@end
