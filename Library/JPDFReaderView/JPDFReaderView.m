//
//  JPDFReaderView.m
//  iOS-Dev-Helper
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "UIView+Transform.h"
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
//    [self createScrollContainerIfNeed];
    [self createTableViewIfNeed];
    
    CGPDFDocumentRelease(refDocument);
    
    refDocument = CGPDFDocumentCreateWithURL((CFURLRef)url);
    numberOfPage = CGPDFDocumentGetNumberOfPages(refDocument);
    
    widthOfPage = tbView.frame.size.width;
    heightOfPage = tbView.frame.size.height;

    [tbView reloadData];

    [self relayout];
}

#pragma mark PRIVATE
- (void) setupInit
{
    dictCachedPDFLayer = [[NSMutableDictionary alloc] init];
    isGotInit = YES;
}

- (void) createTableViewIfNeed
{
    if (tbView) return;
    
    tbView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tbView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tbView.frame = self.bounds;
    tbView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:tbView];
    
    tbView.dataSource = self;
    tbView.delegate = self;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [tbView addGestureRecognizer:pinchGesture];
}

- (void) createScrollContainerIfNeed
{
    if (scrollContainer) return;
    
    scrollContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollContainer.backgroundColor = [UIColor yellowColor];
    [scrollContainer setDelaysContentTouches:NO];
    scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:scrollContainer];
}

- (void) relayout
{
    scrollContainer.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    cell.frame = CGRectMake(0, 0,widthOfPage , heightOfPage);
//    cell.contentView.frame = cell.bounds;
    
    UIView* vwCover = [cell viewWithTag:2];
    vwCover.frame = CGRectMake(0, 0, widthOfPage, heightOfPage);
    
    JPDFReaderPageView* page = (JPDFReaderPageView*)[cell viewWithTag:1];
    page.frame = CGRectMake(5, 5, widthOfPage-10, heightOfPage-10);

//    NSLog(@"%@ ",NSStringFromCGRect(cell.frame));
    
    [page loadPDFDocument:refDocument page:(indexPath.row+1)];
    if (self.highlightKeyword)
    {
        page.keyword = self.highlightKeyword;
    }
    
    [page setNeedsDisplay];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float bound = widthOfPage-tbView.frame.size.width;
    
    if (scrollView.contentOffset.x > bound)
    {
        [scrollView setContentOffset:CGPointMake(bound, scrollView.contentOffset.y)];
    }
    
    if (scrollView.contentOffset.x < 0)
    {
        [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
    }
}
#pragma mark UIGestureRecognizerDelegate

- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer {
	   
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
//        UIView* vw = [gestureRecognizer view];
        CGPoint pos = [gestureRecognizer locationInView:nil];
                
        float ratioLeft = pos.x/tbView.frame.size.width;
        float ratioTop = tbView.contentOffset.y/tbView.contentSize.height;
        
        float scale = [gestureRecognizer scale];
        
        float ww = widthOfPage*scale;
        float hh = heightOfPage*scale;
        
        if (ww < tbView.frame.size.width)
        {
            ww = tbView.frame.size.width;
            hh = tbView.frame.size.height;
        }
        
        if (ww > tbView.frame.size.width*1.8)
        {
            ww = tbView.frame.size.width*1.8;
            hh = tbView.frame.size.height*1.8;
        }
        
        if (ww == widthOfPage) return;
        
        widthOfPage = ww;
        heightOfPage = hh;

        [tbView reloadData];
        tbView.contentSize = CGSizeMake(widthOfPage, tbView.contentSize.height);

        UIScrollView* scroll = ((UIScrollView*)tbView);
        [scroll setContentOffset:CGPointMake( tbView.contentSize.width*ratioLeft, tbView.contentSize.height*ratioTop)];

		[gestureRecognizer setScale:1];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
