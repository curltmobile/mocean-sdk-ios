//
//  MASTSMenuController.h
//  MASTSamples
//
//  Created by Jason Dickert on 4/16/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTSMenuController;


@protocol MASTSMenuDelegate <NSObject>
@required

- (void)menuController:(MASTSMenuController*)menuController presentController:(UIViewController*)controller;
- (void)menuController:(MASTSMenuController *)menuController setLocationUsage:(BOOL)usage;

@end


@interface MASTSMenuController : UITableViewController


@property (nonatomic, assign) id<MASTSMenuDelegate> delegate;

@end
