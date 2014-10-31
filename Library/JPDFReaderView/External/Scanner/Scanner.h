#import <Foundation/Foundation.h>
#import "StringDetector.h"
#import "FontCollection.h"
#import "RenderingState.h"
#import "Selection.h"
#import "RenderingStateStack.h"

@interface Scanner : NSObject <StringDetectorDelegate> {
	CGPDFPageRef pdfPage;
	NSMutableArray *selections;
    Selection *possibleSelection;
	
	StringDetector *stringDetector;
	FontCollection *fontCollection;
	RenderingStateStack *renderingStateStack;
	NSMutableString *content;
}

+ (Scanner *)scannerWithPage:(CGPDFPageRef)page;

- (NSArray *)select:(NSString *)keyword;

@property (nonatomic, readonly) RenderingState *renderingState;

@property (nonatomic, strong) RenderingStateStack *renderingStateStack;
@property (nonatomic, strong) FontCollection *fontCollection;
@property (nonatomic, strong) StringDetector *stringDetector;
@property (nonatomic, strong) NSMutableString *content;


@property (nonatomic, strong) NSMutableArray *selections;
@end
