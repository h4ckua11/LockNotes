#import "LKNFontViewController.h"
#import "LKNRootListController.h"

@implementation LKNFontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(NSMutableArray *)specifiers {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    if(!prefs) {
        prefs = [[NSDictionary alloc] init];
    }

    if(!_specifiers) {
        NSLog(@"[LockNotes] Settings Specifiers");
        _specifiers = [[NSMutableArray alloc] init];

        __block NSString *currentFont = [prefs objectForKey:@"fontName"];
        if([currentFont isEqual:@""]) {
            currentFont = @"None";
        }

        [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Current Font"]];
        [_specifiers addObject:[PSSpecifier preferenceSpecifierNamed:currentFont target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil]];

        NSMutableArray *fonts = [[NSMutableArray alloc] init];
        for (NSString* familyName in [UIFont familyNames]){
            [_specifiers addObject:[PSSpecifier groupSpecifierWithName:familyName]];
            for (NSString* fontName in [UIFont fontNamesForFamilyName:familyName]) {
                [fonts addObject:fontName];
                PSSpecifier *font = [PSSpecifier preferenceSpecifierNamed:fontName target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
                // SEL setFont = [self performSelector:@selector(setFont:) withObject:fontName];
                font->action = @selector(setFont:);
                [_specifiers addObject:font];
            }
        }
        
        NSLog(@"[LockNotes] Set Specifiers");
    }

    return _specifiers;
}

- (PSTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSTableCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    cell.textLabel.font = [UIFont fontWithName:[cell.specifier name] size:[UIFont buttonFontSize]];

    return cell;
}

- (void)setFont:(PSSpecifier*)fontName {
    NSLog(@"[LockNotes] FontName: %@", fontName.name);
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    [prefs setObject:fontName.name forKey:@"fontName"];
    [prefs writeToFile:plistPath atomically:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                            message:@"Changed Font!"
                            preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:^{
            [NSThread sleepForTimeInterval:0.1f];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }];
    });
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

@end