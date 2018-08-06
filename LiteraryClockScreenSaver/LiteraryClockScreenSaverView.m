//
//  LiteraryClockScreenSaverView.m
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/5/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import "LiteraryClockScreenSaverView.h"

@implementation LiteraryClockScreenSaverView

@synthesize timeToQuote;
@synthesize fileLength;
@synthesize resourcePath;
@synthesize lastY;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
    
    NSString* timeFormat = @"^\\d\\d:\\d\\d";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d\\d"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    lastY = 200.0;
    
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
            [timeToQuote setObject:columns[2] forKey:columns[0]];
            NSLog(@"%ld quotes stored.", [timeToQuote count]);
        } else {
            NSLog(@"%@ does not seem formatted correctly.", row);
        }
    }
    
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
    
    NSString *paddedHour = [NSString stringWithFormat:@"%02ld", hour];
    NSString *paddedMinute = [NSString stringWithFormat:@"%02ld", minute];
    NSString *formattedTime = [NSString stringWithFormat:@"%@:%@", paddedHour, paddedMinute];
    
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    [[NSColor lightGrayColor] set];
    
    NSString *timeString = [timeToQuote valueForKey:formattedTime];
    if (lastY > self.bounds.size.height) {
        lastY = 0;
    }
    NSRect quoteRect = self.bounds;
    quoteRect.origin.y = lastY;
    quoteRect.origin.x = 100.0;
    quoteRect.size.width = quoteRect.size.width - 200.0;
    quoteRect.size.height = 100.0;
    
    NSFont* font = [NSFont fontWithName:@"Helvetica Bold" size:24.0];
    
    if (timeString) {
        //[timeString drawAtPoint:NSMakePoint(100.0, lastY) withAttributes:nil];
        [timeString drawInRect:quoteRect withAttributes:@{
               NSForegroundColorAttributeName: [NSColor lightGrayColor],
               NSFontAttributeName: font
            }];
    } else {
        //[formattedTime drawAtPoint:NSMakePoint(100.0, lastY) withAttributes:nil];
        [formattedTime drawInRect:quoteRect withAttributes:@{
                                                             NSForegroundColorAttributeName: [NSColor lightGrayColor],
                                                             NSFontAttributeName: font
                                                             }];
    }
    
    // Scroll bottom to top, slowly
    lastY = lastY + 1;
    
    // Debug string
    NSString *infoString = [NSString stringWithFormat:@"Path: %@, File length: %ld, Quote count: %ld, Time string: %@", resourcePath, fileLength, [timeToQuote count], formattedTime];
    [infoString drawAtPoint:NSMakePoint(100.0, 100.0) withAttributes:@{
                                                                       NSForegroundColorAttributeName: [NSColor lightGrayColor]
                                                                       }];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
