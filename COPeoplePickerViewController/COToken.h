//
//  COToken.h
//  COPeoplePickerViewController
//
//  Created by Maciej Trybiło on 17/06/2013.
//  Copyright (c) 2013 chocomoko.com. All rights reserved.
//
/*
 * The original design displayed the email address of the user and nothing else.
 * For HHM use, the token will need to display the contactName or the emailAddress and
 * be able to toggle between them.  
 *
 * In some cases, the user will enter an email address but it will not have an associated
 * ABContact, so it will not have a contactName (or an associated object)
 *
 */

#import <UIKit/UIKit.h>

extern const CGFloat kTokenFieldFontSize;
extern const CGFloat kTokenFieldTokenHeight;
extern const CGFloat kTokenFieldInsetX;
extern const CGFloat kTokenFieldPaddingX;
extern const CGFloat kTokenFieldPaddingY;

@class COTokenField;

@interface COToken : UIButton
@property (nonatomic, strong) NSString * contactName;
@property (nonatomic, strong) NSString * emailAddress;
@property (nonatomic, strong) id associatedObject;
@property (nonatomic, assign) BOOL showName;

- (void) toggleDisplayName;

+ (COToken *)tokenWithEmailAddress:(NSString *)emailAddress contactName:(NSString *) contactName associatedObject:(id)obj;

@end
