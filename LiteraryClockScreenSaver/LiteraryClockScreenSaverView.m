//
//  LiteraryClockScreenSaverView.m
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/5/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import "LiteraryClockScreenSaverView.h"
#import "HighlightedQuote.h"

@implementation LiteraryClockScreenSaverView

@synthesize timeToQuote;
@synthesize fileLength;
@synthesize resourcePath;
@synthesize configureSheetController;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
    
    configureSheetController = [[ConfigureSheetController alloc] initWithWindowNibName:@"ConfigureSheet"];
    
    backgroundImageIndex = 0;
    backgroundImageList = [[NSMutableArray alloc] init];
    lastRenderedTime = nil;
    
    for (int i = 1; i <= 7; i++) {
        NSString *fileName = [NSString stringWithFormat:@"library%d", i];
        NSLog(@"Loading image %@", fileName);
        NSString *pathOfLibraryImage = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"jpg"];
        NSImage* libraryImage = [[NSImage alloc] initWithContentsOfFile:pathOfLibraryImage];
        [backgroundImageList addObject:libraryImage];
    }
    
    NSString* timeFormat = @"^\\d\\d:\\d\\d";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d\\d"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    textPositionY = 200.0;
    backgroundImageRect = self.bounds;
    backgroundImageRect.size.height = backgroundImageRect.size.height*1.2;
    backgroundImageRect.size.width = backgroundImageRect.size.width*1.2;
    backgroundImageRect.origin.x = 0 - (backgroundImageRect.size.width - self.bounds.size.width);
    
    timeToQuote = [[NSMutableDictionary alloc] init];
    
    NSString *pathOfQuoteFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"litclock_annotated" ofType:@"csv"];
    
    fileLength = 0;
    resourcePath = pathOfQuoteFile;
    
    NSString* fileContents = [NSString stringWithContentsOfFile:pathOfQuoteFile encoding:NSUTF8StringEncoding error:nil];
    
    fileLength = [fileContents length];
    
    NSArray* rows = [fileContents componentsSeparatedByString:@"\n"];
    for (NSString *row in rows){
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:row
                                                            options:0
                                                              range:NSMakeRange(0, [row length])];
        if (numberOfMatches > 0) {
            NSArray* columns = [row componentsSeparatedByString:@"|"];
            if ([columns count] == 5) {
                HighlightedQuote *highlightedQuote = [HighlightedQuote initWithQuote:columns[2] author:columns[4] book:columns[3] timeString:columns[1]];
                NSString *timeOfQuote = columns[0];
                if (! [timeToQuote objectForKey:timeOfQuote]) {
                    [timeToQuote setObject:[[NSMutableArray alloc] initWithObjects:highlightedQuote, nil] forKey:timeOfQuote];
                } else {
                    NSMutableArray *existingList = [timeToQuote objectForKey:timeOfQuote];
                    [existingList addObject:highlightedQuote];
                }
            } else {
                NSLog(@"%@ does not seem formatted correctly; not enough columns.", row);
            }
        } else {
            NSLog(@"%@ does not seem formatted correctly.", row);
        }
    }
    
    NSLog(@"Done loading quotes. %ld quotes stored.", [timeToQuote count]);
    
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    NSDate* now = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    
    NSString *paddedHour = [NSString stringWithFormat:@"%02ld", hour];
    NSString *paddedMinute = [NSString stringWithFormat:@"%02ld", minute];
    NSString *formattedTime = [NSString stringWithFormat:@"%@:%@", paddedHour, paddedMinute];
    
    // Uncomment to run with a fixed time
    // formattedTime = @"03:05";
    // second = 45;
    
    // Whenever the time changes between frames, draw a new random number
    if (! [formattedTime isEqualToString:lastRenderedTime]) {
        currentRandom = arc4random_uniform(10000);
        lastRenderedTime = formattedTime;
    }
    
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    [[NSColor lightGrayColor] set];
    
    backgroundImageRect.origin.x += 0.25;
    if (backgroundImageRect.origin.x > 0) {
        backgroundImageRect.origin.x = 0 - (backgroundImageRect.size.width - self.bounds.size.width);
        backgroundImageIndex += 1;
        backgroundImageIndex = backgroundImageIndex % [backgroundImageList count];
    }
    [(NSImage*)[backgroundImageList objectAtIndex:backgroundImageIndex] drawInRect:backgroundImageRect];
    
    //HighlightedQuote *timeQuote = [timeToQuote valueForKey:formattedTime];
    HighlightedQuote *timeQuote = nil;
    NSMutableArray *quoteList = [timeToQuote valueForKey:formattedTime];
    if (quoteList && [quoteList count] > 0) {
        timeQuote = quoteList[currentRandom % [quoteList count]];
    }
    if (textPositionY > self.bounds.size.height) {
        textPositionY = -200.0;
    }
    NSRect quoteRect = self.bounds;
    quoteRect.origin.y = textPositionY;
    quoteRect.origin.x = 100.0;
    quoteRect.size.width = quoteRect.size.width - 200.0;
    quoteRect.size.height = 300.0;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *boldFontName = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:48.0];
    
    if (timeQuote) {
        // Wait until last 20 seconds to reveal book and author
        if (second > 40) {
            NSFont *creditFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:24.0];
            NSString *credit = [NSString stringWithFormat:@"%@, %@", timeQuote.book, timeQuote.author];
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowOffset = NSMakeSize(-3, -3);
            shadow.shadowColor = [NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:0.75];
            [credit drawInRect:[self calculateCreditRect:quoteRect] withAttributes:@{
               NSFontAttributeName: creditFont,
               NSForegroundColorAttributeName: [NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0],
               NSShadowAttributeName: shadow
           }];
        }
        
        NSMutableAttributedString *highlightedString = [[NSMutableAttributedString alloc] initWithString:timeQuote.quote];
        [highlightedString beginEditing];
        [self addBasicMainTextAttributes:highlightedString];
        [highlightedString addAttribute:NSFontAttributeName value:boldFontName range:[timeQuote rangeOfHighlight]];
        [highlightedString endEditing];
        [highlightedString drawInRect:quoteRect];
        
    } else {
        // Render times that we don't have a quote for
        NSMutableAttributedString *attributedTimeString = [[NSMutableAttributedString alloc] initWithString:formattedTime];
        [attributedTimeString beginEditing];
        [self addBasicMainTextAttributes:attributedTimeString];
        [attributedTimeString endEditing];
        [attributedTimeString drawInRect:quoteRect];
    }
    
    // Scroll bottom to top, slowly
    textPositionY = textPositionY + 0.5;
}

- (NSRect) calculateCreditRect:(NSRect)quoteRect {
    NSRect creditRect;
    NSUInteger differenceFromHeight = self.bounds.size.height - quoteRect.origin.y;
    if (differenceFromHeight > (self.bounds.size.height / 2)) {
        // Above quote
        creditRect = NSMakeRect(self.bounds.size.width*.6, (self.bounds.size.height - quoteRect.origin.y)/2 + quoteRect.origin.y,
                                self.bounds.size.width*.2, self.bounds.size.height*.2);
    } else {
        // Below quote
        creditRect = NSMakeRect(self.bounds.size.width*.6, quoteRect.origin.y /2,
                                self.bounds.size.width*.2, self.bounds.size.height*.2);
    }
    return creditRect;
}

- (void) addBasicMainTextAttributes:(NSMutableAttributedString*)str {
    NSFont* font = [NSFont fontWithName:@"Lucida Grande" size:36.0];
    NSRange fullStringRange = NSMakeRange(0, [str length]);
    [str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:fullStringRange];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = NSMakeSize(-5, -5);
    shadow.shadowColor = [NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    [str addAttribute:NSShadowAttributeName value:shadow range:fullStringRange];
    [str addAttribute:NSFontAttributeName value:font range:fullStringRange];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    return [configureSheetController window];
}

@end
