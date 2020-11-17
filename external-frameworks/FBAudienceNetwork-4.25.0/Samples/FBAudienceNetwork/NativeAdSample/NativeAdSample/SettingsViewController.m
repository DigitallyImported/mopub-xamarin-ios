// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIStepper *debugLevelStepper;
@property (weak, nonatomic) IBOutlet UILabel *debugLevelLabel;
@property (weak, nonatomic) IBOutlet UITextField *sandboxTextField;
@property (weak, nonatomic) IBOutlet UISwitch *testModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *demoAdName;
@property (weak, nonatomic) IBOutlet UIPickerView *demoAdPicker;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.sandboxTextField.delegate = self;

  UIImage *whiteImage = [self imageWithSolidColor:[UIColor whiteColor]];
  UIImage *greyImage = [self imageWithSolidColor:[UIColor lightGrayColor]];
  [self.debugLevelStepper setBackgroundImage:whiteImage forState:UIControlStateNormal];
  [self.debugLevelStepper setBackgroundImage:greyImage forState:UIControlStateHighlighted];
  [self.debugLevelStepper setBackgroundImage:whiteImage forState:UIControlStateDisabled];
  [self.testModeSwitch setOn:[FBAdSettings isTestMode] animated:NO];
  self.sdkVersionLabel.text = FB_AD_SDK_VERSION;
  self.demoAdPicker.delegate = self;
  self.demoAdPicker.dataSource = self;
  self.demoAdName.text = [SettingsViewController demoAdDisplayName:FBAdSettings.testAdType];
  [self.demoAdPicker selectRow:FBAdSettings.testAdType inComponent:0 animated:NO];
}


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  self.sandboxTextField.text = [FBAdSettings urlPrefix];
  self.debugLevelLabel.text = [self logLevelToString:[FBAdSettings getLogLevel]];
  self.debugLevelStepper.value = [FBAdSettings getLogLevel];
}

- (UIImage *)imageWithSolidColor:(UIColor *)color {
  CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (IBAction)debugLevelStepperDidChange:(UIStepper *)sender
{
  if (sender == self.debugLevelStepper) {
    [FBAdSettings setLogLevel:sender.value];
    self.debugLevelLabel.text = [self logLevelToString:[FBAdSettings getLogLevel]];
  }
}

- (IBAction)testModeStateChanged:(id)sender {
  UISwitch *testModeSwitch = (UISwitch *)sender;

  if (testModeSwitch.on) {
    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
  } else {
    [FBAdSettings clearTestDevice:[FBAdSettings testDeviceHash]];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.sandboxTextField) {
    [FBAdSettings setUrlPrefix:textField.text];
  }

  [textField resignFirstResponder];

  return YES;
}

- (NSString *)logLevelToString:(FBAdLogLevel)logLevel
{
  NSString *logLevelString = nil;
  switch (logLevel) {
    case FBAdLogLevelNone:
      logLevelString = @"None";
      break;
    case FBAdLogLevelNotification:
      logLevelString = @"Notification";
      break;
    case FBAdLogLevelError:
      logLevelString = @"Error";
      break;
    case FBAdLogLevelWarning:
      logLevelString = @"Warning";
      break;
    case FBAdLogLevelLog:
      logLevelString = @"Log";
      break;
    case FBAdLogLevelDebug:
      logLevelString = @"Debug";
      break;
    case FBAdLogLevelVerbose:
      logLevelString = @"Verbose";
      break;
    default:
      logLevelString = @"Unknown";
      break;
  }

  return logLevelString;
}

- (IBAction)donePresssed:(UIButton *)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

+ (NSDictionary *)demoAdDictionary {
  return @{
     @(FBAdTestAdType_Default) : @"default",
     @(FBAdTestAdType_Img_16_9_App_Install) : @"image_install",
     @(FBAdTestAdType_Img_16_9_Link) : @"image_link",
     @(FBAdTestAdType_Vid_HD_16_9_46s_App_Install) : @"video_16x9_46s_install",
     @(FBAdTestAdType_Vid_HD_16_9_46s_Link) : @"video_16x9_46s_link",
     @(FBAdTestAdType_Vid_HD_16_9_15s_App_Install) : @"video_16x9_15s_install",
     @(FBAdTestAdType_Vid_HD_16_9_15s_Link) : @"video_16x9_15s_link",
     @(FBAdTestAdType_Vid_HD_9_16_39s_App_Install) : @"video_9x16_39s_install",
     @(FBAdTestAdType_Vid_HD_9_16_39s_Link) : @"video_9x16_39s_link",
     @(FBAdTestAdType_Carousel_Img_Square_App_Install) : @"carousel_install",
     @(FBAdTestAdType_Carousel_Img_Square_Link) : @"carousel_link"
  };
}

+ (NSString *)demoAdDisplayName:(FBAdTestAdType)demoAD {
  return [SettingsViewController demoAdDictionary][@(demoAD)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {

  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {

  return [SettingsViewController demoAdDictionary].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  NSString * title = [SettingsViewController demoAdDisplayName: row];
  if (!title) {
    title = @"none";
  }
  return title;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

  self.demoAdName.text = [SettingsViewController demoAdDisplayName: row];
  if (!self.demoAdName.text) {
    self.demoAdName.text = @"none";
  }
  FBAdSettings.testAdType = row;
}

@end
