//
//  COTokenField.h
//  COPeoplePickerViewController
//
//  Created by Maciej Trybiło on 17/06/2013.
//  Copyright (c) 2013 chocomoko.com. All rights reserved.
//

/*
 * Note:  This design assumes that autoLayout is turned off around this view.  If it is enabled,
 * the application will get stuck in loops.
 *
 *
 * This view communicates with its environment through both the delegate and changes in the 'frame' size.
 * The delegate tracks changes in the contents of the field while the view updates its height as new items
 * are added.  The height simply grows to accommodate all the entries.  If the UI needs to restrict the space
 * of the field, then the view can be put in a scroll view.
 *
 *
 * The delegate is assumed to have an AddressBookRef to use for searching for matching names.
 * As this field receives characters, this field processes them and then 
 * reports a changed list of names from the address book to use in the tableView. 
 *
 * The delegate also supports two other methods, addcontactbutton pressed and searchingModeChanged. 
 * These are used to alert the user of the view of actions taken.
 * - didPressAddContactButton allows the user of this class to display the full AddressBookUI view for 
 *   interacting with the AddressBook
 * - searchingModeChanged is reported to the delegate when the field enters searching (a character is typed) and when 
 *   the user finalizing selecting a token (by calling processToken:associatedRecord)
 *
 *
 * To better emulate the iOS7 behavior, I have added a new mode to this view; compactMode.  
 * In 'compactMode', the display is only one line high and will truncate names with 'and x more' if the
 * list is too long for one line.  This is not an externally controlled mode.
 *
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

extern const CGFloat kTokenFieldShadowHeight;

@class COTokenField;
@class COToken;
@class ABContact;

@protocol COTokenFieldDelegate <NSObject>
@required

- (void)tokenFieldDidPressAddContactButton:(COTokenField *)tokenField;
- (ABAddressBookRef)addressBookForTokenField:(COTokenField *)tokenField;
- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults:(NSArray *)records;
- (void)tokenField:(COTokenField *)tokenField searchingModeChanged:(BOOL)isInSearchingMode;
@end


@interface COTokenField : UIView <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet id<COTokenFieldDelegate> tokenFieldDelegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) UIButton *addContactButton;
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) COToken *selectedToken;
@property (nonatomic, readonly) CGFloat computedRowHeight;
@property (nonatomic, readonly) NSString *textWithoutDetector;

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows;
- (void)selectToken:(COToken *)token;
- (void)removeAllTokens;
- (void)removeToken:(COToken *)token;
- (void)modifyToken:(COToken *)token;
- (void)modifySelectedToken;
- (void)processTokenWithEmailAddress:(NSString *) emailAddress contactName:(NSString *)contactName  associatedRecord:(ABContact *)record;
- (void)tokenInputChanged:(id)sender;

@end
