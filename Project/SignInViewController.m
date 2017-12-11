//
//  SignInViewController.m
//  Project
//
//  Created by NEXTAcademy on 11/28/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "LibraryViewController.h"
#import "Overlay.h"
@import FirebaseAuth;

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@property (strong, nonatomic) Overlay *overlay;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] objectAtIndex:0];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButton:(id)sender {
    [self.overlay setFrame: self.view.frame];
    [[self view] addSubview:self.overlay];
    [[FIRAuth auth] signInWithEmail:self.userText.text password:self.passwordText.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            NSLog(error.localizedDescription);
        } else {
            LibraryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LibraryViewController"];
            self.navigationController.viewControllers = @[vc];
        }
    }];
}

- (IBAction)signUpButton:(id)sender {
    SignUpViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:vc animated:true];
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
