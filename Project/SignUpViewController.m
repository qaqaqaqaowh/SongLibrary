//
//  SignUpViewController.m
//  Project
//
//  Created by NEXTAcademy on 11/28/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignInViewController.h"
#import "Overlay.h"
@import FirebaseAuth;

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userText;

@property (weak, nonatomic) IBOutlet UITextField *passText;

@property (weak, nonatomic) IBOutlet UITextField *confirmText;

@property (weak, nonatomic) Overlay *overlay;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButton:(id)sender {
    [self.overlay setFrame:self.view.frame];
    [self.view addSubview:self.overlay];
    if (![self.userText.text isEqualToString:@""] && [self.passText.text isEqualToString:self.confirmText.text]) {
        [[FIRAuth auth] createUserWithEmail:self.userText.text password:self.passText.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                NSLog(error.localizedDescription);
            } else {
                SignInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
                vc.userText.text = user.email;
                [self.navigationController popViewControllerAnimated:true];
            }
        }];
    }
}

- (IBAction)signInButton:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
