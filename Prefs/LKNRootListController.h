#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../Shared.h"
#import "../NSTask.h"
#import <Foundation/Foundation.h>

@interface PSListController ()
- (void)_keyboardWillShow:(NSNotification *)sender;
- (void)_keyboardWillHide:(NSNotification *)sender;
- (void)_returnKeyPressed:(NSNotification *)sender;
@end

@interface LKNRootListController : PSListController

@property (nonatomic, strong) UIViewController *setTextViewController;
@property (nonatomic, strong) UITextView *setTextView;

- (void)viewDidLoad;

// Background Stuff...
- (NSArray *)specifiers;
- (PSSpecifier *)specifierForKey:(NSString *)key;
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
- (void)reloadSpecifierForValue:(NSString *)specifier;

- (void)didTapDoneButton;

@end
