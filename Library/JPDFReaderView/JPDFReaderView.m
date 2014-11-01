//
//  JPDFReaderView.m
//  iOS-Dev-Helper
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "JPDFReaderPageView.h"
#import "JPDFReaderView.h"

@interface JPDFReaderView (Private)

- (void) setupInit;
- (void) createTableViewIfNeed;

- (void) createScrollContainerIfNeed;

- (void) relayout;

@end

@implementation JPDFReaderView

#pragma mark INIT
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    if (!isGotInit)
    {
        [self setupInit];
    }
    
    [super layoutSubviews];
}

#pragma mark MAIN

- (void) loadPDFURL:(NSURL*)url
{
    [self createScrollContainerIfNeed];
    [self createTableViewIfNeed];
    
    CGPDFDocumentRelease(refDocument);
    
    refDocument = CGPDFDocumentCreateWithURL((CFURLRef)url);
    numberOfPage = CGPDFDocumentGetNumberOfPages(refDocument);
    heightOfPage = self.frame.size.height;
    widthOfPage = self.frame.size.width;
    
    [tbView reloadData];

    [self relayout];
}

#pragma mark PRIVATE
- (void) setupInit
{
    scrollContainer.delegate = self;
    scrollContainer.minimumZoomScale = 1.0;
    scrollContainer.maximumZoomScale = 6.0;
    
    dictCachedPDFLayer = [[NSMutableDictionary alloc] init];
    isGotInit = YES;
}

- (void) createTableViewIfNeed
{
    if (tbView) return;
    
    tbView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tbView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tbView.frame = self.bounds;
    [scrollContainer addSubview:tbView];
    
    tbView.dataSource = self;
    tbView.delegate = self;
}

- (void) createScrollContainerIfNeed
{
    if (scrollContainer) return;
    
    scrollContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:scrollContainer];
}

- (void) relayout
{
    scrollContainer.contentSize = tbView.bounds.size;
    
    tbView.transform = CGAffineTransformIdentity;
    scrollContainer.transform = CGAffineTransformIdentity;
}

#pragma mark UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numberOfPage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return heightOfPage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"JPDFReaderCellView"];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"JPDFReaderCellView" owner:nil options:nil] objectAtIndex:0];
    }
    
    cell.frame = CGRectMake(0, 0,widthOfPage , heightOfPage);
    cell.contentView.frame = cell.bounds;
    
    JPDFReaderPageView* page = (JPDFReaderPageView*)[cell viewWithTag:1];
    page.frame = CGRectMake(5, 5, cell.contentView.bounds.size.width-10, cell.contentView.bounds.size.height-10);
    
    [page loadPDFDocument:refDocument page:(indexPath.row+1)];
    if (self.highlightKeyword)
    {
        page.keyword = self.highlightKeyword;
    }
    
    [page setNeedsDisplay];
    
    return cell;
}

#pragma mark UIScrollViewDelegate
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    if (scrollView == scrollContainer)
//    {
//        return tbView;
//    }
//    return nil;
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
//{
//    widthOfPage = self.bounds.size.width*scale;
//    heightOfPage = self.bounds.size.height*scale;
//    tbView.frame = CGRectMake(0, 0,widthOfPage , heightOfPage);
//    [tbView reloadData];
//    
//    [self relayout];
//}
@end
