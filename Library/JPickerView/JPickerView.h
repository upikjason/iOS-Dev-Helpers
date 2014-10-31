//
//  JPickerView.h
//  JPickerView
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JPickerView;

//----------
@protocol JPickerViewDelegate <NSObject>

@required
- (void) JPickerView:(JPickerView*)picker configViewForList:(NSString*)listName reuseView:(UIView*)view width:(float) width height:(float)height;
- (void) JPickerView:(JPickerView*)picker configViewForItem:(NSString*)itemName reuseView:(UIView*)view width:(float) width height:(float)height;;

@optional
- (void) JPickerView:(JPickerView*)picker didSelectList:(NSString*)listName;
- (void) JPickerView:(JPickerView*)picker didSelectItem:(NSString*)itemName;
- (void) JPickerView:(JPickerView*)picker didSelectConvertItem:(NSString*)itemName;
@end

//----------
@interface JPickerView : UIView <UITableViewDataSource,UITableViewDelegate>
{
    UIImageView* imgViewBackground;
    UIImageView* imgViewSelectionIndicator;
    
    int anchorIndex;
    float anchorOffset;
    
    UITableView* tbViewList;
    int indexTbViewList;
    
    UITableView* tbViewItem;
    int indexTbViewItem;

    UITableView* tbViewConvertItem;
    int indexTbViewConvertItem;
    
    NSDictionary* pickerData;
    
    NSMutableArray* lstOfList;
    int selectedListIndex;

    NSMutableArray* lstOfItem;
    int selectedItemIndex;
    int selectedConvertItemIndex; 
}

#pragma mark MAIN
@property (nonatomic,weak) id<JPickerViewDelegate> delegate;

@property (nonatomic,strong) UIImage* pickerBackgroundImage;
@property (nonatomic,strong) UIImage* pickerSelectionIndicatorImage;
@property (nonatomic) float pickerRowHeight;
@property (nonatomic) float pickerListWidth;

//{lists:[{name,items,is_convert} ] }
- (void) presentData:(NSDictionary*)data;

@end
