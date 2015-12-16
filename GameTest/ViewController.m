//
//  ViewController.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "ViewController.h"
#import <MaxLeap/MaxLeap.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statuslabel;
@property (weak, nonatomic) IBOutlet UIButton *becomeNormalButton;
- (IBAction)becomeNormal:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([MLUser currentUser]) {
        if ([MLAnonymousUtils isLinkedWithUser:[MLUser currentUser]]) {
            self.becomeNormalButton.enabled = YES;
            self.becomeNormalButton.backgroundColor = [UIColor blueColor];
            self.statuslabel.text = @"用户状态：匿名";
        } else {
            self.becomeNormalButton.enabled = NO;
            self.becomeNormalButton.backgroundColor = [UIColor lightGrayColor];
            self.statuslabel.text = @"用户状态：普通";
        }
    } else {
        [self presentLoginViewControllerAnimated:NO];
    }
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    NSString *segueId = @"showLoginViewWithoutAnimation";
    if (animated) {
        segueId = @"showLoginView";
    }
    [self performSegueWithIdentifier:segueId sender:nil];
}

- (IBAction)logout:(id)sender {
    [MLUser logOut];
    [self presentLoginViewControllerAnimated:YES];
}

- (IBAction)becomeNormal:(id)sender {
    [self presentLoginViewControllerAnimated:YES];
}
@end
