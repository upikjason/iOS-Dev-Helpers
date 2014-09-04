//
//  JTableView.h
//  Cuplin
//
//  Created by upikjason on 8/29/14.
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTableView;

@protocol JTableViewDelegate <NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView doRefreshWithData:(id)obj;

@end

@interface JTableView : UITableView <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    CGPoint orgZeroOffset;
    
    float contentInsetY;
    
    //search bar
    UISearchBar* searchBar;
    
    //refresh view
    BOOL isRefreshing;
    UIView* vwRefresh;
    
    BOOL lockContentOffsetChange;
}

#pragma mark MAIN
@property (nonatomic,weak) id<JTableViewDelegate> jtableViewDelegate;

- (void) setSearchEnable:(BOOL)is;
- (void) setPullToRefreshEnable:(BOOL)is;

- (UISearchBar*) getSearchBar;

- (void) beginRefresh;
- (void) endRefresh;

@end
