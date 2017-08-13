//
//  ViewController.m
//  GCD
//
//  Created by cjs on 2017/8/13.
//  Copyright © 2017年 dave. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *testbutton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.testbutton];
    
    //串行、并行、队列、同步、异步、线程
}

- (void)viewDidLayoutSubviews {
    self.testbutton.frame = CGRectMake(40, 100, 100, 40);
}

- (void)testButtonTaped {
    //    [self syncSerialQueue];
    [self asyncSerialQueue];
    //    [self syncConcurrentQueue];
    //    [self asyncConcurrentQueue];
    //    [self asyncGroupByBlock];
    //    [self asyncGroupBySelfManage];
    //    [self dispatchBarrierAsync];
    //    [self asyncSemaphore];
}

#pragma mark - sync async serial concurrent

- (void)syncSerialQueue {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.dave.lan.serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"test1");
    dispatch_sync(serialQueue, ^{
        sleep(2);
        NSLog(@"同步串行1");
    });
    NSLog(@"test2");
    dispatch_sync(serialQueue, ^{
        sleep(2);
        NSLog(@"同步串行2");
    });
    NSLog(@"test3");
    dispatch_sync(serialQueue, ^{
        sleep(2);
        NSLog(@"同步串行3");
    });
    NSLog(@"test4");
}

- (void)asyncSerialQueue {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.dave.lan.serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"test1");
    dispatch_async(serialQueue, ^{
        sleep(2);
        NSLog(@"异步串行task1");
    });
    NSLog(@"test2");
    dispatch_async(serialQueue, ^{
        sleep(2);
        NSLog(@"异步串行task2");
    });
    NSLog(@"test3");
    dispatch_async(serialQueue, ^{
        sleep(2);
        NSLog(@"异步串行task3");
    });
    NSLog(@"test4");
}

- (void)syncConcurrentQueue {
    dispatch_queue_t queue = dispatch_queue_create("com.dave.lan.concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"test1");
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"同步并行1");
    });
    NSLog(@"test2");
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"同步并行2");
    });
    NSLog(@"test3");
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"同步并行3");
    });
    NSLog(@"test4");
}

- (void)asyncConcurrentQueue {
    dispatch_queue_t queue = dispatch_queue_create("com.dave.lan.concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"test1");
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"异步并行1");
    });
    NSLog(@"test2");
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"异步并行2");
    });
    NSLog(@"test3");
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"异步并行3");
    });
    NSLog(@"test4");
}

#pragma mark - dispatch_group

- (void)asyncGroupByBlock {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.dave.lan.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"task begin");
    dispatch_group_async(group, concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 1 in concurrent queue");
    });
    dispatch_group_async(group, concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 2 in concurrent queue");
    });
    dispatch_group_async(group, globalQueue, ^{
        sleep(3);
        NSLog(@"task 3 in global queue");
    });
    dispatch_async(globalQueue, ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);            //等待group执行完毕或者设置的超时时间到了，才会往下执行！相当于同步阻塞
        NSLog(@"task 4 not group async");
    });
    dispatch_group_notify(group, concurrentQueue, ^{
        NSLog(@"group task completed");
    });
}

- (void)asyncGroupBySelfManage {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.dave.lan.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"task begin");
    
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
        sleep(3);
        NSLog(@"task 1");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
        sleep(1);
        dispatch_async(concurrentQueue, ^{
            sleep(3);
            NSLog(@"task 2");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_async(globalQueue, ^{
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));    //设置超时时间为10秒
        NSLog(@"task 3 not group async");
    });
    
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"group task completed");
    });
}

#pragma mark - dispatch_barrier
//这里的并发线程只能用自定义的才有效果，global的不行

- (void)dispatchBarrierAsync {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.dave.lan.concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"task begin");
    dispatch_async(concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 1");
    });
    dispatch_async(concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 2");
    });
    dispatch_async(concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 3");
    });
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"task 4 barrier");
    });
    dispatch_async(concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 5");
    });
    dispatch_async(concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 6");
    });
    dispatch_async(concurrentQueue, ^{
        sleep(3);
        NSLog(@"task 7");
    });
    NSLog(@"没有同步");
}

#pragma mark - dispatch_semaphore

- (void)asyncSemaphore {
    dispatch_queue_t queue = dispatch_queue_create("com.dave.lan.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(queue, ^{
        sleep(3);
        NSLog(@"task");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(queue, ^{
        long result = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
        //        long result = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
        if (0 == result) {
            NSLog(@"信号量不再为0，不再等待");
        }else {
            NSLog(@"超时，不再等待");
        }
    });
}

#pragma mark - getter

- (UIButton *)testbutton {
    if (!_testbutton) {
        _testbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_testbutton setTitle:@"测试按钮" forState:UIControlStateNormal];
        [_testbutton setBackgroundColor:[UIColor grayColor]];
        [_testbutton addTarget:self action:@selector(testButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testbutton;
}
@end
