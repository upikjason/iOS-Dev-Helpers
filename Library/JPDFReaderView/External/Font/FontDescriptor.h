#import <Foundation/Foundation.h>
#import "FontFile.h"



/* Flags as defined in PDF 1.7 */
typedef enum FontFlags
{
	FontFixedPitch		= 1 << 0,
	FontSerif			= 1 << 1,
	FontSymbolic		= 1 << 2,
	FontScript			= 1 << 3,
	FontNonSymbolic		= 1 << 5,
	FontItalic			= 1 << 6,
	FontAllCap			= 1 << 16,
	FontSmallCap		= 1 << 17,
	FontForceBold		= 1 << 18,
} FontFlags;


@interface FontDescriptor : NSObject {
	CGFloat descent;
	CGFloat ascent;
	CGFloat leading;
	CGFloat capHeight;
	CGFloat xHeight;
	CGFloat averageWidth;
	CGFloat maxWidth;
	CGFloat missingWidth;
	CGFloat verticalStemWidth;
	CGFloat horizontalStemHeigth;
	CGFloat italicAngle;
	CGRect bounds;
	NSUInteger flags;
	NSString *fontName;
	FontFile *fontFile;
}

/* Initialize a descriptor using a FontDescriptor dictionary */
- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict;

// TODO: temporarily public
+ (void)parseFontFile:(NSData *)data;

@property (nonatomic) CGRect bounds;
@property (nonatomic) CGFloat ascent;
@property (nonatomic) CGFloat descent;
@property (nonatomic) CGFloat leading;
@property (nonatomic,) CGFloat capHeight;
@property (nonatomic) CGFloat xHeight;
@property (nonatomic) CGFloat averageWidth;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat missingWidth;
@property (nonatomic) CGFloat verticalStemWidth;
@property (nonatomic) CGFloat horizontalStemWidth;
@property (nonatomic) CGFloat italicAngle;
@property (nonatomic) NSUInteger flags;
@property (nonatomic, readonly, getter = isSymbolic) BOOL symbolic;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, readonly) FontFile *fontFile;
@end
