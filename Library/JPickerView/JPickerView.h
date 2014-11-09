//
//  JPickerView.h
//  JPickerView
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <UIKit/UIKit.h>

//----------------------------------------
@protocol JPickerViewDataSource;
@protocol JPickerViewDelegate;

@interface JPickerView : UIView <UITableViewDataSource,UITableViewDelegate>
{
    BOOL isGotInit;
    
    NSMutableArray* lstReclaimedComponents;
    NSMutableArray* lstComponents;
    
    float defWidth; //when no response for width of component, build default width

    UIImageView* imgViewBackground;
}

#pragma mark MAIN

@property (nonatomic,assign) id<JPickerViewDataSource> dataSource;
@property (nonatomic,assign) id<JPickerViewDelegate> delegate;

- (NSInteger)numberOfRowsInComponent:(NSInteger)component; //OUT
- (CGSize)rowSizeForComponent:(NSInteger)component; //OUT

// returns the view provided by the delegate via pickerView:viewForRow:forComponent:reusingView:
// or nil if the row/component is not visible or the delegate does not implement
// pickerView:viewForRow:forComponent:reusingView:
- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component; //OUT

// Reloading whole view or single component
- (void)reloadAllComponents; //IN
- (void)reloadComponent:(NSInteger)component; //IN

// selection. in this case, it means showing the appropriate row in the middle
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated; // scrolls the specified row to center. //IN

- (NSInteger)selectedRowInComponent:(NSInteger)component;                                   // returns selected row. -1 if nothing selected //OUT

@end

//----------------------------------------
@protocol JPickerViewDataSource<NSObject>
@required

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(JPickerView *)pickerView; //IN

// returns the # of rows in each component..
- (NSInteger)pickerView:(JPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; //IN
@end

//----------------------------------------
@protocol JPickerViewDelegate<NSObject>
@optional

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(JPickerView *)pickerView widthForComponent:(NSInteger)component; //IN
- (CGFloat)pickerView:(JPickerView *)pickerView rowHeightForComponent:(NSInteger)component; //IN

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(JPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component; //IN

//- (NSAttributedString *)pickerView:(JPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0); // attributed title is favored if both methods are implemented //IN

- (UIView *)pickerView:(JPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view; //IN

- (void)pickerView:(JPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component; //OUT

@end

