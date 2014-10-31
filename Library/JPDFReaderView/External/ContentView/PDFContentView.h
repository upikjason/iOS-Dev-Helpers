#import "Scanner.h"

@interface PDFContentView : UIView {
	CGPDFPageRef pdfPage;
    NSString *keyword;
	NSArray *selections;
	Scanner *scanner;
}

#pragma mark

- (void) setPage:(CGPDFPageRef)page;

@property (nonatomic, retain) Scanner *scanner;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSArray *selections;

@end

#pragma mark
