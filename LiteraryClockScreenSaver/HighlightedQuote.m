//
//  HighlightedQuote.m
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/6/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import "HighlightedQuote.h"

@implementation HighlightedQuote

@synthesize quote;
@synthesize timeString;
@synthesize book;
@synthesize author;

+ (HighlightedQuote *) initWithQuote:(NSString *)quote author:(NSString *)author book:(NSString *)book timeString:(NSString *)timeString {
    HighlightedQuote *highlightedQuote = [[HighlightedQuote alloc] init];
    highlightedQuote.quote = quote;
    highlightedQuote.author = author;
    highlightedQuote.book = book;
    highlightedQuote.timeString = timeString;
    return highlightedQuote;
}

- (NSRange) rangeOfHighlight {
    NSRange range = [self.quote rangeOfString:self.timeString];
    if (range.length == 0) {
        NSLog(@"Problem finding %@ in quote %@", self.timeString, self.quote);
    }
    return range;
}

@end
