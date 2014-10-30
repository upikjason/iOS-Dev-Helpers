//
//  JTableView.m
//  Cuplin
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "JTableView.h"

#define SEARCH_BAR_HEIGHT                       50.0
#define VIEW_REFRESH_HEIGHT                     70.0

@implementation JTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
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

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
        
        orgZeroOffset.x = -1;
        
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (lockContentOffsetChange)
    {
        return;
    }
    
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (lockContentOffsetChange)
    {
        return;
    }
    [super setContentOffset:contentOffset animated:animated];
}

#pragma mark MAIN
- (void) setSearchEnable:(BOOL)is
{
    UIView* target = self;
    if (!searchBar)
    {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, SEARCH_BAR_HEIGHT)];
        searchBar.frame = CGRectMake(0, -searchBar.frame.size.height, searchBar.frame.size.width, searchBar.frame.size.height);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            for (id vw in searchBar.subviews)
            {
                if ([vw isKindOfClass:[UITextField class]])
                {
                    UITextField* txt = vw;
                    txt.delegate = self;
                }
            }
            
        });
    }
    
    if (is)
    {
        if (vwRefresh.superview == target)
        {
            vwRefresh.frame = CGRectMake(0, -VIEW_REFRESH_HEIGHT-searchBar.frame.size.height, self.frame.size.width, VIEW_REFRESH_HEIGHT);
        }
        [target addSubview:searchBar];
    }
    else
    {
        [searchBar removeFromSuperview];
    }
}

- (void) setPullToRefreshEnable:(BOOL)is
{
    UIView* target = self;

    if (!vwRefresh)
    {
        vwRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, -VIEW_REFRESH_HEIGHT, self.frame.size.width, VIEW_REFRESH_HEIGHT)];
        
        UIActivityIndicatorView* vwIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        vwIndicator.frame = CGRectMake((vwRefresh.frame.size.width-vwIndicator.frame.size.width)/2, (vwRefresh.frame.size.height-vwIndicator.frame.size.height)/2, vwIndicator.frame.size.width, vwIndicator.frame.size.height);
        vwIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [vwIndicator stopAnimating];
        [vwIndicator setHidesWhenStopped:NO];
        vwIndicator.tag = 111;
        
        [vwRefresh addSubview:vwIndicator];
    }
    
    if (is)
    {
        if (searchBar.superview == target)
        {
            vwRefresh.frame = CGRectMake(0, -VIEW_REFRESH_HEIGHT-searchBar.frame.size.height, self.frame.size.width, VIEW_REFRESH_HEIGHT);
        }
        [target addSubview:vwRefresh];
    }
    else
    {
        [vwRefresh removeFromSuperview];
    }
}

- (UISearchBar*) getSearchBar
{
    return searchBar;
}

- (void) beginRefresh
{
    isRefreshing = YES;
    
    UIActivityIndicatorView* vwIndicator = (UIActivityIndicatorView*) [vwRefresh viewWithTag:111];
    [vwIndicator startAnimating];
    
    [self.jtableViewDelegate tableView:self doRefreshWithData:nil];
}

- (void) endRefresh
{
    UIActivityIndicatorView* vwIndicator = (UIActivityIndicatorView*) [vwRefresh viewWithTag:111];
    [vwIndicator stopAnimating];

    //refresh to SEARCH BAR
    if (searchBar.superview == self)
    {
        float extra = 1;
        contentInsetY = -orgZeroOffset.y+SEARCH_BAR_HEIGHT-extra;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setContentInset:UIEdgeInsetsMake(contentInsetY, 0, 0, 0)];
            [self setContentOffset:CGPointMake(0, orgZeroOffset.y-SEARCH_BAR_HEIGHT+extra)];
        }];
    }
    else
    {
        contentInsetY = -orgZeroOffset.y;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setContentInset:UIEdgeInsetsMake(contentInsetY, 0, 0, 0)];
            [self setContentOffset:CGPointMake(0, orgZeroOffset.y)];
        }];
    }

    isRefreshing = NO;
}

#pragma mark UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (orgZeroOffset.x < 0)
    {
        orgZeroOffset = self.contentOffset;
    }

    return [self.jtableViewDelegate tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.jtableViewDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.jtableViewDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.jtableViewDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    float extra = 1;
    if (searchBar.superview == self)
    {
        if (vwRefresh.superview == self && scrollView.contentOffset.y < (orgZeroOffset.y-SEARCH_BAR_HEIGHT-VIEW_REFRESH_HEIGHT*1.4) && //view refresh
            (contentInsetY == -orgZeroOffset.y+SEARCH_BAR_HEIGHT-extra || contentInsetY == -orgZeroOffset.y))
        {
            targetContentOffset->y = scrollView.contentOffset.y;
            contentInsetY = -orgZeroOffset.y+VIEW_REFRESH_HEIGHT+SEARCH_BAR_HEIGHT-extra;
            
            [UIView animateWithDuration:0.2 animations:^{
                [scrollView setContentInset:UIEdgeInsetsMake(contentInsetY, 0, 0, 0)];
                [scrollView setContentOffset:CGPointMake(0, orgZeroOffset.y-SEARCH_BAR_HEIGHT-VIEW_REFRESH_HEIGHT+extra)];
            }];

            [self beginRefresh];
        }
        else if (scrollView.contentOffset.y < (orgZeroOffset.y-(SEARCH_BAR_HEIGHT*1.2)) && contentInsetY == -orgZeroOffset.y)
        {
            targetContentOffset->y = scrollView.contentOffset.y;
            contentInsetY = -orgZeroOffset.y+SEARCH_BAR_HEIGHT-extra;
            
            [UIView animateWithDuration:0.2 animations:^{
                [scrollView setContentInset:UIEdgeInsetsMake(contentInsetY, 0, 0, 0)];
                [scrollView setContentOffset:CGPointMake(0, orgZeroOffset.y-SEARCH_BAR_HEIGHT+extra)];
            }];
            
        }
        else if (scrollView.contentOffset.y > orgZeroOffset.y && (contentInsetY == -orgZeroOffset.y+VIEW_REFRESH_HEIGHT+SEARCH_BAR_HEIGHT-extra || contentInsetY == -orgZeroOffset.y+SEARCH_BAR_HEIGHT-extra))
        {
            //hide search bar, (if no loading)
            if (!isRefreshing)
            {
                contentInsetY = -orgZeroOffset.y;
                [scrollView setContentInset:UIEdgeInsetsMake(contentInsetY, 0, 0, 0)];
                
            }
        }
    }
    else //only refresh view
    {
        if (scrollView.contentOffset.y < (orgZeroOffset.y-VIEW_REFRESH_HEIGHT*1.2) && //view refresh
            (contentInsetY == -orgZeroOffset.y-extra || contentInsetY == -orgZeroOffset.y))
        {
            targetContentOffset->y = scrollView.contentOffset.y;
            contentInsetY = -orgZeroOffset.y+VIEW_REFRESH_HEIGHT-extra;
            
            [UIView animateWithDuration:0.2 animations:^{
                [scrollView setContentInset:UIEdgeInsetsMake(contentInsetY, 0, 0, 0)];
                [scrollView setContentOffset:CGPointMake(0, orgZeroOffset.y-VIEW_REFRESH_HEIGHT+extra)];
            }];
            [self beginRefresh];

        }
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    lockContentOffsetChange = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->lockContentOffsetChange = NO;
    });
    return YES;
}

@end
