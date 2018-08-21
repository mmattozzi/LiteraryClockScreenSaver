//
//  LiteraryClockScreenSaverView.h
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/5/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "ConfigureSheetController.h"

@interface LiteraryClockScreenSaverView : ScreenSaverView {
    CGFloat backgroundImageX;
    NSRect backgroundImageRect;
    NSMutableArray* backgroundImageList;
    NSUInteger backgroundImageIndex;
    CGFloat textPositionY;
    NSString *lastRenderedTime;
    NSUInteger currentRandom;
}

@property (retain) NSMutableDictionary *timeToQuote;
@property NSInteger fileLength;
@property (retain) NSString* resourcePath;
@property (retain) ConfigureSheetController* configureSheetController;

- (void) addBasicMainTextAttributes:(NSMutableAttributedString*)str;
- (NSRect) calculateCreditRect:(NSRect)quoteRect;

@end
