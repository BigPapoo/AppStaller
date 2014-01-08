//
//  BPPAppDelegate.m
//  AppStaller
//
//  Created by Gildas Quiniou on 07/01/2014.
//  Copyright (c) 2014 Gildas Quiniou. All rights reserved.
//

#import "BPPAppDelegate.h"
#import "NSFileHandle+Readable.h"

@interface BPPAppDelegate()
	@property (nonatomic, retain) NSFileHandle												*fdStdout;
	@property (nonatomic, retain) NSTask														*task;
@end

@implementation BPPAppDelegate

@synthesize txtUrl, fdStdout, task, btnGo;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self cleanup];
}

- (void)cleanup
{
	[self.task terminate];
	self.task = nil;
}


- (IBAction)go:(id)sender
{
	NSString					*anIp = nil;
	NSString					*fileName = nil;
	NSString					*path = nil;
	NSMutableString		*aString = nil;
	NSRange					aRange;
	NSMutableDictionary	*aDict = nil;

	[self.btnGo setEnabled:NO];
	for (anIp in [[NSHost currentHost] addresses])
	{
		NSLog(@"IP %@, OK?", anIp);
		if (![anIp isEqualToString:@"127.0.0.1"] &&
			([anIp rangeOfString:@"[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}" options:NSRegularExpressionSearch].location != NSNotFound))
		{
			NSLog(@"Selected IP: %@", anIp);
			break;
		}
	}

	[self.txtUrl setStringValue:[NSString stringWithFormat:@"http://%@:8000", anIp]];

	aString = [NSMutableString stringWithString:@"<html><head></head><body>\n"];

	path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];

	NSLog(@"Dir=%@", path);

	[[NSFileManager defaultManager] changeCurrentDirectoryPath:path];

	NSLog(@"WorkDir=%@", [[NSFileManager defaultManager] currentDirectoryPath]);

	for (NSString *aFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
	{
		aRange = [aFile rangeOfString:@".*\\.ipa" options:NSRegularExpressionSearch];
		if (aRange.location != NSNotFound)
		{
			NSLog(@"IPA: %@", aFile);
			fileName = [aFile substringToIndex:aRange.length - 4];
			[aString appendFormat:@"<a href=\"itms-services://?action=download-manifest&url=http://%@:8000/%@.plist\">%@</a><br />\n", anIp, fileName, fileName];
			aDict = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist", path, fileName]];
			if (aDict != nil)
			{
				if ([[aDict objectForKey:@"items"] isKindOfClass:[NSArray class]] &&
					([[aDict objectForKey:@"items"] count] > 0))
				{
					id 	anObj;

					anObj = [[aDict objectForKey:@"items"] objectAtIndex:0];
					if ([[anObj objectForKey:@"assets"] isKindOfClass:[NSArray class]] &&
						([[anObj objectForKey:@"assets"] count] > 0))
					{
						anObj = [[anObj objectForKey:@"assets"] objectAtIndex:0];
						[anObj setObject:[NSString stringWithFormat:@"http://%@:8000/%@.ipa", anIp, fileName] forKey:@"url"];
					}
					anObj = [[aDict objectForKey:@"items"] objectAtIndex:0];
					if ([[anObj objectForKey:@"metadata"] isKindOfClass:[NSDictionary class]])
					{
						anObj = [anObj objectForKey:@"metadata"];
						[anObj setObject:fileName forKey:@"title"];
					}
				}
			}
			[aDict writeToFile:[NSString stringWithFormat:@"%@/%@.plist", path, fileName] atomically:YES];
		}
	}
	[aString appendString:@"</body></html>\n"];

	[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/index.html", path]
								contents:[aString dataUsingEncoding:NSUTF8StringEncoding]
							attributes:nil];

	self.task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/bin/python"];
	[task setArguments:[NSArray arrayWithObjects:@"-m", @"SimpleHTTPServer", @"8000", nil]];

	NSPipe *outPipe;
	outPipe = [NSPipe pipe];
	[self.task setStandardOutput:outPipe];

	self.fdStdout = [outPipe fileHandleForReading];
	[self.fdStdout waitForDataInBackgroundAndNotify];
	[[NSNotificationCenter defaultCenter] addObserver:self
															selector:@selector(commandNotification:)
                                                 name:NSFileHandleDataAvailableNotification 
                                               object:nil];    

	[self.task launch];
}

- (void)commandNotification:(NSNotification *)notification
{
	NSData	*someData = nil;
	NSString	*aString = nil;

	while ([self.fdStdout isReadable])
	{
		someData = [self.fdStdout availableData];
		if ([someData length] <= 0)
			break;
		aString = [[[NSString alloc] initWithData:someData encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	 	NSLog(@"%@", aString);
	}
	[self.fdStdout waitForDataInBackgroundAndNotify];
}

@end
