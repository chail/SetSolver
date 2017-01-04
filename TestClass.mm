//
//  TestClass.m
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "TestClass.h"

@implementation TestClass

- (void)sampleMethod{
    NSLog(@"Hello, World! \n");
}

/* method returning the max between two numbers */
- (int)max:(int)num1 andNum2:(int)num2{
    /* local variable declaration */
    int result;
    
    if (num1 > num2)
    {
        result = num1;
    }
    else
    {
        result = num2;
    }
    
    return result; 
}

- (int *) testArray:(int) len {
    int arr [len];
    for (int i = 0; i < len; i++) {
        arr[i] = 2*i;
    }
    return arr;
}

- (std::vector<int>) testVector {
    std::vector<int> second (4,100);
    return second;
}

@end
