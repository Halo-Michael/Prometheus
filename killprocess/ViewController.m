//
//  ViewController.m
//  respring
//
//  Created by dell on 2020/5/9.
//  Copyright © 2020 dell. All rights reserved.
//

#import "ViewController.h"
#import "NSTask.h"

bool do_check(const char *num) {
    if (strcmp(num, "0") == 0) {
        return true;
    }
    const char* p = num;
    if (*p < '1' || *p > '9') {
        return false;
    } else {
        p++;
    }
    while (*p) {
        if(*p < '0' || *p > '9') {
            return false;
        } else {
            p++;
        }
    }
    return true;
}

@interface ViewController ()

- (IBAction)kill:(id)sender;
- (IBAction)change:(id)sender;
- (IBAction)enter:(id)sender;
- (IBAction)refresh:(id)sender;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)kill:(id)sender {
    switch (_choice.selectedSegmentIndex) {
        case 0:
        {
            if (do_check([[_process text] UTF8String]) == true) {
                if (kill([[_process text] intValue], SIGKILL) < 0) {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                                  message:[NSString stringWithFormat:@"You do not have permission to close process \"%@\" or it does not exist!", [_process text]]
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {}];
                    [error addAction:defaultAction];
                    [self presentViewController:error animated:YES completion:nil];
                }
            } else {
                UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                              message:[NSString stringWithFormat:@"Wrong input:\"%@\", the pid of the process is only composed by numbers!", [_process text]]
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
            int line = 1;
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

            if (![[_process text] isEqualToString:@""] && [listItems containsObject:[_process text]]) {
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

- (IBAction)enter:(id)sender {
}

- (IBAction)refresh:(id)sender {
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
}

- (void)keyboardAction:(NSNotification*)sender {
    if([sender.name isEqualToString:UIKeyboardWillShowNotification]) {
        NSDictionary *useInfo = [sender userInfo];
        NSValue *value = [useInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        [_ps setContentOffset:CGPointMake([_ps contentOffset].x, [_ps contentOffset].y - [value CGRectValue].origin.y + 561)];
        _ps.frame = CGRectMake(16, 20, 343, [value CGRectValue].origin.y - 145);
        _choice.frame = CGRectMake(133, [value CGRectValue].origin.y - 117, 109, 32);
        _process.frame = CGRectMake(127, [value CGRectValue].origin.y - 78, 120, 34);
        _kill.frame = CGRectMake(172, [value CGRectValue].origin.y - 37, 30, 30);
        _refresh.frame = CGRectMake(275, [value CGRectValue].origin.y - 116, 53, 30);
    } else {
        [_ps setContentOffset:CGPointMake([_ps contentOffset].x, [_ps contentOffset].y + _ps.frame.size.height - 416)];
        _ps.frame = CGRectMake(16, 20, 343, 416);
        _choice.frame = CGRectMake(133, 444, 109, 32);
        _process.frame = CGRectMake(127, 483, 120, 34);
        _kill.frame = CGRectMake(172, 524, 30, 30);
        _refresh.frame = CGRectMake(275, 445, 53, 30);
    }
}

@end
