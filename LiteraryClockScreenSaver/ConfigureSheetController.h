//
//  ConfigureSheetController.h
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/10/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConfigureSheetController : NSWindowController

@property (strong) IBOutlet NSTextView* licenseText;

- (IBAction) clickOk:(id)sender;

@end
