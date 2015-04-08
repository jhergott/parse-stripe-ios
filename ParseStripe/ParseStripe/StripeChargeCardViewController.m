//
//  StripeChargeCardViewController.m
//  ParseStripe
//
//  Created by Jake Hergott on 4/8/15.
//  Copyright (c) 2015 Jake Hergott. All rights reserved.
//

#import "StripeChargeCardViewController.h"
#import <Parse/Parse.h>
#import "PTKView.h"
#import "STPCard.h"
#import "STPAPIClient.h"
#import "STPToken.h"

@interface StripeChargeCardViewController () <PTKViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property(weak, nonatomic) PTKView *paymentView;
@property STPToken *userToken;

@property (weak, nonatomic) IBOutlet UIButton *payButton;
- (IBAction)pay:(id)sender;

- (void)createOneTimeCharge:(STPToken *)token;

@property NSNumber *price;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerData;

@end

@implementation StripeChargeCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake((self.view.frame.size.width)/2.0 - 145,100,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
    
    self.payButton.layer.cornerRadius = 25;
    self.payButton.enabled = false;
    
    self.pickerData = @[@"5",@"10",@"15",@"20",@"25",@"30",@"35",@"40",@"45",@"50"];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.paymentView resignFirstResponder];
}

#pragma mark - PTKViewDelegate Method

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    self.payButton.enabled = valid;
    [self.paymentView resignFirstResponder];
}

#pragma mark - Make Payment

- (IBAction)pay:(id)sender {
    
    STPCard *creditCard = [[STPCard alloc] init];
    creditCard.number = self.paymentView.card.number;
    creditCard.expMonth = self.paymentView.card.expMonth;
    creditCard.expYear = self.paymentView.card.expYear;
    creditCard.cvc = self.paymentView.card.cvc;
    
    STPAPIClient *client = [[STPAPIClient alloc] initWithPublishableKey:@"pk_test_QkeQIbKScSBPWMR3UwKmBvcP"];
    
    [client createTokenWithCard:creditCard completion:^(STPToken *token, NSError *error) {
        if (error) {
            
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                message:error.localizedDescription
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [errorAlert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [errorAlert addAction:ok];
            [self presentViewController:errorAlert animated:YES completion:nil];
            
        } else {
            self.userToken = token;
            [self createOneTimeCharge:self.userToken];
        }
    }];
}

- (void)createOneTimeCharge:(STPToken *)token{
    
    [PFCloud callFunctionInBackground:@"ChargeWithCard"
                       withParameters:@{
                                        @"token" : token.tokenId,
                                        @"price" : self.price
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Result: %@",result);
                                    }else{
                                        NSLog(@"Error: %@",error);
                                    }
                                }];
}

#pragma mark - Picker View

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickerData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSInteger priceSelected = (1 + row) * 5;
    self.price = [NSNumber numberWithInteger:priceSelected];
    NSLog(@"%@",self.price);
}

@end
