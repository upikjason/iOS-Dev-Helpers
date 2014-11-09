//
//  JPickerView.m
//  JPickerView
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "JPickerView.h"

#define ANCHOR_INDEX                    20

//**************************************************

//----------------------------------------
@interface JPickerViewComponent : NSObject

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic) int numberOfRows;
@property (nonatomic) int selectedIndex;

@property (nonatomic) CGRect frameCenter;
@property (nonatomic) float anchorOffset;

@property (nonatomic) float height;
@property (nonatomic) float width;

@property (nonatomic) int willSelectedIndex;

@property (nonatomic,strong) UIImageView* imgViewSelection;

@end

//----------------------------------------
@implementation JPickerViewComponent
@end

//**************************************************

//----------------------------------------
@interface JPickerView (Private)

- (void) setupInit;
- (void) detectAnchorOffsetForComponentIndex:(int)idx;
- (void) snapForTableView:(UITableView*)tbView;

@end

//----------------------------------------
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

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (!isGotInit)
    {
        [self setupInit];
        isGotInit = YES;
        
        [self reloadAllComponents];
    }
}

- (void)dealloc
{
    [lstReclaimedComponents removeAllObjects];
    [lstComponents removeAllObjects];
        
    self.dataSource = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark MAIN
- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:component];
    return comp.numberOfRows;
}

- (CGSize)rowSizeForComponent:(NSInteger)component
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:component];
    return CGSizeMake(comp.width, comp.height);
}

// returns the view provided by the delegate via pickerView:viewForRow:forComponent:reusingView:
// or nil if the row/component is not visible or the delegate does not implement
// pickerView:viewForRow:forComponent:reusingView:
- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:component];
    
    UITableView* tbView = comp.tableView;
    UITableViewCell* cell = [tbView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    return [cell.contentView viewWithTag:111];
}

// Reloading whole view or single component
- (void)reloadAllComponents
{
    //reclaim
    for (JPickerViewComponent* comp in lstComponents)
    {
        [comp.tableView removeFromSuperview];
        [comp.imgViewSelection removeFromSuperview];
    }
    [lstReclaimedComponents addObjectsFromArray:lstComponents];
    [lstComponents removeAllObjects];
    
    //alloc
    int n = [self.dataSource numberOfComponentsInPickerView:self];
    
    if (![self.delegate respondsToSelector:@selector(pickerView:widthForComponent:)])
    {
        defWidth = self.frame.size.width/n;
    }
    else
    {
        defWidth = -1;
    }
    
    for (int i = 0; i < n; i++)
    {
        JPickerViewComponent* comp = nil;
        if (lstReclaimedComponents.count == 0)
        {
            comp = [[[JPickerViewComponent alloc] init] autorelease];
            comp.tableView = [[[UITableView alloc] init] autorelease];
            comp.imgViewSelection = [[[UIImageView alloc] init] autorelease];
        }
        else
        {
            comp = [lstReclaimedComponents objectAtIndex:0];
            [lstReclaimedComponents removeObjectAtIndex:0];
        }
        
        [lstComponents addObject:comp];
        
        [self reloadComponent:i];
    }
}

- (void)reloadComponent:(NSInteger)component
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:component];
    
    comp.numberOfRows = [self.dataSource pickerView:self numberOfRowsInComponent:component];
    comp.selectedIndex = -1;
    
    if ([self.delegate respondsToSelector:@selector(pickerView:widthForComponent:)])
    {
        comp.width = [self.delegate pickerView:self widthForComponent:component];
    }
    else
    {
        comp.width = defWidth;
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)])
    {
        comp.height = [self.delegate pickerView:self rowHeightForComponent:component];
    }
    else
    {
        comp.height = 30.0;
    }
    
    float orgX = 0;
    for (int i = 0; i < component; i++)
    {
        JPickerViewComponent* prev = [lstComponents objectAtIndex:i];
        orgX += prev.width;
    }
    
    //table view
    UITableView* tbView = comp.tableView;
    tbView.tag = 10+component;
    
    tbView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin;
    tbView.frame = CGRectMake(orgX, 0, comp.width, self.frame.size.height);
    tbView.backgroundColor = [UIColor clearColor];
    tbView.dataSource = self;
    tbView.delegate = self;
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbView setShowsVerticalScrollIndicator:NO];
    
    [self addSubview:tbView];
    
    //selection
    UIImageView* imgView = comp.imgViewSelection;
    imgView.frame = CGRectMake(orgX, (tbView.frame.size.height-comp.height)/2, comp.width, comp.height);
    imgView.image = [[UIImage imageNamed:@"JPickerView_SelectionIndicator.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    [self addSubview:imgView];

    //reload
    [comp.tableView reloadData];
    
    //anchor offset
    [self detectAnchorOffsetForComponentIndex:component];
    
    //select initial
    [self selectRow:0 inComponent:component animated:NO];
}

// selection. in this case, it means showing the appropriate row in the middle
// scrolls the specified row to center.
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:component];
    float off = (row*comp.height)+comp.anchorOffset;
    
    UIScrollView* scroll = (UIScrollView*)comp.tableView;
    if (!animated)
    {
        [scroll setContentOffset:CGPointMake(0,off)];
        if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)])
        {
            [self.delegate pickerView:self didSelectRow:row inComponent:component];
        }
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [scroll setContentOffset:CGPointMake(0,off)];
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)])
            {
                [self.delegate pickerView:self didSelectRow:row inComponent:component];
            }
        }];
    }
}

// returns selected row. -1 if nothing selected
- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:component];
    return comp.selectedIndex;
}

#pragma mark Private
- (void) setupInit
{
    lstComponents = [[NSMutableArray alloc] init];
    lstReclaimedComponents = [[NSMutableArray alloc] init];
}

- (void) detectAnchorOffsetForComponentIndex:(int)idx
{
    JPickerViewComponent* comp = [lstComponents objectAtIndex:idx];
    
    UITableView* tbView = comp.tableView;
    
    comp.frameCenter = CGRectMake(0, (tbView.frame.size.height-comp.height)/2, tbView.frame.size.width, comp.height);
    
    NSIndexPath* idp = [NSIndexPath indexPathForRow:ANCHOR_INDEX inSection:0];
    [tbView scrollToRowAtIndexPath:idp atScrollPosition:UITableViewScrollPositionTop animated:NO];
    UITableViewCell* cell = [tbView cellForRowAtIndexPath:idp];
    CGRect rcCell = [self convertRect:cell.frame fromView:cell.superview];
    
    float off = comp.frameCenter.origin.y - rcCell.origin.y;
    UIScrollView* scroll = (UIScrollView*)tbView;
    [scroll setContentOffset:CGPointMake(0, scroll.contentOffset.y-off)];
    
    comp.anchorOffset = scroll.contentOffset.y;
}

- (void) snapForTableView:(UITableView*)tbView
{
    int compIdx = tbView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];
    
    UIScrollView* scroll = (UIScrollView*) tbView;
    
    int n = comp.numberOfRows-1;
    
    float idf = (scroll.contentOffset.y-comp.anchorOffset)/comp.height;
    
    int targetIdx = floor(idf+0.5);
    if (idf < 0) targetIdx = 0;
    else if (idf > n) targetIdx = n;
    
    [self selectRow:targetIdx inComponent:compIdx animated:YES];
}

#pragma mark UITableViewDataSource,UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"JPickerViewCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JPickerViewCell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView* vw = [cell.contentView viewWithTag:111];
    [vw setHidden:YES];
    [cell.textLabel setHidden:YES];

    int compIdx = tableView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];
    
    if (indexPath.row < ANCHOR_INDEX || indexPath.row > comp.numberOfRows+ANCHOR_INDEX-1)
    {
        return cell;
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)])
    {
        [cell.textLabel setHidden:NO];
        
        cell.textLabel.text = [self.delegate pickerView:self titleForRow:(indexPath.row-ANCHOR_INDEX) forComponent:compIdx];
    }
    else if ([self.delegate respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)])
    {
        UIView* vw = [cell.contentView viewWithTag:111];
        if (!vw)
        {
            vw = [[[UIView alloc] init] autorelease];
            vw.frame = cell.contentView.bounds;
            vw.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:vw];
        }
        
        [vw setHidden:NO];
        [cell.contentView bringSubviewToFront:vw];
        
        [self.delegate pickerView:self viewForRow:(indexPath.row-ANCHOR_INDEX) forComponent:compIdx reusingView:vw];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int compIdx = tableView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];
    return comp.numberOfRows+(ANCHOR_INDEX*2);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int compIdx = tableView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];
    return comp.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int compIdx = tableView.tag - 10;

    int targetIdx = indexPath.row - ANCHOR_INDEX;
    
    [self selectRow:targetIdx inComponent:compIdx animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UITableView* tbView = (UITableView*)scrollView;
    int compIdx = tbView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];

    for (UITableViewCell* cell in tbView.visibleCells)
    {
        CGRect rcCell = [self convertRect:cell.frame fromView:cell.superview];
        float off = 1.0 - ( fabsf(rcCell.origin.y - comp.frameCenter.origin.y)/(self.frame.size.height/2));
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
    UITableView* tbView = (UITableView*)scrollView;
    int compIdx = tbView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];
    
    int n = (int)comp.numberOfRows - 1;
    
    float idf = (targetContentOffset->y-comp.anchorOffset)/comp.height;
    int targetIdx = floor(idf+0.5);
    
    int currentIdx = floor(((scrollView.contentOffset.y-comp.anchorOffset)/comp.height) + 0.5);
    
    if ((currentIdx <= 0 || currentIdx >= n) && (idf < 0 || idf > n))
    {
        targetContentOffset->y = scrollView.contentOffset.y;
        idf = (targetContentOffset->y-comp.anchorOffset)/comp.height;
        targetIdx = floor(idf+0.5);
        
        if (targetIdx < 0) targetIdx = 0;
        if (targetIdx > n) targetIdx = n;
        
        [self selectRow:targetIdx inComponent:compIdx animated:YES];
    }
    else if (currentIdx > 0 && currentIdx < n && (idf < 0 || idf > n))
    {
        if (idf < 0) targetIdx = 0;
        if (idf > n) targetIdx = n;
        float off = targetIdx*comp.height+comp.anchorOffset;
        targetContentOffset->y = off;
        
        comp.willSelectedIndex = targetIdx;
    }
    else
    {
        float off = targetIdx*comp.height+comp.anchorOffset;
        targetContentOffset->y = off;
        
        comp.willSelectedIndex = targetIdx;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UITableView* tbView = (UITableView*)scrollView;
    int compIdx = tbView.tag - 10;
    JPickerViewComponent* comp = [lstComponents objectAtIndex:compIdx];

    [self selectRow:comp.willSelectedIndex inComponent:compIdx animated:NO];
}

@end
