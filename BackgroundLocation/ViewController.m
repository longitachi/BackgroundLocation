//
//  ViewController.m
//  BackgroundLocation
//
//  Created by long on 2017/8/22.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ViewController.h"
#import "LocationTool.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifys:) name:@"locationSuc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifys:) name:@"uploadSuc" object:nil];
}

- (void)notifys:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = [self.textView.text stringByAppendingFormat:@"\n\n%@: %@",  [self getDate], notify.userInfo[@"message"]];
    });
}

- (NSString *)getDate
{
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    fm.dateFormat = @"HH:mm:ss.SSS";
    return [fm stringFromDate:[NSDate date]];
}

- (IBAction)startLocation:(id)sender {
    [[LocationTool shareInstance] setUploadInterval:3];
    [[LocationTool shareInstance] startLocation];
}

- (IBAction)stopLocation:(id)sender {
    [[LocationTool shareInstance] stopLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
