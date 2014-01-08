//
//  BPPAppDelegate.h
//  AppStaller
//
//  Created by Gildas Quiniou on 07/01/2014.
//  Copyright (c) 2014 Gildas Quiniou. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPPAppDelegate : NSObject <NSApplicationDelegate>
{
	NSTextField																							*txtUrl;
	NSFileHandle																						*fdStdout;
	NSTask																								*task;
	NSButton																								*btnGo;
}

@property (assign) IBOutlet NSWindow															*window;
@property (retain) IBOutlet NSTextField														*txtUrl;
@property (retain) IBOutlet NSButton															*btnGo;

- (IBAction)go:(id)sender;

@end
