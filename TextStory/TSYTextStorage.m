//
//  TSYTextStorage.m
//  TextStory
//
//  Created by Matt Massicotte on 2020-01-02.
//  Copyright © 2020 Chime Systems Inc. All rights reserved.
//

#import "TSYTextStorage.h"

@implementation TSYTextStorage

- (instancetype)initWithStorage:(NSTextStorage *)textStorage {
    self = [super init];
    if (self) {
        _internalStorage = textStorage;
    }

    return self;
}

- (instancetype)init {
    return [self initWithString:@""];
}

// MARK: NSAttributedString
- (NSRange)doubleClickAtIndex:(NSUInteger)location {
    if ([self.storageDelegate respondsToSelector:@selector(textStorage:doubleClickRangeForLocation:)]) {
        return [self.storageDelegate textStorage:self doubleClickRangeForLocation:location];
    }

    return [super doubleClickAtIndex:location];
}

- (NSUInteger)nextWordFromIndex:(NSUInteger)location forward:(BOOL)isForward {
    if ([self.storageDelegate respondsToSelector:@selector(textStorage:nextWordIndexFromLocation:direction:)]) {
        return [self.storageDelegate textStorage:self nextWordIndexFromLocation:location direction:isForward];
    }

    return [super nextWordFromIndex:location forward:isForward];
}

// MARK: NSMutableAttributedString
- (instancetype)initWithString:(NSString *)str {
    NSTextStorage* storage = [[NSTextStorage alloc] initWithString:str];

    return [self initWithStorage:storage];
}

- (NSString *)string {
    return self.internalStorage.string;
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    if ([self.storageDelegate respondsToSelector:@selector(textStorage:willReplaceCharactersInRange:withString:)]) {
        [self.storageDelegate textStorage:self willReplaceCharactersInRange:range withString:str];
    }

    [self beginEditing];

    [self.internalStorage replaceCharactersInRange:range withString:str];

    if ([self.storageDelegate respondsToSelector:@selector(textStorage:didReplaceCharactersInRange:withString:)]) {
        [self.storageDelegate textStorage:self didReplaceCharactersInRange:range withString:str];
    }

    NSInteger delta = [str length] - range.length;

    [self edited:NSTextStorageEditedCharacters range:range changeInLength:delta];
    [self endEditing];
}

- (NSDictionary<NSAttributedStringKey, id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(nullable NSRangePointer)range {
    return [self.internalStorage attributesAtIndex:location effectiveRange:range];
}

- (void)setAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range {
    [self beginEditing];

    [self.internalStorage setAttributes:attrs range:range];

    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

// MARK: NSTextStorage
- (void)processEditing {
    [super processEditing];

    if ([self.storageDelegate respondsToSelector:@selector(textStorageProcessEditingComplete:)]) {
        [self.storageDelegate textStorageProcessEditingComplete:self];
    }
}

@end
