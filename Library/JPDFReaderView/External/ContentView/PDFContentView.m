#import "PDFContentView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PDFContentView
@synthesize keyword, selections, scanner;

#pragma mark - Initialization

//- (id)initWithFrame:(CGRect)frame
//{
//    if ((self = [super initWithFrame:frame]))
//    {
//        self.backgroundColor = [UIColor whiteColor];
//		
//		CATiledLayer *tiledLayer = (CATiledLayer *) [self layer];
//		tiledLayer.frame = CGRectMake(0, 0, 512, 512);
//		[tiledLayer setTileSize:CGSizeMake(1024, 1024)];
//		[tiledLayer setLevelsOfDetail:5];
//		[tiledLayer setLevelsOfDetailBias:2];
//    }
//    return self;
//}
//
//+ (Class) layerClass
//{
//	return [CATiledLayer class];
//}

- (void)setKeyword:(NSString *)str
{
    keyword = str;
	self.selections = nil;
}

- (NSArray *)selections
{
	@synchronized (self)
	{
		if (!selections)
		{
			self.selections = [self.scanner select:self.keyword];
		}
		return selections;
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    CGRect rcBound = CGRectMake(0, 0, layer.bounds.size.width, layer.bounds.size.height);
    
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, rcBound);
	
    // Flip the coordinate system    
	CGContextTranslateCTM(ctx, 0.0, rcBound.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGRect rc = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
    float scaleRatio = MIN(rcBound.size.width/rc.size.width,rcBound.size.height/rc.size.height);
    CGContextScaleCTM(ctx, scaleRatio, scaleRatio);
    
//    //adjust content box position
//    float ratioBound = rcBound.size.width/rcBound.size.height;
//    float ratioBox = rc.size.width/rc.size.height;
//    float ratio = fabsf(ratioBound-ratioBox);
//    if (ratio < 0.1) ratio = 0;
//    
//    if (rcBound.size.width > rcBound.size.height)
//    {
//        float off = ratio * fabsf(rc.size.width-rcBound.size.width);
//        CGContextTranslateCTM(ctx, off, 0);
//    }
//    else
//    {
//        float off = ratio * rc.size.height;
//        CGContextTranslateCTM(ctx, 0, off);
//    }
    
	CGContextDrawPDFPage(ctx, pdfPage);
	
	if (self.keyword)
    {
        CGContextSetFillColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        for (Selection *s in self.selections)
        {
            CGContextSaveGState(ctx);
            CGContextConcatCTM(ctx, s.transform);
            CGContextFillRect(ctx, s.frame);
            CGContextRestoreGState(ctx);
        }
    }
    
    CGContextRestoreGState(ctx);
}

#pragma mark PDF drawing

/* Draw the PDFPage to the content view */
- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
	CGContextFillRect(ctx, rect);
}

/* Sets the current PDFPage object */
- (void)setPage:(CGPDFPageRef)page
{
    CGPDFPageRelease(pdfPage);
	pdfPage = CGPDFPageRetain(page);
	self.scanner = [Scanner scannerWithPage:pdfPage];
}

@end
