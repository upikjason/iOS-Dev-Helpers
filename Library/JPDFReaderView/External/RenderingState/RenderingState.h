#import <Foundation/Foundation.h>
#import "Font.h"

@interface RenderingState : NSObject <NSCopying> {
	CGAffineTransform lineMatrix;
	CGAffineTransform textMatrix;
	CGAffineTransform ctm;
	CGFloat leading;
	CGFloat wordSpacing;
	CGFloat characterSpacing;
	CGFloat horizontalScaling;
	CGFloat textRise;
	Font *font;
	CGFloat fontSize;
}

/* Set the text matrix and (optionally) the line matrix */
- (void)setTextMatrix:(CGAffineTransform)matrix replaceLineMatrix:(BOOL)replace;

/* Transform the text matrix */
- (void)translateTextPosition:(CGSize)size;

/* Move to start of next line, optionally with custom line height and indent, and optionally save line height */
- (void)newLineWithLeading:(CGFloat)aLeading indent:(CGFloat)indent save:(BOOL)save;
- (void)newLineWithLeading:(CGFloat)lineHeight save:(BOOL)save;
- (void)newLine;

/* Converts a size from text space to user space */
- (CGSize)convertSizeToUserSpace:(CGSize)aSize;

/* Converts a float to user space */
- (CGFloat)convertToUserSpace:(CGFloat)value;


/* Matrixes (line-, text- and global) */
@property (nonatomic) CGAffineTransform lineMatrix;
@property (nonatomic) CGAffineTransform textMatrix;
@property (nonatomic) CGAffineTransform ctm;

/* Text size, spacing, scaling etc. */
@property (nonatomic) CGFloat characterSpacing;
@property (nonatomic) CGFloat wordSpacing;
@property (nonatomic) CGFloat leadning;
@property (nonatomic) CGFloat textRise;
@property (nonatomic) CGFloat horizontalScaling;

/* Font and font size */
@property (nonatomic, strong) Font *font;
@property (nonatomic) CGFloat fontSize;

@end
