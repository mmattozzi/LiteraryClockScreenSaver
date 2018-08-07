//
//  HighlightedQuote.h
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/6/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighlightedQuote : NSObject

@property (retain) NSString *quote;
@property (retain) NSString *author;
@property (retain) NSString *book;
@property (retain) NSString *timeString;

+ (HighlightedQuote *) initWithQuote:(NSString *)quote author:(NSString *)author book:(NSString *)book timeString:(NSString *)timeString;
- (NSRange) rangeOfHighlight;

@end
