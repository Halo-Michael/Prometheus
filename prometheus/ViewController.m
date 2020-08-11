//
//  ViewController.m
//  respring
//
//  Created by dell on 2020/5/9.
//  Copyright © 2020 dell. All rights reserved.
//

#import "ViewController.h"
#import "NSTask.h"
#import <objc/message.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_11_0
#   define kCFCoreFoundationVersionNumber_iOS_11_0 1443.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_12_0
#   define kCFCoreFoundationVersionNumber_iOS_12_0 1535.12
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#   define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

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

- (IBAction)changeView:(id)sender;
- (IBAction)kill:(id)sender;
- (IBAction)kpChangeEnter:(id)sender;
- (IBAction)kpReturn:(id)sender;
- (IBAction)change:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)nfChangedEnter:(id)sender;
- (IBAction)nfReturn:(id)sender;
- (IBAction)fix:(id)sender;
- (IBAction)terminalReturn:(id)sender;
- (IBAction)terminalChangeEnter:(id)sender;
- (IBAction)runCommands:(id)sender;
- (IBAction)clearCommands:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = [NSArray arrayWithObjects:@"-Aco user pid time command", nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)changeView:(id)sender {
    switch (_viewControl.selectedSegmentIndex) {
        case 0:
            _nfview.hidden = true;
            _terminalView.hidden = true;
            _psview.hidden = false;
            break;
        case 1:
            _psview.hidden = true;
            _terminalView.hidden = true;
            _nfview.hidden = false;
            break;
        case 2:
            _psview.hidden = true;
            _nfview.hidden = true;
            _terminalView.hidden = false;
            break;
    }
}

- (IBAction)kill:(id)sender {
    switch (_choice.selectedSegmentIndex) {
        case 0:
            {
                if (do_check([[_process text] UTF8String]) == true) {
                    if (kill([[_process text] intValue], SIGKILL) < 0) {
                        UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"You do not have permission to close process \"%@\" or it does not exist!", [_process text]] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                        [error addAction:defaultAction];
                        [self presentViewController:error animated:YES completion:nil];
                    }
                } else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"Wrong input:\"%@\", the pid of the process is only composed by numbers!", [_process text]] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                    [error addAction:defaultAction];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }
            break;
        case 1:
            {
                NSTask *task = [[NSTask alloc] init];
                task.launchPath = @"/bin/ps";
                task.arguments = [NSArray arrayWithObjects:@"-Aco pid command", nil];
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

                NSMutableDictionary *ps = [NSMutableDictionary dictionary];
                for (int i = 0; i < [printString length]; i++) {
                    while ([printString characterAtIndex:i] != '\n') {
                        NSMutableString *name = [[NSMutableString alloc] init];
                        NSMutableString *pid = [[NSMutableString alloc] init];
                        while ([printString characterAtIndex:i] == ' ') {
                            i++;
                        }
                        while ([printString characterAtIndex:i] != ' ') {
                            [pid appendFormat:@"%c", [printString characterAtIndex:i]];
                            i++;
                        }
                        while ([printString characterAtIndex:i] == ' ') {
                            i++;
                        }
                        while ([printString characterAtIndex:i] != '\n') {
                            if ([printString characterAtIndex:i] != '(' && [printString characterAtIndex:i] != ')') {
                                [name appendFormat:@"%c", [printString characterAtIndex:i]];
                            }
                            i++;
                        }
                        if (do_check([pid UTF8String])) {
                            NSMutableArray *pids = [NSMutableArray array];
                            if (ps[name] != nil) {
                                pids = ps[name];
                            }
                            [pids addObject:pid];
                            ps[name] = pids;
                        }
                    }
                }

                if (![[_process text] isEqualToString:@""] && ps[[_process text]] != nil) {
                    for (NSString *pid in ps[[_process text]]) {
                        if (kill([pid intValue], SIGKILL) < 0) {
                            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"You do not have permission to close process \"%@\"!", [_process text]] preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                            [error addAction:defaultAction];
                            [self presentViewController:error animated:YES completion:nil];
                        }
                    }
                } else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"No process named \"%@\"!", [_process text]] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                    [error addAction:defaultAction];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }
            break;
    }
}

- (IBAction)kpChangeEnter:(id)sender {
    if (![[_process text] isEqualToString:@""]) {
           _kill.userInteractionEnabled = true;
    } else {
           _kill.userInteractionEnabled = false;
    }
}

- (IBAction)kpReturn:(id)sender {
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

- (IBAction)refresh:(id)sender {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = [NSArray arrayWithObjects:@"-Aco user pid time command", nil];
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

- (IBAction)nfChangedEnter:(id)sender {
    if (![[_bundleid text] isEqualToString:@""]) {
           _fix.userInteractionEnabled = true;
    } else {
           _fix.userInteractionEnabled = false;
    }
}

- (IBAction)nfReturn:(id)sender {
}

- (IBAction)fix:(id)sender {
    NSBundle *bundle;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SettingsCellular.framework"];
    } else if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Preferences.framework"];
    }

    if (![bundle load]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"iOS version too low, 11.0 or higher required!"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [error addAction:defaultAction];
        [self presentViewController:error animated:YES completion:nil];
        return;
    }
    NSArray *bundleIds = [[_bundleid text] componentsSeparatedByString:@" "];
    for (NSString *exampleBundleid in bundleIds) {
        UIAlertController *message;
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_12_0) {
            Class PSAppDataUsagePolicyCacheClass = NSClassFromString(@"PSAppDataUsagePolicyCache");
            id cacheInstance = [PSAppDataUsagePolicyCacheClass valueForKey:@"sharedInstance"];

            BOOL result = ((BOOL (*)(id, SEL, NSString *, BOOL, BOOL))objc_msgSend)(cacheInstance, NSSelectorFromString(@"setUsagePoliciesForBundle:cellular:wifi:"), exampleBundleid, true, true);
            if (!result) {
                message = [UIAlertController alertControllerWithTitle:@"Failed!" message:[NSString stringWithFormat:@"Fail to enable network for %s.", [exampleBundleid UTF8String]] preferredStyle:UIAlertControllerStyleAlert];
            } else {
                message = [UIAlertController alertControllerWithTitle:@"Success!" message:[NSString stringWithFormat:@"Enable network for %s successfully.", [exampleBundleid UTF8String]] preferredStyle:UIAlertControllerStyleAlert];
            }
        } else {
            Class AppWirelessDataUsageManager = NSClassFromString(@"AppWirelessDataUsageManager");
            BOOL result = ((BOOL (*)(Class, SEL, NSNumber *, NSString *, id))objc_msgSend)(AppWirelessDataUsageManager, NSSelectorFromString(@"setAppWirelessDataOption:forBundleIdentifier:completionHandler:"), [NSNumber numberWithInt:3], exampleBundleid, nil);
            if (!result) {
                message = [UIAlertController alertControllerWithTitle:@"Failed!" message:[NSString stringWithFormat:@"Fail to enable network for %s.", [exampleBundleid UTF8String]] preferredStyle:UIAlertControllerStyleAlert];
                continue;
            }
            result = ((BOOL (*)(Class, SEL, NSNumber *, NSString *, id))objc_msgSend)(AppWirelessDataUsageManager, NSSelectorFromString(@"setAppCellularDataEnabled:forBundleIdentifier:completionHandler:"), [NSNumber numberWithInt:1], exampleBundleid, nil);
            if (!result) {
                message = [UIAlertController alertControllerWithTitle:@"Failed!" message:[NSString stringWithFormat:@"Fail to enable network for %s.", [exampleBundleid UTF8String]] preferredStyle:UIAlertControllerStyleAlert];
            } else {
                message = [UIAlertController alertControllerWithTitle:@"Success!" message:[NSString stringWithFormat:@"Enable network for %s successfully.", [exampleBundleid UTF8String]] preferredStyle:UIAlertControllerStyleAlert];
            }
        }
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [message addAction:defaultAction];
        [self presentViewController:message animated:YES completion:nil];
    }
}

- (IBAction)terminalReturn:(id)sender {
}

- (IBAction)terminalChangeEnter:(id)sender {
    if (![[_terminal text] isEqualToString:@""]) {
           _run.userInteractionEnabled = true;
    } else {
           _run.userInteractionEnabled = false;
    }
}

- (IBAction)runCommands:(id)sender {
    if (![[_terminal text] isEqualToString:@""]) {
        NSString *launchPath = @"";
        NSString *arguments = @"";
        int i = 0;
        while (i < [_terminal text].length && [[_terminal text] characterAtIndex:i] != ' ') {
            launchPath = [launchPath stringByAppendingFormat:@"%c", [[_terminal text] characterAtIndex:i]];
            i++;
        }
        while (i < [_terminal text].length && [[_terminal text] characterAtIndex:i] == ' ') {
            i++;
        }
        while (i < [_terminal text].length) {
            arguments = [arguments stringByAppendingFormat:@"%c", [[_terminal text] characterAtIndex:i]];
            i++;
        }

        NSTask *task = [[NSTask alloc] init];
        task.launchPath = launchPath;
        if (![arguments isEqualToString:@""]) {
            task.arguments = [NSArray arrayWithObjects:arguments, nil];
        }
        NSPipe *outputPipe = [NSPipe pipe];
        [task setStandardOutput:outputPipe];
        NSFileHandle *file = [outputPipe fileHandleForReading];
        @try {
            [task launch];
        } @catch (NSException *exception) {
            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"Command \"%@\" not found, missing path or binary does not exist.", launchPath] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [error addAction:defaultAction];
            [self presentViewController:error animated:YES completion:nil];
            return;
        }
        NSData *data = [file readDataToEndOfFile];
        _terminalOutput.text = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    }
}

- (IBAction)clearCommands:(id)sender {
    _terminalOutput.text = @"";
}

- (void)keyboardAction:(NSNotification*)sender {
    if([sender.name isEqualToString:UIKeyboardWillShowNotification]) {
        NSDictionary *useInfo = [sender userInfo];
        NSValue *value = [useInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        [_ps setContentOffset:CGPointMake([_ps contentOffset].x, [_ps contentOffset].y - [value CGRectValue].origin.y + 599)];
        _ps.frame = CGRectMake(16, 0, 343, [value CGRectValue].origin.y - 183);
        _choice.frame = CGRectMake(133, [value CGRectValue].origin.y - 175, 109, 32);
        _process.frame = CGRectMake(127, [value CGRectValue].origin.y - 136, 120, 34);
        _kill.frame = CGRectMake(172, [value CGRectValue].origin.y - 95, 30, 30);
        _refresh.frame = CGRectMake(275, [value CGRectValue].origin.y - 174, 53, 30);
        _bundleid.frame = CGRectMake(127, [value CGRectValue].origin.y - 242, 120, 34);
        _fix.frame = CGRectMake(172, [value CGRectValue].origin.y - 200, 30, 30);
        [_terminalOutput setContentOffset:CGPointMake([_terminalOutput contentOffset].x, [_terminalOutput contentOffset].y - [value CGRectValue].origin.y + 561)];
        _terminalOutput.frame = CGRectMake(16, 0, 343, [value CGRectValue].origin.y - 145);
        _terminal.frame = CGRectMake(37, [value CGRectValue].origin.y - 137, 300, 34);
        _run.frame = CGRectMake(172, [value CGRectValue].origin.y - 95, 30, 30);
        _clear.frame = CGRectMake(284, [value CGRectValue].origin.y - 95, 36, 30);
    } else {
        [_ps setContentOffset:CGPointMake([_ps contentOffset].x, [_ps contentOffset].y + _ps.frame.size.height - 416)];
        _ps.frame = CGRectMake(16, 0, 343, 416);
        _choice.frame = CGRectMake(133, 424, 109, 32);
        _process.frame = CGRectMake(127, 463, 120, 34);
        _kill.frame = CGRectMake(172, 504, 30, 30);
        _refresh.frame = CGRectMake(275, 425, 53, 30);
        _bundleid.frame = CGRectMake(127, 287, 120, 34);
        _fix.frame = CGRectMake(172, 329, 30, 30);
        [_terminalOutput setContentOffset:CGPointMake([_terminalOutput contentOffset].x, [_terminalOutput contentOffset].y + _terminalOutput.frame.size.height - 416)];
        _terminalOutput.frame = CGRectMake(16, 0, 343, 416);
        _terminal.frame = CGRectMake(37, 422, 300, 34);
        _run.frame = CGRectMake(172, 464, 30, 30);
        _clear.frame = CGRectMake(284, 464, 36, 30);
    }
}

@end
