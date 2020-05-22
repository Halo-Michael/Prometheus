//
//  ViewController.h
//  respring
//
//  Created by dell on 2020/5/9.
//  Copyright © 2020 dell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewControl;
@property (weak, nonatomic) IBOutlet UIView *psview;
@property (weak, nonatomic) IBOutlet UIButton *kill;
@property (weak, nonatomic) IBOutlet UITextField *process;
@property (weak, nonatomic) IBOutlet UISegmentedControl *choice;
@property (weak, nonatomic) IBOutlet UITextView *ps;
@property (weak, nonatomic) IBOutlet UIButton *refresh;
@property (weak, nonatomic) IBOutlet UIView *nfview;
@property (weak, nonatomic) IBOutlet UITextField *bundleid;
@property (weak, nonatomic) IBOutlet UIButton *fix;
@property (weak, nonatomic) IBOutlet UIView *terminalView;
@property (weak, nonatomic) IBOutlet UITextView *terminalOutput;
@property (weak, nonatomic) IBOutlet UITextField *terminal;
@property (weak, nonatomic) IBOutlet UIButton *run;
@property (weak, nonatomic) IBOutlet UIButton *clear;

@end
