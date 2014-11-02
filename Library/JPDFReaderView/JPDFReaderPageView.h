//
//  JPDFReaderPageView.h
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFContentView.h"

@interface JPDFReaderPageView : PDFContentView
{
    
}

#pragma mark MAIN
- (void) loadPDFURL:(NSURL*)url page:(int)page;
- (void) loadPDFDocument:(CGPDFDocumentRef)ref page:(int)page;

@end
