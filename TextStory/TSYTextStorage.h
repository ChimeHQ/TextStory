//
//  TSYTextStorage.h
//  TextStory
//
//  Created by Matt Massicotte on 2020-01-02.
//  Copyright © 2020 Chime Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <AppKit/NSTextStorage.h>
#else
#import <UIKit/NSTextStorage.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol TSYTextStorageDelegate;

@interface TSYTextStorage : NSTextStorage

- (instancetype)initWithStorage:(NSTextStorage *)textStorage NS_DESIGNATED_INITIALIZER;

@property (nullable, weak) id <TSYTextStorageDelegate> storageDelegate;

@property (nonatomic, readonly) NSTextStorage *internalStorage;

@end

@protocol TSYTextStorageDelegate <NSTextStorageDelegate>
@optional

- (void)textStorage:(TSYTextStorage *)textStorage willReplaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (void)textStorage:(TSYTextStorage *)textStorage didReplaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (void)textStorageProcessEditingComplete:(TSYTextStorage *)textStorage;

#if TARGET_OS_OSX
- (NSRange)textStorage:(TSYTextStorage *)textStorage doubleClickRangeForLocation:(NSUInteger)location;
- (NSUInteger)textStorage:(TSYTextStorage *)textStorage nextWordIndexFromLocation:(NSUInteger)location direction:(BOOL)forward;
#endif

@end

NS_ASSUME_NONNULL_END
