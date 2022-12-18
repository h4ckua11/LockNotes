#import "LKNRootListController.h"

@implementation LKNRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view endEditing:YES];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSwitch) name:@"com.h4ckua11.locknotes/updateState" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadSpecifierForValue:@"enabledSwitch"];
}

- (void)didTapSetText {
   
    _setTextViewController = [[UIViewController alloc] init];
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(didTapSaveTextButton)];
    [_setTextViewController.navigationItem setRightBarButtonItem:saveBtn animated:YES];
    _setTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    _setTextView.backgroundColor = [UIColor whiteColor];
    [_setTextView setEditable:YES];
    _setTextView.text = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:@"/var/mobile/Library/LockNotes/LockscreenText.txt"] encoding:NSUTF8StringEncoding];
    _setTextViewController.view = _setTextView;
    [self.navigationController pushViewController:_setTextViewController animated:YES];
}

-(void)didTapSaveTextButton {
    NSLog(@"[LockNotes] Button Pressed");
    NSLog(@"[LockNotes] Text: %@", _setTextView.text);
    [_setTextViewController.view endEditing:YES];
    NSError *error;

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL yes = YES;
    if(![fm fileExistsAtPath:@"/var/mobile/Library/LockNotes/" isDirectory:&yes]) {
        [fm createDirectoryAtPath:@"/var/mobile/Library/LockNotes/" withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if(![fm fileExistsAtPath:@"/var/mobile/Library/LockNotes/LockscreenText.txt"]) {
        [fm createFileAtPath:@"/var/mobile/Library/LockNotes/LockscreenText.txt" contents:nil attributes:nil];
    }

    [_setTextView.text writeToFile:@"/var/mobile/Library/LockNotes/LockscreenText.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];

    if(!error) {
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.h4ckua11.locknotes/updateState" object:nil userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                    message:@"Saved!"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
                [self presentViewController:alert animated:YES completion:^{
                    [NSThread sleepForTimeInterval:0.1f];
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }];
            });
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                               message:[NSString stringWithFormat:@"oops... an error occured. Here's the log: \n\n%@", error]
                               preferredStyle:UIAlertControllerStyleAlert];
 
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Well,, shit" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
 
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (void)didTapChangeFont {
    NSMutableArray *fonts = [[NSMutableArray alloc] init];
    for (NSString* familyName in [UIFont familyNames]){
        for (NSString* fontName in [UIFont fontNamesForFamilyName:familyName]) {
            [fonts addObject:fontName];
        }
         // Store font names or do whatever you want
         // You can create font object using 
         // [UIFont fontWithName:fontName size:fontSize];
    }
    NSLog(@"[LockNotes] Fonts: %lu", fonts.count);
}

- (void)updateState {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *yesOrNo = ([[prefs objectForKey:@"isShown"] isEqual:@"yes"]) ? @"no" : @"yes";
    BOOL enabledSwitch = ([[prefs objectForKey:@"isShown"] isEqual:@"yes"]) ? 0 : 1;
    [prefs setObject:yesOrNo forKey:@"isShown"];
    [prefs setObject:[NSNumber numberWithBool:enabledSwitch] forKey:@"enabledSwitch"];
    [prefs writeToFile:plistPath atomically:YES];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.h4ckua11.locknotes/updateState" object:nil userInfo:nil];
    [self reloadSpecifierForValue:@"enabledSwitch"];
}

- (void)updateEnableSwitch {
    NSLog(@"[LockNotes] EnableSwitch");
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    BOOL yesOrNo = ([[prefs objectForKey:@"isShown"] isEqual:@"yes"]) ? 1 : 0;
    [prefs setObject:[NSNumber numberWithBool:yesOrNo] forKey:@"enabledSwitch"];
    [prefs writeToFile:plistPath atomically:YES];
    // [self reloadSpecifierForValue:@"enabledSwitch"];
}

- (void)updateSwitch {
    [self reloadSpecifierForValue:@"enabledSwitch"];
}

- (void)respringNow {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/sbreload";
    [task launch];
    [task waitUntilExit];
}

// Background Stuff...

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (PSSpecifier *)specifierForKey:(NSString *)key {
    for (PSSpecifier *spec in _specifiers) {
        NSString *keyInLoop = [spec propertyForKey:@"key"];
        if ([keyInLoop isEqualToString:key]) {
            return spec;
        }
    }
    return nil;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    id object = [dict objectForKey:[specifier propertyForKey:@"key"]];
    if (!object) {
        object = [specifier propertyForKey:@"default"];
    }
    return object;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    [dict setObject:value forKey:[specifier propertyForKey:@"key"]];
    [dict writeToFile:plistPath atomically:YES];
}

- (void)reloadSpecifierForValue:(NSString *)specifier {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self reloadSpecifier:[self specifierForKey:specifier] animated:YES];
	});
}

- (void)_keyboardWillShow:(NSNotification *)sender {
    [super _keyboardWillShow:sender];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(didTapDoneButton)];
    [self.navigationItem setRightBarButtonItem:btn animated:YES];
}

- (void)_keyboardWillHide:(NSNotification *)sender {
    [super _keyboardWillHide:sender];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)_returnKeyPressed:(NSNotification *)sender {
    [self.view endEditing:YES];
    [super _returnKeyPressed:sender];
}

- (void)didTapDoneButton {
    [self.view endEditing:YES];
}

@end
