//
//  LapTimerController.h
//  Timer
//
//  Created by Ben Jacobs <benmillerj@gmail.com> on 8/31/12.
//  Copyleft 2012
//

#import <UIKit/UIKit.h>

@protocol LapTimerProtocol;

@interface LapTimerController : UIViewController <UITableViewDataSource>

@property (nonatomic, assign) id <LapTimerProtocol> delegate;
@property (nonatomic, assign) BOOL timerCanceled;

@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;

@property (retain, nonatomic) IBOutlet UIButton *buttonOk;
@property (retain, nonatomic) IBOutlet UIButton *buttonCancel;
@property (retain, nonatomic) IBOutlet UITableView *lapHistory;
@property (retain, nonatomic) IBOutlet UILabel *mainTimer;
@property (retain, nonatomic) IBOutlet UILabel *lapTimer;

- (IBAction)button1Pressed:(id)sender;
- (IBAction)button2Pressed:(id)sender;

- (IBAction) okButtonPressed:(id)sender;
- (IBAction) cancelButtonPressed:(id)sender;

- (LapTimerController *) newLapTimerWithDelegate:(id) delegate;

- (double) timeElapsedInSeconds;
- (double) timeElapsedInMinutes;

- (double) totalElapsedInSeconds;
- (double) totalElapsedInMinutes;

@end

@protocol LapTimerProtocol

- (void) timerDidFinish:(LapTimerController*) timer;

@end


