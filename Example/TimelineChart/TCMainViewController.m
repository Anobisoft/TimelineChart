//
//  TCMainViewController.m
//  TimelineChart
//
//  Created by Stanislav Pletnev on 08/11/2017.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "TCMainViewController.h"
#import <TimelineChart/TimelineChart.h>

@interface TCMainViewController () <TCGraphSource>
@property (weak, nonatomic) IBOutlet TCView *graphView;
@property (weak, nonatomic) IBOutlet TCScaleView *scaleView;
@property (nonatomic) NSArray<TCPoint *> *randomArray;
@end

@implementation TCMainViewController {
    
}

@synthesize randomArray = _randomArray;

- (NSArray<TCPoint *> *)randomArray {
    if (!_randomArray) {
        NSMutableArray<TCPoint *> *tmpMutableArray = [NSMutableArray new];
        long i, iMax;
        for (i = (long)[NSDate date].timeIntervalSince1970, iMax = i + 10 + random() % 20; i < iMax; i++) {
            double value =  fabs((double)arc4random() / (double)UINT32_MAX) * 100;
            TCPoint *newPoint = [TCPoint pointWithTimestamp:i value:value];
            newPoint.timeviewAskew = i;
            [tmpMutableArray addObject:newPoint];
        }
        _randomArray = tmpMutableArray.copy;
    }
    return _randomArray;
}

- (TCGraph *)graphForView:(TCView *)graphView {
    TCGraph *graph = [TCGraph graphInRect:CGRectInset(graphView.bounds, 0, graphView.bounds.size.height / 10) withOriginPoints:self.randomArray mindx:30.0];
    self.scaleView.scale = graph.scale;
    self.scaleView.graphRect = graph.rect;
    return graph;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)refreshTap:(id)sender {
    static int i = 0;
    if (++i % 2) {
        [self.graphView clear];
        self.randomArray = nil;
    } else {
        [self.graphView drawGraphAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
