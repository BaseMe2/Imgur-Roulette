//
//  ImgurImageView.m
//  Imgur Roulette
//
//  Created by Brian Michel on 8/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "ImgurImageView.h"
#import "UIImageView+WebCache.h"
#import <Accounts/ACAccountType.h>
#import <QuartzCore/QuartzCore.h>

NSString * const kImgurImageKeypath = @"image.links.original";
const CGFloat kImgurImageViewHeightWidth = 280;

@interface ImgurImageView ()

@property (strong) UIImageView *imageView;
@property (strong) UIActivityIndicatorView *indicator;

@end

@implementation ImgurImageView

@synthesize imageView = _imageView;
@synthesize imgurDictionary = _imgurDictionary;
@synthesize indicator = _indicator;
@dynamic currentURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kImgurImageViewHeightWidth, kImgurImageViewHeightWidth)];
      self.imageView.contentMode = UIViewContentModeCenter;
      self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
      self.imageView.clipsToBounds = YES;
      [self addSubview:self.imageView];
      
      self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      self.indicator.alpha = 0.0;
      [self.indicator startAnimating];
      [self addSubview:self.indicator];
      
      self.layer.shadowColor = [UIColor blackColor].CGColor;
      self.layer.shadowOffset = CGSizeMake(0, 0);
      self.layer.shadowRadius = 8.0;
      self.layer.shadowOpacity = 0.8;
      self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.frame].CGPath;
      self.backgroundColor = [UIColor darkGrayColor];
      
      UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
      [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.indicator.frame = CGRectMake(round(self.frame.size.width/2 - self.indicator.frame.size.width/2), round(self.frame.size.height/2 - self.indicator.frame.size.height/2), self.indicator.frame.size.width, self.indicator.frame.size.height);
}

- (void)setImgurDictionary:(NSDictionary *)imgurDictionary {
  _imgurDictionary = imgurDictionary;
  
  [UIView animateWithDuration:0.3 animations:^{
    self.indicator.alpha = 1.0;
  }];
  
  [self.imageView setImageWithURL:[NSURL URLWithString:[imgurDictionary valueForKeyPath:kImgurImageKeypath]] success:^(UIImage *image) {
    NSLog(@"SUCCESS!");
    CGFloat newWidth = image.size.width < self.frame.size.width ? image.size.width : kImgurImageViewHeightWidth;
    CGFloat newHeight = image.size.height < self.frame.size.height ? image.size.height : kImgurImageViewHeightWidth;
    
    CGPoint oldCenter = self.center;
    [UIView animateWithDuration:0.3 animations:^{
      self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, newHeight);
      self.center = oldCenter;
      self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.frame].CGPath;
      self.indicator.alpha = 0.0;
    }];
  } failure:^(NSError *error) {
    NSLog(@"FAILURE");
    [UIView animateWithDuration:0.3 animations:^{
      self.indicator.alpha = 0.0;
    }];
  }];
}

- (NSDictionary *)imgurDictionary {
  return _imgurDictionary;
}

- (NSString *)currentURL {
  return [self.imgurDictionary valueForKeyPath:kImgurImageKeypath];
}

#pragma mark - Long Press
- (void)longPress:(UIGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateEnded) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imgurImageView:shareOnAccountWithType:)]) {
      [self.delegate imgurImageView:self shareOnAccountWithType:ACAccountTypeIdentifierTwitter];
    }
  }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
