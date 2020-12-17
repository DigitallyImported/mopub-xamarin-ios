//
//  MPIndexPathPickerView.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>

@protocol MPIndexPathPickerViewDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPIndexPathPickerView : UIView

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPIndexPathPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<MPIndexPathPickerViewDelegate> delegate;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UIToolbar *toolbar;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPIndexPathPickerViewDelegate <NSObject>

- (NSInteger)numberOfSectionsForIndexPathPickerView:(MPIndexPathPickerView *)pickerView;
- (NSInteger)indexPathPickerView:(MPIndexPathPickerView *)pickerView numberOfItemsInSection:(NSInteger)section;
- (void)indexPathPickerView:(MPIndexPathPickerView *)pickerView didSelectIndexPath:(NSIndexPath *)indexPath;

@end
