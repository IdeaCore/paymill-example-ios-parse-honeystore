//
//  CheckOutViewController.m
//  Honey on Sale
//
//  Created by Vladimir Marinov on 14.01.14.
//  Copyright (c) 2014 г. Vladimir Marinov. All rights reserved.
//

#import "PaymentViewController.h"
#import "MBProgressHUD.h"
#import "StoreController.h"
#import "CardIOPaymentViewController.h"
#import "CardIOCreditCardInfo.h"
#import <PayMillSDK/PMClient.h>
#import <Parse/PFUser.h>
#import <Parse/PFCloud.h>
#import <PayMillSDK/PMFactory.h>
#import <PayMillSDK/PMManager.h>

@interface PaymentViewController ()

@property (nonatomic, weak) IBOutlet UITextField *existingClient;
@property (nonatomic, strong) UIPickerView *paymentsPicker;
@property (nonatomic, weak) IBOutlet UITextField *accHolder;
@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UILabel *cardNumber;
@property (nonatomic, weak) IBOutlet UILabel *cardVerification;
@property (nonatomic, weak) IBOutlet UILabel *cardExpire;
@property (nonatomic, weak) IBOutlet UILabel *total;
@property (nonatomic, strong) NSString *cardExpireMonth;
@property (nonatomic, strong) NSString *cardExpireYear;
@property (nonatomic, strong) NSString *existingPaymentId;
@end

#define CARDIO_TOKEN @"2bcc1401544a4e24b6036b4fda84000f"

@implementation PaymentViewController


- (IBAction)chooseExistingClient:(id)sender {
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
     UIBarButtonItem *checkoutButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                        target:self action:@selector(payNow:)];
    self.navigationItem.rightBarButtonItem = checkoutButton;
    self.paymentsPicker = [[UIPickerView alloc] init];
    self.paymentsPicker.dataSource = self;
    self.paymentsPicker.delegate = self;
    self.paymentsPicker.showsSelectionIndicator = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:self action:@selector(selectDidFinish:)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems: [NSArray arrayWithObject:doneButton]];
    
    [self.paymentsPicker selectedRowInComponent:0];
    [self.existingClient setInputView:self.paymentsPicker];
    self.existingClient.inputAccessoryView = toolbar;
    self.existingClient.delegate = self;
    self.accHolder.text = [PFUser currentUser].username;
    self.email.text = [PFUser currentUser].email;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[MBProgressHUD showHUDAddedTo:self.view animated:NO];
	[[StoreController getInstance] getPaymentsWithComplte:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.paymentsPicker reloadAllComponents];
    }];
    self.total.text = [NSString stringWithFormat:@"Total: %d.%d", [[StoreController getInstance] getTotal]/ 100,
                       [[StoreController getInstance] getTotal] %100 ];
	
}

- (void)selectDidFinish:(id)sender {
    [self.existingClient resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark- UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[StoreController getInstance].Payments count] + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(row == 0){
        return @"Select Card";
    }
    PMPayment *payment = [[StoreController getInstance].Payments objectAtIndex:row-1];
    return payment.last4;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    PMPayment *payment = [[StoreController getInstance].Payments objectAtIndex:row-1];
    self.cardNumber.text = payment.last4;
    self.cardVerification.text = payment.code;
    self.cardExpire.text = [NSString stringWithFormat:@"Exp: %@/%@", payment.expire_month, payment.expire_year];
    self.cardExpireMonth = payment.expire_month;
    self.cardExpireYear = payment.expire_year;
    self.existingPaymentId = payment.id;
   [self.existingClient resignFirstResponder];
    
}
#pragma mark- CardIO
/// This method will be called if the user cancels the scan. You MUST dismiss paymentViewController.
/// @param paymentViewController The active CardIOPaymentViewController.
- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController{
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

/// This method will be called when there is a successful scan (or manual entry). You MUST dismiss paymentViewController.
/// @param cardInfo The results of the scan.
/// @param paymentViewController The active CardIOPaymentViewController.
- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController{
    
    self.cardNumber.text = [NSString stringWithFormat:@"N: %@",cardInfo.cardNumber];
    self.cardVerification.text = [NSString stringWithFormat:@"CCV: %@", cardInfo.cvv];
    self.cardExpire.text = [NSString stringWithFormat:@"Exp: %d/%d", cardInfo.expiryMonth, cardInfo.expiryYear];
    self.cardExpireMonth = [NSString stringWithFormat:@"%d", cardInfo.expiryMonth];
    self.cardExpireYear = [NSString stringWithFormat:@"%d", cardInfo.expiryYear];
    self.existingPaymentId = nil;
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark-
- (void)createTransactionWithToken:(NSString*)token amount:(NSString*)amount currency:(NSString*)currency descrition:(NSString*)descrition{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:amount forKey:@"amount"];
    [parameters setObject:currency forKey:@"currency"];
    [parameters setObject:descrition forKey:@"descrition"];
    
    [PFCloud callFunctionInBackground:@"createTransactionWithToken" withParameters:parameters
                                block:^(id object, NSError *error) {
                                    
                                    if(error == nil){
                                        [[StoreController getInstance] clearCart];
                                        NSString *msg = @"Payment has been successfull.";
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                        message:msg delegate:nil
                                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                    }
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                } ];

}
- (void)createTransactionWithPayment:(NSString*)paymentId amount:(NSString*)amount currency:(NSString*)currency descrition:(NSString*)descrition{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:paymentId forKey:@"paymillPaymentId"];
    [parameters setObject:amount forKey:@"amount"];
    [parameters setObject:currency forKey:@"currency"];
    [parameters setObject:descrition forKey:@"descrition"];
    
    [PFCloud callFunctionInBackground:@"createTransactionWithPayment" withParameters:parameters
                                block:^(id object, NSError *error) {
                                    
                                    if(error == nil){
                                        [[StoreController getInstance] clearCart];
                                        NSString *msg = @"Payment has been successfull.";
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                        message:msg delegate:nil
                                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                        
                                    }
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                } ];
    
}
- (void)payNow:(UIButton*)sender{
    NSString *amount = [NSString stringWithFormat:@"%d", [[StoreController getInstance] getTotal]];
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    if(self.existingPaymentId != nil){
        [self createTransactionWithPayment:self.existingPaymentId amount:amount currency:@"EUR" descrition:@"Descrition"];
    }
    else
    {
        PMError *error;
        PMPaymentParams *params;
        // 1. generate paymill payment method
        NSLog(@"%@ %@ %@ %@ %@ ", self.accHolder.text, self.cardNumber.text, self.cardExpireMonth, self.cardExpireYear, self.cardVerification.text);
        id paymentMethod = [PMFactory genCardPaymentWithAccHolder:self.accHolder.text
                                                       cardNumber:@"5500000000000004"//self.cardNumber.text
                                                      expiryMonth:self.cardExpireMonth
                                                       expiryYear:self.cardExpireYear
                                                     verification:self.cardVerification.text
                                                            error:&error];
        if(!error) {
            // 2. generate params
            params = [PMFactory genPaymentParamsWithCurrency:@"EUR" amount:150 //[[StoreController getInstance] getTotal]
                                                 description:@"3DS Test" error:&error];
        }
        
        if(!error) {
            // 3. generate token
            [PMManager generateTokenWithMethod:paymentMethod parameters:params success:^(NSString *token) {
                //token successfully created
                [self createTransactionWithToken:token amount:amount currency:@"EUR" descrition:@"Descrition"];
            }
                                       failure:^(PMError *error) {
                                           //token generation failed
                                           NSLog(@"Generate Token Error %@", error.message);
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       }];  
        }
        else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"GenCardPayment Error %@", error.message);
        }
        
    }

}
- (IBAction)scanCard:(id)sender {
	CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
	scanViewController.appToken = CARDIO_TOKEN;
	[self presentViewController:scanViewController animated:YES completion:nil];
	
}

@end