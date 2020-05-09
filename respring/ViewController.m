//
//  ViewController.m
//  respring
//
//  Created by dell on 2020/5/9.
//  Copyright © 2020 dell. All rights reserved.
//

#import "ViewController.h"
#import "NSTask.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = [NSArray arrayWithObjects:
                      @"-A",
                      nil];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    NSFileHandle *file = [outputPipe fileHandleForReading];
    @try {
        [task launch];
    } @catch (NSException *exception) {
        exit(0);
    }
    NSData *data = [file readDataToEndOfFile];
    NSString *printString = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];

    NSString *string = @"";
    bool lastIsValue = false;
    for (int i = 0; i < printString.length; i++) {
        if ([printString characterAtIndex:i] != ' ' && [printString characterAtIndex:i] != '\n') {
            string = [string stringByAppendingFormat:@"%c", [printString characterAtIndex:i]];
            lastIsValue = true;
        } else if (lastIsValue == true) {
            string = [string stringByAppendingString:@" "];
            lastIsValue = false;
        }
    }

    NSArray *listItems = [string componentsSeparatedByString:@" "];

    int SpringBoardPid = [[listItems objectAtIndex:[listItems indexOfObject:@"/System/Library/CoreServices/SpringBoard.app/SpringBoard"] - 3] intValue];

    kill(SpringBoardPid, SIGKILL);
}


@end
