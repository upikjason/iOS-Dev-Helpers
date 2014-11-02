#import "Type1Font.h"

@implementation Type1Font

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if (self = [super initWithFontDictionary:dict])
	{
	}
	return self;
}

- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize
{
    if (self.fontDescriptor) {
        return [super widthOfCharacter:characher withFontSize:fontSize];
    }
    
    NSString *fontName;
    if ([self.baseFont hasPrefix:@"Helvetica"]) {
        fontName = @"Helvetica";
    }
    else if ([self.baseFont hasPrefix:@"Times"])
    {
        fontName = @"Times New Roman";
    }
    else if ([self.baseFont hasPrefix:@"Courier"]) {
        fontName = @"Courier New";
    }
    else if ([self.baseFont hasPrefix:@"Zapf"]) {
        fontName = @"Zapfino";
    }
    else {
        fontName = @"Helvetica";
    }
    CGFontRef fontRef = CGFontCreateWithFontName((CFStringRef)fontName);
    
    CGRect boxRect= CGFontGetFontBBox(fontRef);
    
    CGFontRelease(fontRef);
    return boxRect.size.width;
}

@end
