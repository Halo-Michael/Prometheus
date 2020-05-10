//
//  ViewController.m
//  respring
//
//  Created by dell on 2020/5/9.
//  Copyright © 2020 dell. All rights reserved.
//

#import "ViewController.h"
#import "NSTask.h"

void killall(const char *name) {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = [NSArray arrayWithObjects:
                      @"-Ac",
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

    NSMutableArray *listItems = [NSMutableArray array];
    NSString *string = @"";
    for (int i = 0; i < printString.length; i++) {
        if ([printString characterAtIndex:i] != ' ' && [printString characterAtIndex:i] != '\n') {
            string = [string stringByAppendingFormat:@"%c", [printString characterAtIndex:i]];
        } else if (![string isEqualToString:@""]) {
            [listItems addObject:string];
            string = @"";
        }
    }

    if ([listItems containsObject:[NSString stringWithFormat:@"%s", name]]) {
        kill([[listItems objectAtIndex:[listItems indexOfObject:[NSString stringWithFormat:@"%s", name]] - 3] intValue], SIGKILL);
    }
    exit(0);
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    killall("SpringBoard");
}


@end
