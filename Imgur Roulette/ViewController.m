//
//  ViewController.m
//  Imgur Roulette
//
//  Created by Brian Michel on 8/19/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "ViewController.h"
#import "Imgur.h"
#import "ImgurImageView.h"
#import "NSString+Utilities.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#define kConsumerKey @"4015cca3d185c756e87c32a84b32dfef0503002b7"
#define kConsumerSecret @"46aeff30516e5596d1260db788f7821f"

@interface ViewController () <ImgurDelegate, ImgurImageViewDelegate, UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong) Imgur *imgur;
@property (strong) UIWebView *webView;
@property (strong) ImgurImageView *imgurView;
@property (strong) UIButton *refreshButton;
@property (strong) UIButton *cameraButton;
@end

@implementation ViewController

@synthesize imgur, webView, imgurView, refreshButton;

- (void)commonInit {
  self.imgurView = [[ImgurImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
  self.imgurView.delegate = self;
  [self.view addSubview:self.imgurView];
  self.view.backgroundColor = [UIColor underPageBackgroundColor];
  
  self.refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
  [self.refreshButton sizeToFit];
  [self.refreshButton addTarget:self action:@selector(refreshImage:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.refreshButton];
  
  self.cameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
  [self.cameraButton addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
  [self.cameraButton sizeToFit];
  [self.view addSubview:self.cameraButton];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.imgur = [[Imgur alloc] initWithDeveloperKey:@"e32d305b730a589d4b769c97944d9fb8"];
	// Do any additional setup after loading the view, typically from a nib.
  self.imgurView.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.cameraButton.frame = CGRectMake(round(self.view.frame.size.width/2 - self.cameraButton.frame.size.width/2), self.view.frame.size.height - self.cameraButton.frame.size.height, self.cameraButton.frame.size.width, self.cameraButton.frame.size.height);
}

- (void)refreshImage:(id)sender {
  [self.imgur fetchImageInformationForHashCode:[NSString randomStringOfLength:5] withCompletionHandler:^(NSError *error, NSDictionary *dictionary) {
    if (!error) {
      self.imgurView.imgurDictionary = dictionary;
    } else {
      NSLog(@"UPLOAD YOUR OWN! %@", error);
    }
  }];
}

- (void)imgurNeedsAuthorizationForURL:(NSURL *)url {
  [self.webView removeFromSuperview];
  self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.webView.scalesPageToFit = YES;
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  self.webView.delegate = self;
  [self.webView loadRequest:request];
  [self.view addSubview:self.webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if ([request.URL.scheme isEqualToString:@"imgur"]) {
    [self.imgur resumeAuthenticationFlowFromURL:request.URL];
    return NO;
  }
  return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Actions
- (void)openCamera:(id)sender {
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  picker.allowsEditing = YES;
  picker.delegate = self;
  [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [picker dismissViewControllerAnimated:YES completion:nil];
  [self.imgur uploadImageFromData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], 1.0) withParams:nil andCompletionHandler:^(NSError *postError, NSDictionary *successDictionary) {
   //GREAT SUCCESS!
    if (!postError) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Posted" message:[NSString stringWithFormat:@"Image was posted to %@", [successDictionary valueForKeyPath:@"upload.links.original"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    }
 }];
}

#pragma mark - Imgur Image View Delegate
- (void)imgurImageView:(ImgurImageView *)imageView shareOnAccountWithType:(NSString *)accountType {
  if ([accountType isEqualToString:ACAccountTypeIdentifierTwitter]) {
    TWTweetComposeViewController *twtcvc = [[TWTweetComposeViewController alloc] init];
    [twtcvc setInitialText:@"Found with Imgur Roulette"];
    [twtcvc addURL:[NSURL URLWithString:imageView.currentURL]];
    [self presentViewController:twtcvc animated:YES completion:nil];
  }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
