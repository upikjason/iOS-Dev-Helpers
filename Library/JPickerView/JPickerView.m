//
//  JPickerView.m
//  JPickerView
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "JPickerView.h"

#define DEFAULT_LIST_WIDTH              70
#define DEFAULT_ROW_HEIGHT              30

#define AUTOSIZE_FULL               UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth
#define AUTOSIZE_FULL_HEIGHT        UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin

@interface JPickerView (Private)

- (void) selectListIndex:(int)idx;
- (void) reloadPickerView;

- (void) setPickerConvertMode:(BOOL)is;

- (void) setSelectedIndex:(int)idx ofTableView:(UITableView*)tbView onAfterAnimation:(void(^)(void))onAfterAnimation;

- (void) detectAnchorOffset;

- (void) snapForTableView:(UITableView*)tbView;

- (void) processAfterTableView:(UITableView*)tbView gotoIndex:(int)idx;
@end

@implementation JPickerView

#pragma mark INIT
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark MAIN
- (void) presentData:(NSDictionary*)data
{
    if (![data objectForKey:@"lists"])
    {
        NSAssert(1>2, @"JPickerView:presentData >>> lists not found");
        return;
    }
    
    anchorIndex = 20;
    if (self.pickerListWidth == 0)
        self.pickerListWidth = DEFAULT_LIST_WIDTH;
    
    if (self.pickerRowHeight <= DEFAULT_ROW_HEIGHT)
        self.pickerRowHeight = DEFAULT_ROW_HEIGHT;
    
    pickerData = data;
    
    if (!lstOfList) lstOfList = [NSMutableArray new];
    if (!lstOfItem) lstOfItem = [NSMutableArray new];
    
    [lstOfList removeAllObjects];
    for (id lst in [pickerData objectForKey:@"lists"])
    {
        [lstOfList addObject:[lst objectForKey:@"name"]];
    }
    int padding = anchorIndex;
    for (int i = 0; i < padding; i++)
    {
        [lstOfList insertObject:[NSNull null] atIndex:0];
        [lstOfList addObject:[NSNull null]];
    }
    
    if (lstOfList.count == 0)
    {
        NSAssert(1>2, @"JPickerView:presentData >>> lists empty");
        return;
    }
    
    [self selectListIndex:0];
    [self reloadPickerView];
}

#pragma mark PRIVATE
- (void) selectListIndex:(int)idx
{
    selectedListIndex = idx;
    
    [lstOfItem removeAllObjects];
    id lst = [[pickerData objectForKey:@"lists"] objectAtIndex:selectedListIndex];
    [lstOfItem addObjectsFromArray:[lst objectForKey:@"items"]];
    
    int padding = anchorIndex;
    for (int i = 0; i < padding; i++)
    {
        [lstOfItem insertObject:[NSNull null] atIndex:0];
        [lstOfItem addObject:[NSNull null]];
    }
    
    selectedItemIndex = 0;
    if ([[lst objectForKey:@"is_convert"] boolValue])
    {
        selectedConvertItemIndex = 0;
    }
    else
    {
        selectedConvertItemIndex = -1;
    }
}

- (void) reloadPickerView
{
    if (!tbViewList)
    {
        imgViewBackground = [[UIImageView alloc] initWithFrame:self.bounds];
        imgViewBackground.autoresizingMask = AUTOSIZE_FULL;
        imgViewBackground.backgroundColor = [UIColor clearColor];
        [self addSubview:imgViewBackground];
        
        tbViewList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tbViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbViewList.frame = CGRectMake(0, 0, self.pickerListWidth, self.frame.size.height);
        tbViewList.autoresizingMask = AUTOSIZE_FULL_HEIGHT;
        tbViewList.dataSource = self;
        tbViewList.delegate = self;
        tbViewList.backgroundColor = [UIColor clearColor];
        [tbViewList setShowsVerticalScrollIndicator:NO];
        [self addSubview:tbViewList];
        
        float remainWidth = self.frame.size.width - self.pickerListWidth;
        
        tbViewItem = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tbViewItem.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbViewItem.frame = CGRectMake(self.pickerListWidth, 0, remainWidth/2, self.frame.size.height);
        tbViewItem.autoresizingMask = AUTOSIZE_FULL_HEIGHT;
        tbViewItem.dataSource = self;
        tbViewItem.delegate = self;
        tbViewItem.backgroundColor = [UIColor clearColor];
        [tbViewItem setShowsVerticalScrollIndicator:NO];
        [self addSubview:tbViewItem];

        tbViewConvertItem = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tbViewConvertItem.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbViewConvertItem.frame = CGRectMake(self.pickerListWidth+tbViewItem.frame.size.width, 0, remainWidth/2, self.frame.size.height);
        tbViewConvertItem.autoresizingMask = AUTOSIZE_FULL_HEIGHT;
        tbViewConvertItem.dataSource = self;
        tbViewConvertItem.delegate = self;
        tbViewConvertItem.backgroundColor = [UIColor clearColor];
        [tbViewConvertItem setShowsVerticalScrollIndicator:NO];
        [self addSubview:tbViewConvertItem];
        
        imgViewSelectionIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(tbViewList.frame.origin.x, (tbViewList.frame.size.height-self.pickerRowHeight)/2,self.frame.size.width, self.pickerRowHeight)];
        [self addSubview:imgViewSelectionIndicator];
        imgViewSelectionIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    }
    
    [tbViewList reloadData];
    if (anchorOffset == 0)
    {
        [self detectAnchorOffset];
    }
    [tbViewItem reloadData];
    
    [self setSelectedIndex:selectedListIndex ofTableView:tbViewList onAfterAnimation:nil];
    [self setSelectedIndex:selectedItemIndex ofTableView:tbViewItem onAfterAnimation:nil];

    if (selectedConvertItemIndex >= 0)
    {
        [tbViewConvertItem reloadData];
        [self setSelectedIndex:selectedConvertItemIndex ofTableView:tbViewConvertItem onAfterAnimation:nil];
    }
    
    [self setPickerConvertMode:(selectedConvertItemIndex>=0)];
}

- (void) setPickerConvertMode:(BOOL)is
{
    float remainWidth = self.frame.size.width - self.pickerListWidth;

    if (!is)
    {
        tbViewItem.frame = CGRectMake(self.pickerListWidth, 0, remainWidth, self.frame.size.height);
        tbViewConvertItem.frame = CGRectMake(self.pickerListWidth+tbViewItem.frame.size.width, 0, 0, self.frame.size.height);
    }
    else
    {
        tbViewItem.frame = CGRectMake(self.pickerListWidth, 0, remainWidth/2, self.frame.size.height);
        tbViewConvertItem.frame = CGRectMake(self.pickerListWidth+tbViewItem.frame.size.width, 0, remainWidth/2, self.frame.size.height);
    }
}

- (void) setSelectedIndex:(int)idx ofTableView:(UITableView*)tbView  onAfterAnimation:(void(^)(void))onAfterAnimation
{
    float off = idx*self.pickerRowHeight + anchorOffset;
    UIScrollView* scroll = (UIScrollView*)tbView;
    if (!onAfterAnimation)
    {
        [scroll setContentOffset:CGPointMake(0,off)];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [scroll setContentOffset:CGPointMake(0,off)];
        } completion:^(BOOL finished) {
            if (onAfterAnimation) onAfterAnimation();
        }];
    }
}

- (void) detectAnchorOffset
{
    NSIndexPath* idp = [NSIndexPath indexPathForRow:anchorIndex inSection:0];
    [tbViewList scrollToRowAtIndexPath:idp atScrollPosition:UITableViewScrollPositionTop animated:NO];
    UITableViewCell* cell = [tbViewList cellForRowAtIndexPath:idp];
    CGRect rcCell = [self convertRect:cell.frame fromView:cell.superview];
   
    float off = imgViewSelectionIndicator.frame.origin.y - rcCell.origin.y;
    UIScrollView* scroll = (UIScrollView*)tbViewList;
    [scroll setContentOffset:CGPointMake(0, scroll.contentOffset.y-off)];
    
    anchorOffset = scroll.contentOffset.y;
    NSLog(@"Detected anchor offset %.2f",anchorOffset);
}

- (void) snapForTableView:(UITableView*)tbView
{
    //after user release the drag
    // snap tbview to correct offset
    UIScrollView* scroll = (UIScrollView*) tbView;
    
    NSArray* lst = lstOfItem;
    if (tbView == tbViewList)
        lst = lstOfList;
    
    int n = lst.count-(anchorIndex*2) - 1;
    
    float idf = (scroll.contentOffset.y-anchorOffset)/self.pickerRowHeight;
    
    int targetIdx = floor(idf+0.5);
    if (idf < 0) targetIdx = 0;
    else if (idf > n) targetIdx = n;
    
    [self setSelectedIndex:targetIdx ofTableView:tbView onAfterAnimation:^{
        [self processAfterTableView:tbView gotoIndex:targetIdx];
    }];
}

- (void) processAfterTableView:(UITableView*)tbView gotoIndex:(int)idx
{
    if (tbView == tbViewList)
    {
        [self selectListIndex:idx];
        [self reloadPickerView];
        
        NSString* title = [lstOfList objectAtIndex:idx+anchorIndex];
        if ([self.delegate respondsToSelector:@selector(JPickerView:didSelectList:)])
        {
            [self.delegate JPickerView:self didSelectList:title];
        }
    }
    else if (tbView == tbViewItem)
    {
        selectedItemIndex = idx;
        
        NSString* title = [lstOfItem objectAtIndex:idx+anchorIndex];
        if ([self.delegate respondsToSelector:@selector(JPickerView:didSelectItem:)])
        {
            [self.delegate JPickerView:self didSelectItem:title];
        }
    }
    else
    {
        selectedConvertItemIndex = idx;
        
        NSString* title = [lstOfItem objectAtIndex:idx+anchorIndex];
        if ([self.delegate respondsToSelector:@selector(JPickerView:didSelectConvertItem:)])
        {
            [self.delegate JPickerView:self didSelectConvertItem:title];
        }
    }
}

#pragma mark UITableViewDelegate + UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tbViewList) return lstOfList.count;
    return lstOfItem.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.pickerRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"";
    if (tableView == tbViewList) cellIdentifier = @"tbViewList.Cell";
    else if (tableView == tbViewItem) cellIdentifier = @"tbViewItem.Cell";
    else cellIdentifier = @"tbViewConvertItem.Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int idx = indexPath.row;
    if (tableView == tbViewList)
    {
        NSArray* arr = lstOfList;
        NSString* title = [arr objectAtIndex:idx];
        [cell.contentView setHidden:[title isKindOfClass:[NSNull class]]];
        
        if (![title isKindOfClass:[NSNull class]])
        {
            [self.delegate JPickerView:self configViewForList:title reuseView:cell.contentView width:self.pickerListWidth height:self.pickerRowHeight];
        }
    }
    else
    {
        float remainWidth = self.frame.size.width - self.pickerListWidth;
        if (selectedConvertItemIndex >= 0) remainWidth = remainWidth/2;

        NSArray* arr = lstOfItem;
        NSString* title = [arr objectAtIndex:idx];
        [cell.contentView setHidden:[title isKindOfClass:[NSNull class]]];

        if (![title isKindOfClass:[NSNull class]])
        {
            [self.delegate JPickerView:self configViewForItem:title reuseView:cell.contentView width:remainWidth height:self.pickerRowHeight];
        }
    }
    
    return cell;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UITableView* tbView = (UITableView*)scrollView;
    for (UITableViewCell* cell in tbView.visibleCells)
    {
        CGRect rcCell = [self convertRect:cell.frame fromView:cell.superview];
        float off = 1.0 - ( fabsf(rcCell.origin.y - imgViewSelectionIndicator.frame.origin.y)/(self.frame.size.height/2));
        [cell setAlpha:off];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self snapForTableView:(UITableView*)scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSArray* lst = lstOfItem;
    if (scrollView == tbViewList)
        lst = lstOfList;
    
    int n = lst.count-(anchorIndex*2) - 1;
    
    float idf = (targetContentOffset->y-anchorOffset)/self.pickerRowHeight;
    int targetIdx = floor(idf+0.5);
    
    int currentIdx = floor(((scrollView.contentOffset.y-anchorOffset)/self.pickerRowHeight) + 0.5);
    
    if ((currentIdx <= 0 || currentIdx >= n) && (idf < 0 || idf > n))
    {
        targetContentOffset->y = scrollView.contentOffset.y;
        idf = (targetContentOffset->y-anchorOffset)/self.pickerRowHeight;
        targetIdx = floor(idf+0.5);
    }
    else if (currentIdx > 0 && currentIdx < n && (idf < 0 || idf > n))
    {
        if (idf < 0) targetIdx = 0;
        if (idf > n) targetIdx = n;
        float off = targetIdx*self.pickerRowHeight+anchorOffset;
        targetContentOffset->y = off;
    }
    else
    {
        float off = targetIdx*self.pickerRowHeight+anchorOffset;
        targetContentOffset->y = off;        
    }
    
    if (scrollView == tbViewList) indexTbViewList = targetIdx;
    else if (scrollView == tbViewItem) indexTbViewItem = targetIdx;
    else indexTbViewConvertItem = targetIdx;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == tbViewList)
    {
        [self processAfterTableView:tbViewList gotoIndex:indexTbViewList];
    }
    else if (scrollView == tbViewItem)
    {
        [self processAfterTableView:tbViewItem gotoIndex:indexTbViewItem];
    }
    else
    {
        [self processAfterTableView:tbViewConvertItem gotoIndex:indexTbViewConvertItem];
    }
}
@end
