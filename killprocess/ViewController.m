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
- (IBAction)change:(id)sender;
- (IBAction)retuen:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = [NSArray arrayWithObjects:
                      @"-Aco",
                      @"user",
                      @"-o",
                      @"pid",
                      @"-o",
                      @"time",
                      @"-o",
                      @"command",
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
    _ps.text = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    _process.placeholder = @"process id";
}

- (IBAction)kill:(id)sender {
    switch (_choice.selectedSegmentIndex) {
        case 0:
        {
            if (kill([[_process text] intValue], SIGKILL) < 0) {
                UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                              message:[NSString stringWithFormat:@"You do not have permission to close process \"%@\" or it does not exist!", [_process text]]
                                              preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction * action) {}];
                [error addAction:defaultAction];
                [self presentViewController:error animated:YES completion:nil];
            }
        }
            break;
        case 1:
        {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/bin/ps";
            task.arguments = [NSArray arrayWithObjects:
                              @"-Aco",
                              @"pid",
                              @"-o",
                              @"command",
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
            //NSString *string = @"";
            int line = 1; //item = 0;
            NSString *lastpid = @"", *pid = @"", *name = @"";

            for (int i = 0; i < printString.length; i++) {
                while ([printString characterAtIndex:i] != '\n') {
                    while ([printString characterAtIndex:i] == ' ') {
                        i++;
                    }
                    while ([printString characterAtIndex:i] != ' ') {
                        pid = [pid stringByAppendingFormat:@"%c", [printString characterAtIndex:i]];
                        i++;
                    }
                    while ([printString characterAtIndex:i] == ' ') {
                        i++;
                    }
                    while ([printString characterAtIndex:i] != '\n') {
                        if ([printString characterAtIndex:i] != '(' && [printString characterAtIndex:i] != ')') {
                            name = [name stringByAppendingFormat:@"%c", [printString characterAtIndex:i]];
                        }
                        i++;
                    }
                    if (line > 1) {
                        if ([lastpid isEqualToString:@""]) {
                            [listItems addObject:@""];
                            [listItems addObject:name];
                            name = @"";
                        } else {
                            for (int j = [lastpid intValue] + 1; j < [pid intValue]; j++) {
                                [listItems addObject:@""];
                            }
                            [listItems addObject:name];
                            name = @"";
                        }
                        lastpid = pid;
                        pid = @"";
                    } else {
                        pid = @"";
                        name = @"";
                    }
                    line ++;
                }
            }

            if ([listItems containsObject:[_process text]]) {
                if (kill([[NSString stringWithFormat:@"%lu", [listItems indexOfObject:[_process text]]] intValue], SIGKILL) < 0) {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                                  message:[NSString stringWithFormat:@"You do not have permission to close process \"%@\"!", [_process text]]
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {}];
                    [error addAction:defaultAction];
                    [self presentViewController:error animated:YES completion:nil];
                }
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
            break;
    }
}

- (IBAction)change:(id)sender {
    switch (_choice.selectedSegmentIndex) {
        case 0:
            _process.placeholder = @"process id";
            break;
        case 1:
            _process.placeholder = @"process name";
            break;
    }
}

- (IBAction)retuen:(id)sender {
}

@end
