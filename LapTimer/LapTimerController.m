//
//  LapTimerController.m
//  Timer
//
//  Created by Ben Jacobs <benmillerj@gmail.com> on 8/31/12.
//  Copyleft 2012
//

#import "LapTimerController.h"
#import "UIButtonGlossy.h"

@interface LapTimerController ()

typedef enum {
    stopped,
    running
} TimerState;

@property (nonatomic, retain) NSDate *runStart;
@property (nonatomic, retain) NSMutableArray *laps;
@property (nonatomic, assign) NSTimeInterval pauseTimeInterval;

@property (nonatomic, assign) TimerState state;
@property (nonatomic, retain) NSTimer *repeatingTimer;

@property (nonatomic, retain) NSDateFormatter *dateFormat;

- (void)startRepeatingTimer:sender;
- (void)stopRepeatingTimer:sender;

- (NSDate *)userInfo;

@end

@implementation LapTimerController
@synthesize button2;
@synthesize button1;
@synthesize buttonOk;
@synthesize buttonCancel;
@synthesize lapHistory;
@synthesize mainTimer;
@synthesize lapTimer;

- (LapTimerController *) newLapTimerWithDelegate:(id) delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.button1 setBackgroundToGlossyRectOfColor:[UIColor colorWithRed:.05 green:.65 blue:.05 alpha:1] withBorder:YES forState:UIControlStateNormal];
    [self.button2 setBackgroundToGlossyRectOfColor:[UIColor grayColor] withBorder:YES forState:UIControlStateNormal];
    
    // initialize variables
    self.state = stopped;
    
    self.laps = [[NSMutableArray alloc] init];
    
    self.dateFormat = [[NSDateFormatter alloc] init];
    [self.dateFormat setDateFormat:@"mm:ss.S"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [self.buttonOk release];
    [self.buttonCancel release];
    [self.lapHistory release];
    [self.button1 release];
    [self.button2 release];
    [self.mainTimer release];
    [self.lapTimer release];
    [super dealloc];
}

- (IBAction)button1Pressed:(id)sender {
    if(self.state == stopped) { // state is 'stopped,' pressing starts
        self.state = running;
        [self startRepeatingTimer:self];
        
        if(!self.runStart) {
            self.runStart = [NSDate date];
        } else {
            self.runStart = [NSDate dateWithTimeIntervalSinceNow:self.pauseTimeInterval];
        }
        
        //format buttons
        [self.button1 setTitle:@"Stop" forState:UIControlStateNormal];
        [self.button1 setBackgroundToGlossyRectOfColor:[UIColor colorWithRed:.65 green:.05 blue:.05 alpha:1] withBorder:YES forState:UIControlStateNormal];
        [self.button2 setTitle:@"Lap" forState:UIControlStateNormal];
    } else if (self.state = running) { // state is 'running,' pressing stops
        self.state = stopped;
        [self stopRepeatingTimer:self];
        
        self.pauseTimeInterval = [self.runStart timeIntervalSinceNow];
        
        [self.button1 setTitle:@"Start" forState: UIControlStateNormal];
        [self.button1 setBackgroundToGlossyRectOfColor:[UIColor colorWithRed:.05 green:.65 blue:.05 alpha:1] withBorder:YES forState:UIControlStateNormal];
        [self.button2 setTitle:@"Reset" forState:UIControlStateNormal];
    }
}

- (IBAction)button2Pressed:(id)sender {
    if(self.state == stopped) { // 'reset'
        [self.laps removeAllObjects];
        [self.lapHistory reloadData];
        
        self.runStart = nil;
        self.mainTimer.text = @"00:00.0";
        self.lapTimer.text = @"00:00.0";
    } else if (self.state = running) { // 'lap'
        NSNumber *thisLap = [NSNumber numberWithDouble:-[self.runStart timeIntervalSinceNow]]; // can't add NSTimeInterval to array because it's a primitive type (double)
        [self.laps addObject:thisLap];
        
        self.runStart = [NSDate date];
        
        [self.lapHistory reloadData];
        
        // scroll to the most recent lap
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self.laps count]-1 inSection:0];
        [self.lapHistory scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

- (IBAction)okButtonPressed:(id)sender {
    self.timerCanceled = FALSE;
    [self.delegate timerDidFinish:self];
}

- (IBAction)cancelButtonPressed:(id)sender {
    self.timerCanceled = TRUE;
    [self.delegate timerDidFinish:self];
}

// from Apple: https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Timers/Articles/usingTimers.html

- (void)startRepeatingTimer:sender {
    // Cancel a preexisting timer.
    [self.repeatingTimer invalidate];
    
    self.runStart = [NSDate date];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(targetMethod:)
                                                    userInfo:[self userInfo]
                                                     repeats:YES];
    self.repeatingTimer = timer;
}

- (void)stopRepeatingTimer:sender {
    [self.repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

-(void)targetMethod:(id)sender {
    self.mainTimer.text = [NSString stringWithFormat:@"%02.0f:%04.1f", [self totalElapsedInMinutes], [self totalElapsedInSeconds]];
 
    self.lapTimer.text = [NSString stringWithFormat:@"%02.0f:%04.1f", [self timeElapsedInMinutes], [self timeElapsedInSeconds]];
}

- (NSDate *)userInfo {
    return [NSDate date];
}

#pragma mark - Time Functions

- (double) timeElapsedInSeconds {
    return [[NSDate date] timeIntervalSinceDate:self.runStart];
}

- (double) timeElapsedInMinutes {
    return [self timeElapsedInSeconds] / 60.0f;
}

- (double) totalElapsedInSeconds {
    NSNumber *totalTime = [NSNumber numberWithDouble:0];
    
    for(id lap in self.laps) {
        totalTime = [NSNumber numberWithDouble:([totalTime doubleValue] + [(NSNumber*)lap doubleValue])];
    }
    
    totalTime = [NSNumber numberWithDouble:([totalTime doubleValue] + [self timeElapsedInSeconds])];
    
    return [totalTime doubleValue];
}

- (double) totalElapsedInMinutes {
    return [self totalElapsedInSeconds] / 60.0f;
}

#pragma mark - Table view Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.laps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                   reuseIdentifier: CellIdentifier] autorelease];
    
    double minutes = [(NSNumber*)[self.laps objectAtIndex:indexPath.row] doubleValue] / 60.0f;
    double seconds = [(NSNumber*)[self.laps objectAtIndex:indexPath.row] doubleValue];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Lap %d", indexPath.row + 1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%02.0f:%04.1f", minutes, seconds];
    
    return cell;
}

@end
