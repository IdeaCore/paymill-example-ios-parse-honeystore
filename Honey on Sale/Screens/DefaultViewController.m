//
//  DefaultSettingsViewController.m
//  Honey on Sale
//
//  Created by Vladimir Marinov on 1/20/14.
//  Copyright (c) 2014 Vladimir Marinov. All rights reserved.
//

#import "DefaultViewController.h"

#import "StoreController.h"
#import <Parse/PFUser.h>
#import <Parse/Parse.h>

@interface DefaultViewController ()


@end

@implementation DefaultViewController

static NSString *ParseApplicationId = @"uii9EaqHnJ5fiez0hZOgc5KdIz5Fw9uIXIn24SMY";
static NSString *ParseClientKey = @"mMwscLfDnKDTvVlTUDsiUKp5llTlpJ1hy300F87r";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Init Parse
    [Parse setApplicationId:ParseApplicationId
                  clientKey:ParseClientKey];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten;
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    else{
        [self goToStore];
    }
}

- (void)goToStore{
    [self performSegueWithIdentifier:@"GoToStoreSeque" sender:self];
}
#pragma mark- PFSignUpViewControllerDelegate
- (void)dismisssSingUpController{
}
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user{
     [signUpController dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up successful"
                                                        message:@"Sign up successful, please use your credentials to login." delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}
#pragma mark- PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [logInController dismissViewControllerAnimated:YES completion:^{
       // [self goToStore];
    }];
    
}

#pragma mark-
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
