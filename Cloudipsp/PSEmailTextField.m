#import "PSEmailTextField.h"
#import "PSTextFieldHandler.h"

@implementation PSEmailTextField

- (PSTextFieldHandler *)setup {
    self.keyboardType = UIKeyboardTypeEmailAddress;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;

    return nil;
}

@end
