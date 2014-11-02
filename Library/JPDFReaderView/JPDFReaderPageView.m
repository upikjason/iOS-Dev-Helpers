//
//  JPDFReaderPageView.m
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "JPDFReaderPageView.h"

@implementation JPDFReaderPageView

#pragma mark INIT
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark MAIN
- (void) loadPDFURL:(NSURL*)url page:(int)page
{
    CGPDFDocumentRef refDoc = CGPDFDocumentCreateWithURL((CFURLRef)url);
    CGPDFPageRef refPage = CGPDFDocumentGetPage(refDoc, page);
    [self setPage:refPage];
}

- (void) loadPDFDocument:(CGPDFDocumentRef)ref page:(int)page
{
    CGPDFPageRef refPage = CGPDFDocumentGetPage(ref, page);
    [self setPage:refPage];
}

@end
