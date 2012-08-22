//
//  NSString+Utilities.m
//  Imgur Roulette
//
//  Created by Brian Michel on 8/21/12.
//  Copyright (c) 2012 Foureyes. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+ (NSString *)randomStringOfLength:(NSUInteger)length {
  NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
  NSMutableString *s = [NSMutableString stringWithCapacity:length];
  for (NSUInteger i = 0U; i < length; i++) {
    u_int32_t r = arc4random() % [alphabet length];
    unichar c = [alphabet characterAtIndex:r];
    [s appendFormat:@"%C", c];
  }
  return s;
}

@end
