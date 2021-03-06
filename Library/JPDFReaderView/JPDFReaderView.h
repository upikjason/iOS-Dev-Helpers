//
//  JPDFReaderView.h
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPDFReaderView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    CGPDFDocumentRef refDocument;
    int numberOfPage;
    float heightOfPage;
    float widthOfPage;
    
    NSMutableDictionary* dictCachedPDFLayer; //pageIndex->pdf
    
    BOOL isGotInit;
    
    UIScrollView* scrollContainer;
    UITableView* tbView;
}

#pragma mark MAIN
@property (nonatomic,strong) NSString* highlightKeyword;

- (void) loadPDFURL:(NSURL*)url;

@end
