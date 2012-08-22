//
//  ImgurImageView.h
//  Imgur Roulette
//
//  Created by Brian Michel on 8/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImgurImageView;
@protocol ImgurImageViewDelegate <NSObject>

- (void)imgurImageViewRequestNewImage:(ImgurImageView *)imageView;
- (void)imgurImageView:(ImgurImageView *)imageView shareOnAccountWithType:(NSString *)accountType;

@end

@interface ImgurImageView : UIView

@property (strong) NSDictionary *imgurDictionary;
@property (weak) id<ImgurImageViewDelegate>delegate;

@property (strong, readonly) NSString *currentURL;
@end
