//
//  HighlightedQuote.m
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/5/18.
//  Copyright © 2018 Mike Mattozzi.
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
