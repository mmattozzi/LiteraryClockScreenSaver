//
//  LiteraryClockScreenSaverView.h
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
