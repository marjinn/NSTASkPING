//
//  NSTASkPINGAppDelegate.h
//  NSTASkPING
//
//  Created by theNotSoBrightLazyNovice on 5/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTASkPINGAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	IBOutlet NSTextView		*outputView;
	IBOutlet NSTextField	*hostField;
	IBOutlet NSButton		*startButton;
	NSTask					*task;
	NSPipe					*pipe;
	
	IBOutlet NSTextView     *outputViewZip;
	
	NSTask					*nu_task;
	NSPipe					*nu_pipe;
	
	}

@property (assign) IBOutlet NSWindow *window;
-(IBAction)startStopPing:(id)sender;
-(IBAction)openZip:(id)sender;
@end
