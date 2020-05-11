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

- (IBAction)kill:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)kill:(id)sender {
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
    int line = 1, item = 0;
    for (int i = 0; i < printString.length; i++) {
        if ([printString characterAtIndex:i] != ' ' || item == 4) {
            if ([string isEqualToString:@""]) {
                item ++;
            }
            if ([printString characterAtIndex:i] != '\n') {
                string = [string stringByAppendingFormat:@"%c", [printString characterAtIndex:i]];
            } else {
                if (line > 1) {
                    [listItems addObject:string];
                }
                item = 0;
                line ++;
                string = @"";
            }
        } else if (![string isEqualToString:@""]) {
            if (line > 1 && item == 1) {
                [listItems addObject:string];
            }
            string = @"";
        }
    }

    if ([listItems containsObject:[_process text]]) {
        kill([[listItems objectAtIndex:[listItems indexOfObject:[_process text]] - 1] intValue], SIGKILL);
    } else {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                      message:[NSString stringWithFormat:@"No process named \"%@\"!", [_process text]]
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
        [error addAction:defaultAction];
        [self presentViewController:error animated:YES completion:nil];
    }
}

@end
