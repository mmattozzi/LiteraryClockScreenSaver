//
//  ConfigureSheetController.m
//  LiteraryClockScreenSaver
//
//  Created by Mike Mattozzi on 8/10/18.
//  Copyright © 2018 Mike Mattozzi. All rights reserved.
//

#import "ConfigureSheetController.h"

@implementation ConfigureSheetController

@synthesize licenseText;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *pathOfLicense = [[NSBundle bundleForClass:[self class]] pathForResource:@"LICENSE" ofType:@"txt"];
    NSString* fileContents = [NSString stringWithContentsOfFile:pathOfLicense encoding:NSUTF8StringEncoding error:nil];
    [licenseText setString:fileContents];
}

- (IBAction) clickOk:(id)sender {
    NSLog(@"Got OK click");
    [[NSApplication sharedApplication] endSheet:self.window];
}

@end
