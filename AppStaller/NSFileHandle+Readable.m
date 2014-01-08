//
//  NSFileHandle+Readable.m
//  AppStaller
//
//  Created by Gildas Quiniou on 07/01/2014.
//  Copyright (c) 2014 Gildas Quiniou. All rights reserved.
//

// http://pastebin.com/8QuxVGVj

#import <Foundation/Foundation.h>

@implementation NSFileHandle(Readable)

- (BOOL)isReadable
{
    int fd = [self fileDescriptor];
    fd_set fdset;
    struct timeval tmout = { 0, 0 }; // return immediately
    FD_ZERO(&fdset);
    FD_SET(fd, &fdset);
    if (select(fd + 1, &fdset, NULL, NULL, &tmout) <= 0)
        return NO;
    return FD_ISSET(fd, &fdset);
}

@end
