#import "../Shared.h"
#import "../SparkColourPickerUtils.h"

// UIViewController *LKNTextViewController;
UITextView *LKNTextView;

@interface SBFTouchPassThroughView : UIView

-(void)viewDidLoad;

@end

%hook SBFTouchPassThroughView

- (instancetype)initWithFrame:(CGRect)frame {
    //%orig;
    self = %orig;
    NSLog(@"[LockNotes] VIEW::: %@",NSStringFromClass([self class]));

    if(![NSStringFromClass([self class]) isEqual:@"SBCoverSheetParallaxContainerView"]){
        return self;
    }

    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if(!prefs) {
        prefs = [[NSDictionary alloc] init];
    }

    NSLog(@"[LockNotes] yee %@", NSStringFromClass([self class]));
    NSLog(@"[LockNotes] Subviews: %@", self.subviews);

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState) name:@"com.h4ckua11.locknotes/updateState" object:nil];

    // LKNTextViewController = [[UIViewController alloc] initWithFrame:UIScreen.mainScreen.bounds];
    // [LKNTextViewController setEditable:NO];

    BOOL hidden = (![[prefs objectForKey:@"isShown"] isEqual:@"no"]) ? NO : YES;
    CGFloat padding = ([prefs objectForKey:@"paddingTop"]) ? [[prefs objectForKey:@"paddingTop"] floatValue] : 0.0;

    LKNTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,padding, UIScreen.mainScreen.bounds.size.width, (UIScreen.mainScreen.bounds.size.height - padding))];
    NSLog(@"[LockNotes] Colour: %@", [[prefs objectForKey:@"fontColour"] componentsSeparatedByString:@":"][0]);
    // UIColor *fontColour = ([prefs objectForKey:@"fontColour"]) ? [UIColor colorWithHexString:[[prefs objectForKey:@"fontColour"] componentsSeparatedByString:@":"][0]] : [UIColor blackColor];
    // UIColor *fontColour = [self colorWithHexString:@"#BADA55"];
    LKNTextView.textColor = [SparkColourPickerUtils colourWithString:[prefs objectForKey:@"fontColour"]];
    LKNTextView.backgroundColor = [UIColor clearColor];
    LKNTextView.hidden = hidden;
    __block UIFont *font;
    if([prefs objectForKey:@"fontName"] && [prefs objectForKey:@"fontSize"]){
        font = [UIFont fontWithName:[prefs objectForKey:@"fontName"] size:[[prefs objectForKey:@"fontSize"] floatValue]];
    } else if([prefs objectForKey:@"fontName"] && ![prefs objectForKey:@"fontSize"]) {
        font = [UIFont fontWithName:[prefs objectForKey:@"fontName"] size:15];
    } else if(![prefs objectForKey:@"fontName"] && [prefs objectForKey:@"fontSize"]) {
        font = [UIFont systemFontOfSize:[[prefs objectForKey:@"fontSize"] floatValue]];
    } else {
        font = [UIFont systemFontOfSize:15];
    }
    LKNTextView.font = font;
    LKNTextView.userInteractionEnabled = NO;
    [LKNTextView setEditable:NO];
    __block NSTextAlignment textAlignment;
    if([[prefs objectForKey:@"textAlignment"] isEqual:@"right"]) {
        textAlignment = NSTextAlignmentRight;
    } else if([[prefs objectForKey:@"textAlignment"] isEqual:@"center"]) {
        textAlignment = NSTextAlignmentCenter;
    } else {
        textAlignment = NSTextAlignmentLeft;
    }
    [LKNTextView setTextAlignment:textAlignment];
    // [LKNTextViewController addSubview:LKNTextView];
    [self addSubview:LKNTextView];
    return self;
}

%new
- (void)updateState {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    BOOL hidden = (![[prefs objectForKey:@"isShown"] isEqual:@"no"]) ? NO : YES;
    CGFloat padding = ([prefs objectForKey:@"paddingTop"]) ? [[prefs objectForKey:@"paddingTop"] floatValue] : 0.0;

    [LKNTextView setHidden:hidden];
    LKNTextView.text = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:@"/var/mobile/Library/LockNotes/LockscreenText.txt"] encoding:NSUTF8StringEncoding];
    // UIColor *fontColour = ([prefs objectForKey:@"fontColour"]) ? [UIColor colorWithHexString:[[prefs objectForKey:@"fontColour"] componentsSeparatedByString:@":"][0]] : [UIColor blackColor];
    // UIColor *fontColour = [self colorWithHexString:@"#BADA55"];
    LKNTextView.textColor = [SparkColourPickerUtils colourWithString:[prefs objectForKey:@"fontColour"]];
    // LKNTextView.tintColor = [UIColor blueColor];
    __block UIFont *font;
    if([prefs objectForKey:@"fontName"] && [prefs objectForKey:@"fontSize"]){
        font = [UIFont fontWithName:[prefs objectForKey:@"fontName"] size:[[prefs objectForKey:@"fontSize"] floatValue]];
    } else if([prefs objectForKey:@"fontName"] && ![prefs objectForKey:@"fontSize"]) {
        font = [UIFont fontWithName:[prefs objectForKey:@"fontName"] size:15];
    } else if(![prefs objectForKey:@"fontName"] && [prefs objectForKey:@"fontSize"]) {
        font = [UIFont systemFontOfSize:[[prefs objectForKey:@"fontSize"] floatValue]];
    } else {
        font = [UIFont systemFontOfSize:15];
    }
    LKNTextView.font = font;
    __block NSTextAlignment textAlignment;
    if([[prefs objectForKey:@"textAlignment"] isEqual:@"right"]) {
        textAlignment = NSTextAlignmentRight;
    } else if([[prefs objectForKey:@"textAlignment"] isEqual:@"center"]) {
        textAlignment = NSTextAlignmentCenter;
    } else {
        textAlignment = NSTextAlignmentLeft;
    }
    [LKNTextView setTextAlignment:textAlignment];
    LKNTextView.frame = CGRectMake(0,padding, UIScreen.mainScreen.bounds.size.width, (UIScreen.mainScreen.bounds.size.height - padding));
    NSLog(@"[LockNotes] Updated TextView");
}

%end
