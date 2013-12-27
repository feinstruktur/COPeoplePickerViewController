//
//  CORecordEmail.m
//  COPeoplePickerViewController
//
//  Created by Maciej Trybiło on 17/06/2013.
//  Copyright (c) 2013 chocomoko.com. All rights reserved.
//

#import "CORecordEmail.h"

@implementation CORecordEmail

- (id)initWithEmails:(ABMultiValueRef)emails
          identifier:(ABMultiValueIdentifier)identifier
{
    self = [super init];
    if (self) {
        if (emails != NULL) {
            _emails = CFRetain(emails);
        }
        _identifier = identifier;
    }
    return self;
}

- (void)dealloc
{
    if (_emails != NULL) {
        CFRelease(_emails);
        _emails = NULL;
    }
}

- (NSString *)label
{
    CFStringRef label =
    ABMultiValueCopyLabelAtIndex(_emails, ABMultiValueGetIndexForIdentifier(_emails, _identifier));
    
    if (label != NULL) {
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(label);
        CFRelease(label);
        return CFBridgingRelease(localizedLabel);
    }
    return @"email";
}

- (NSString *)address
{
    return CFBridgingRelease(ABMultiValueCopyValueAtIndex(_emails,
                                                          ABMultiValueGetIndexForIdentifier(_emails, _identifier)));
}

@end
