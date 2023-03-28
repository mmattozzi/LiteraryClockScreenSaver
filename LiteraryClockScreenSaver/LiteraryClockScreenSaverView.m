//
//  LiteraryClockScreenSaverView.m
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/5/18.
//  Copyright © 2023 Mike Mattozzi.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
                HighlightedQuote *highlightedQuote = [HighlightedQuote initWithQuote:columns[2] author:columns[4] book:[columns[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] timeString:columns[1]];
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
    
    // Set up the layer for the screensaver
    mainLayer = [CALayer layer];
    mainLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    mainLayer.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0); // black background
    [self setLayer:mainLayer];
    [self setWantsLayer:YES];
    
    backgroundImageLayer = [CALayer layer];
    [backgroundImageLayer setBounds:CGRectMake(0, 0, [mainLayer bounds].size.width*1.2, [mainLayer bounds].size.height*1.2)];
    [backgroundImageLayer setPosition:CGPointMake([mainLayer bounds].size.width/2.0, [mainLayer bounds].size.height/2.0)];
    backgroundImageLayer.contents = [backgroundImageList objectAtIndex:backgroundImageIndex];
    [backgroundImageLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
    [backgroundImageLayer setContentsGravity:kCAGravityResizeAspectFill];
    [mainLayer addSublayer:backgroundImageLayer];
    
    // Create a new CATextLayer
    quoteTextLayer = [CATextLayer layer];

    [self selectNextQuote];
    [self setupTextLayerPropertiesWithTextLayer:quoteTextLayer textContents:currentQuote];

    // Set the layer bounds and position
    [quoteTextLayer setBounds:CGRectMake(0.0, 0.0, mainLayer.bounds.size.width*.8, mainLayer.bounds.size.height*.25)];
    [quoteTextLayer setPosition:CGPointMake(mainLayer.bounds.size.width*.45, mainLayer.bounds.size.height*.1)];

    // Add the layer to a parent layer or view
    [mainLayer addSublayer:quoteTextLayer];

    citationLayer = [CATextLayer layer];
    [citationLayer setBounds:CGRectMake(0.0, 0.0, mainLayer.bounds.size.width*.8, mainLayer.bounds.size.height*.25)];
    [citationLayer setPosition:CGPointMake(mainLayer.bounds.size.width*.45, mainLayer.bounds.size.height*.1)];
    citationLayer.opacity = 0.0;
    [self setupCitatationTextLayerPropertiesWithTextLayer:citationLayer textContents:currentQuote];
    [mainLayer addSublayer:citationLayer];
    
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    [self resumeAnimation];
}

- (void) setupTextLayerPropertiesWithTextLayer:(CATextLayer *)layer textContents:(HighlightedQuote *)quote {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *boldFontName = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:48.0];
    
    NSMutableAttributedString *highlightedString;
    if (quote) {
        highlightedString = [[NSMutableAttributedString alloc] initWithString:quote.quote];
        [highlightedString beginEditing];
        [self addBasicMainTextAttributes:highlightedString];
        [highlightedString addAttribute:NSFontAttributeName value:boldFontName range:[quote rangeOfHighlight]];
        [highlightedString endEditing];
    } else {
        highlightedString = [[NSMutableAttributedString alloc] initWithString:[self createFormattedTime]];
        [highlightedString beginEditing];
        [self addBasicMainTextAttributes:highlightedString];
        [highlightedString endEditing];
    }
    
    [layer setString:highlightedString];
    
    // Set the alignment and wrapping mode
    [layer setAlignmentMode:kCAAlignmentLeft];
    [layer setWrapped:YES];
}

- (void) setupCitatationTextLayerPropertiesWithTextLayer:(CATextLayer *)layer textContents:(HighlightedQuote *)quote {
    if (quote) {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *creditFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:24.0];
        NSString *credit = [NSString stringWithFormat:@"%@, %@", quote.book, quote.author];
        
        [layer setFont:(__bridge CTFontRef) creditFont];
        [layer setString:credit];
        
        // Set the alignment and wrapping mode
        [layer setAlignmentMode:kCAAlignmentCenter];
        [layer setWrapped:YES];
    }
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)resumeAnimation {
    CABasicAnimation *backgroundImageAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    backgroundImageAnimation.fromValue = @([backgroundImageLayer position].x);
    if ([backgroundImageLayer position].x > 0) {
        backgroundImageAnimation.toValue = @([backgroundImageLayer position].x - [mainLayer bounds].size.width*0.1);
    } else {
        backgroundImageAnimation.toValue = @([backgroundImageLayer position].x + [mainLayer bounds].size.width*0.1);
    }
    backgroundImageAnimation.duration = 60.0;
    backgroundImageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    backgroundImageAnimation.fillMode = kCAFillModeForwards;
    backgroundImageAnimation.removedOnCompletion = NO;
    [backgroundImageLayer addAnimation:backgroundImageAnimation forKey:@"position.x"];
    
    CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    textAnimation.fromValue = @([quoteTextLayer position].y);
    textAnimation.toValue = @([quoteTextLayer position].y + mainLayer.bounds.size.height*.4);
    textAnimation.duration = 60.0;
    textAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    textAnimation.fillMode = kCAFillModeForwards;
    textAnimation.removedOnCompletion = NO;
    [quoteTextLayer addAnimation:textAnimation forKey:@"position.y"];
    
    NSDate* now = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSInteger second = [dateComponents second];
    
    if (second < 15 && currentQuote != nil) {
        CATextLayer* layer = citationLayer;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Create an animation that gradually increases the layer's opacity to 1.0 over a duration of 1 second
            CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeInAnimation.duration = 1.0;
            fadeInAnimation.fromValue = @(0.0);
            fadeInAnimation.toValue = @(1.0);
            fadeInAnimation.fillMode = kCAFillModeForwards;
            fadeInAnimation.removedOnCompletion = NO;

            // Add the animation to the layer
            [layer addAnimation:fadeInAnimation forKey:@"fadeIn"];
        });
    }
}

- (void)animateOneFrame
{
    BOOL quoteChanged = [self selectNextQuote];
    
    if (quoteChanged) {
        [backgroundImageLayer removeAllAnimations];
        [quoteTextLayer removeAllAnimations];
        [citationLayer removeAllAnimations];
        
        backgroundImageIndex += 1;
        backgroundImageIndex = backgroundImageIndex % [backgroundImageList count];
        backgroundImageLayer.contents = [backgroundImageList objectAtIndex:backgroundImageIndex];
        
        [self setupTextLayerPropertiesWithTextLayer:quoteTextLayer textContents:currentQuote];
        
        citationLayer.opacity = 0.0;
        [self setupCitatationTextLayerPropertiesWithTextLayer:citationLayer textContents:currentQuote];
        
        [self resumeAnimation];
    }
}

- (NSString*) createFormattedTime {
    NSDate* now = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    
    NSString *paddedHour = [NSString stringWithFormat:@"%02ld", hour];
    NSString *paddedMinute = [NSString stringWithFormat:@"%02ld", minute];
    NSString *formattedTime = [NSString stringWithFormat:@"%@:%@", paddedHour, paddedMinute];
    
    return formattedTime;
}

- (BOOL) selectNextQuote {
    NSString *formattedTime = [self createFormattedTime];
    BOOL quoteChanged = NO;
    
    // Whenever the time changes between frames, draw a new random number
    if (! [formattedTime isEqualToString:lastRenderedTime]) {
        currentRandom = arc4random_uniform(10000);
        lastRenderedTime = formattedTime;
        quoteChanged = YES;
        
        HighlightedQuote *timeQuote = nil;
        NSMutableArray *quoteList = [timeToQuote valueForKey:formattedTime];
        if (quoteList && [quoteList count] > 0) {
            timeQuote = quoteList[currentRandom % [quoteList count]];
        }
        
        currentQuote = timeQuote;
    }
    
    return quoteChanged;
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
