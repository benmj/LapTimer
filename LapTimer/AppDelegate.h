//
//  AppDelegate.h
//  LapTimer
//
//  Created by CVSS on 9/3/12.
//  Copyright (c) 2012 Ben Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LapTimerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LapTimerController *lapTimer;

@end
