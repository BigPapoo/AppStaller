//
//  BPPAppDelegate.m
//  AppStaller
//
//  Created by Gildas Quiniou on 07/01/2014.
//  Copyright (c) 2014 Gildas Quiniou. All rights reserved.
//

#import "BPPAppDelegate.h"
#import "NSFileHandle+Readable.h"

#define BPP_WEB_PORT																					8000
#define BPP_PYTHON																					@"/usr/bin/python"
#define BPP_ZIP																						@"/usr/bin/zip"

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

	[self.txtUrl setStringValue:@"...wait..."];

	aString = [NSMutableString stringWithString:@"<html><head></head><body>\n"];

	path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];

	NSLog(@"Dir=%@", path);

	[[NSFileManager defaultManager] changeCurrentDirectoryPath:path];

	NSLog(@"WorkDir=%@", [[NSFileManager defaultManager] currentDirectoryPath]);

	// Create ipa from Payload
	for (NSString *aFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
	{
		NSTask	*aTask;

		if ([aFile isEqualToString:@"AppStaller.app"])
			continue;
		aRange = [aFile rangeOfString:@".*\\.app" options:NSRegularExpressionSearch];
		if (aRange.location != NSNotFound)
		{
			fileName = [aFile substringToIndex:aRange.length - 4];
			NSLog(@"Creating %@.ipa", fileName);
			NSLog(@"Remove directory %@", [path stringByAppendingString:@"/Payload"]);
			[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingString:@"/Payload"] error:NULL];
			NSLog(@"Create directory %@", [path stringByAppendingString:@"/Payload"]);
			[[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingString:@"/Payload"] withIntermediateDirectories:NO attributes:nil error:NULL];
			NSLog(@"Copy file %@ to directory %@", [NSString stringWithFormat:@"%@/%@", path, aFile], [NSString stringWithFormat:@"%@/Payload/%@", path, aFile]);
			[[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/%@", path, aFile] toPath:[NSString stringWithFormat:@"%@/Payload/%@", path, aFile] error:NULL];
			aTask = [[NSTask alloc] init];
			[aTask setLaunchPath:BPP_ZIP];
			[aTask setArguments:[NSArray arrayWithObjects:@"--exclude", @".DS_Store", @"-r", [fileName stringByAppendingString:@".ipa"], @"Payload", nil]];
			[aTask launch];
			[aTask waitUntilExit];
			NSLog(@"Remove directory %@", [path stringByAppendingString:@"/Payload"]);
			[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingString:@"/Payload"] error:NULL];
		}
	}

	for (NSString *aFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
	{
		aRange = [aFile rangeOfString:@".*\\.ipa" options:NSRegularExpressionSearch];
		if (aRange.location != NSNotFound)
		{
			NSLog(@"IPA: %@", aFile);
			fileName = [aFile substringToIndex:aRange.length - 4];
			[aString appendFormat:@"<a href=\"itms-services://?action=download-manifest&url=http://%@:%d/%@.plist\">%@</a><br />\n", anIp, BPP_WEB_PORT, fileName, fileName];
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
						[anObj setObject:[NSString stringWithFormat:@"http://%@:%d/%@.ipa", anIp, BPP_WEB_PORT, fileName] forKey:@"url"];
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
	[task setLaunchPath:BPP_PYTHON];
	[task setArguments:[NSArray arrayWithObjects:@"-m", @"SimpleHTTPServer", [NSString stringWithFormat:@"%d", BPP_WEB_PORT], nil]];

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

	[self.txtUrl setStringValue:[NSString stringWithFormat:@"http://%@:%d", anIp, BPP_WEB_PORT]];
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
