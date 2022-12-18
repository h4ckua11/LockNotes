#import <libactivator/libactivator.h>
#import "../Shared.h"

static NSString *bundleID = @"com.h4ckua11.locknotes/listenerListener";
static LAActivator *_LASharedActivator;

@interface LockNotesListener : NSObject <LAListener>
@end

@implementation LockNotesListener

static LockNotesListener *myDataSource;

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if([self isSelected]){
		NSLog(@"[LockNotes] Is Selected");
		[self setSelected:![self isSelected]];
	} else {
		NSLog(@"[LockNotes] Not Selected");
		[self setSelected:![self isSelected]];
	}

	[event setHandled:YES]; // To prevent the default OS implementation
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
	return [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/LockNotes.bundle/icon.png"];
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
	return [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/LockNotes.bundle/icon.png"];
}

+ (void)load
{
        @autoreleasepool {
                myDataSource = [[LockNotesListener alloc] init];
        }
}

- (id)init {
        if ((self = [super init])) {
			NSLog(@"[LockNotes] Registering Event");
			[LASharedActivator registerListener:self forName:@"LockNotes"];
        }
        return self;
}

- (BOOL)isSelected {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    NSString *state = [prefs objectForKey:@"isShown"];

    if ([state isEqualToString:@"no"]) { 
        return YES;
    }

    return NO;
}

- (void)setSelected:(BOOL)selected {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];

    if (!prefs ) {
        prefs = [[NSMutableDictionary alloc] init];
    }

	NSLog(@"[LockNotes] State: %@", [prefs objectForKey:@"isShown"]);

    if (selected) {
    	[prefs setObject:@"no" forKey:@"isShown"];
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"enabledSwitch"];
    } else {
		[prefs setObject:@"yes" forKey:@"isShown"];
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"enabledSwitch"];
	}

    [prefs writeToFile:plistPath atomically:YES];

    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.h4ckua11.locknotes/updateState" object:nil userInfo:nil];
}

@end