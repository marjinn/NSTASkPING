//
//  NSTASkPINGAppDelegate.m
//  NSTASkPING
//
//  Created by theNotSoBrightLazyNovice on 5/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NSTASkPINGAppDelegate.h"

@implementation NSTASkPINGAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}


-(IBAction)startStopPing:(id)sender
{
	if (task) {
		[startButton setTitle:@"Start Ping"];
		[task interrupt];
	}
	else {
		[startButton setTitle:@"Stop Ping"];
		
		task = [[NSTask alloc]init];
		
		///*
		[task setLaunchPath:@"/sbin/ping"];
		
		NSArray *args = [NSArray arrayWithObjects:@"-c10",
						 [hostField stringValue],nil];
		[task setArguments:args];
		//*/
		
		//[task setCurrentDirectoryPath:@"/"];
		
		/*
		[task setLaunchPath:@"/bin/ls"];//executable location
		
		NSArray *args = [NSArray arrayWithObjects:@"-alRG",
						 nil];
		[task setArguments:args];
		 */
		
		
		//Create a new pipe
		pipe = [[NSPipe alloc]init];
		[task setStandardOutput:pipe];
		
		NSFileHandle *fh = [pipe fileHandleForReading];
		
		NSNotificationCenter *nc;
		
		nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		[nc addObserver:self
			   selector:@selector(dataRead:)
				   name:NSFileHandleReadCompletionNotification
				 object:fh];
		[nc addObserver:self
			   selector:@selector(taskTerminated:)
				   name:NSTaskDidTerminateNotification
				 object:task];	
		[task launch];
		[outputView setString:@"Ping Has Started...\n"];
		
		[fh readInBackgroundAndNotify];
	}

	
}

-(void)appendData:(NSData*)d
{
	NSString *s = [[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding];
	
	NSTextStorage *ts = [outputView textStorage];
	[ts replaceCharactersInRange:NSMakeRange([ts length],0) 
					  withString:s];
	
	[s release];
}

-(void)dataRead:(NSNotification*)n
{
	NSData *d;
	d = [[n userInfo]valueForKey:NSFileHandleNotificationDataItem];
	
	NSLog(@"dataReady:%ld bytes",[d length]);
	
	if ([d length]) {
		[self appendData:d]	;
	}
	
	//if the task is runninng,start reading again
	if (task) {
		[[pipe fileHandleForReading]readInBackgroundAndNotify];
	}
}

-(void)taskTerminated:(NSNotification*)note
{
	NSLog(@"taskTerminated:");
	
	task = nil;
	
	[startButton setState:0];
	
	[startButton setTitle:@"Start Ping"];
	
	//log task termination status
	
	int status = [[note object]terminationStatus];
	
	/*
	if (status = ATASK_SUCCESSif (<#condition#>) {
			<#statements#>
		}ALUE) {
		NSLog(@"Task Succeded.");
		
	}
	else {
		NSLog(@"Task Failed with code:%d",status);
	}
	*/
	
	NSLog(@"Task code:%d",status);
//choschosenDirrg(@"%l",[[note object]terminationReason]);


}



-(IBAction)openZip:(id)sender
{
	[outputViewZip setString:@" "];
	NSOpenPanel *fileOpnPanel = [NSOpenPanel openPanel];
	
	//configuring
	
	[fileOpnPanel setCanChooseFiles:YES];
	[fileOpnPanel setCanChooseDirectories:NO];
	[fileOpnPanel setCanCreateDirectories:NO];
	[fileOpnPanel setResolvesAliases:YES];
	[fileOpnPanel setAllowsMultipleSelection:NO];	
	
	[fileOpnPanel beginWithCompletionHandler:^(NSInteger result) {
		NSURL* chosenDir = fileOpnPanel.URL;
		NSLog(@"adsdadsadasdasdad%@",chosenDir);
	}];
	 
	if([fileOpnPanel runModal] == NSOKButton)
	{
		NSString *selectedFileName = 
		[fileOpnPanel filename];
		
		NSLog(@"%@",selectedFileName);
		
		//check if the selected file is a .zip file
		NSString *fileExt = @"zip";
		NSURL *fileURL = [NSURL URLWithString:selectedFileName];
		
		NSLog(@"%@",[fileURL pathExtension]);
		
		//[fileURL pathExtension] == fileExt wont work for strings as 
		//thhe == operator only compares the pointer values of the two variables.
		
		if ([[fileURL pathExtension]isEqualToString:fileExt]) 
		{
			NSLog(@"%@",[fileURL pathExtension] );
		

		
		//[outputViewZip setString:selectedFileName];
		
		/*
		//using text storage
		NSTextStorage *ts = [outputViewZip textStorage];
		[ts replaceCharactersInRange:NSMakeRange([ts length],0) 
						  withString:selectedFileName];
		*/
		
		//Prepare the task
		nu_task = [[NSTask alloc]init];
		[nu_task setLaunchPath:@"/usr/bin/zipinfo"];
		NSArray *args = [NSArray arrayWithObjects:@"-1",selectedFileName,nil];
		[nu_task setArguments:args];
		
		//create pipe
		nu_pipe = [[NSPipe alloc]init];
		[nu_task setStandardOutput:nu_pipe];
		
		//start the process
		[nu_task launch];
		
		//Read the output
		NSData *data = [[nu_pipe fileHandleForReading]readDataToEndOfFile];
		
		//Make sure the task terminates normally
		[nu_task waitUntilExit];
		
		int status = [nu_task terminationStatus];
			
			if (status != 0) 
			{
				NSDictionary *eDict = [NSDictionary dictionaryWithObject:@"zipinfo failed" 
																  forKey:NSLocalizedFailureReasonErrorKey];
				NSError *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
											code:0
										userInfo:eDict];
				NSLog(@"%@",outError);
			}
		
		//Convert to a string
		NSString *aString = [[NSString alloc]initWithData:data
												 encoding:NSUTF8StringEncoding];
		
		//Break the string into lines
		//fileNames = [aString componentsSeparatedByString:@"\n"];
		NSLog(@"filenames =%@",aString);
		
		//using text storage
		NSTextStorage *ts = [outputViewZip textStorage];
		[ts replaceCharactersInRange:NSMakeRange([ts length],0) 
						  withString:aString];
		}
		else 
		{
			NSLog(@"Not a zip file");
			//sheet
			NSAlert *alertSheet = [NSAlert alertWithMessageText:@"Not a zip file" 
												  defaultButton:@"OK" 
												alternateButton:nil //@"Alternate" 
													otherButton:nil //@"Other" 
									  informativeTextWithFormat:[NSString stringWithFormat:
								   @"The selected file : \n%@\nis not a zip file",selectedFileName]];
			
			
			[alertSheet beginSheetModalForWindow:[sender window] //if displayed on button click
								   modalDelegate:self
								  didEndSelector:nil 
									 contextInfo:nil];
			
			//[fileOpnPanel cancel:sender];
			
		}
				
	}
	
	/*
	else if ([fileOpnPanel runModal] == NSCancelButton) 
		{
			NSLog(@"File Choose Operation Cancelled by User");
			[fileOpnPanel cancel:sender];
		}
	
*/
	
	}





-(void)dealloc
{
	[super dealloc];
	
	[task release];
	[pipe release];
	
	[nu_task release];
	[nu_pipe release];
	
	
	
	
	
}


@end
