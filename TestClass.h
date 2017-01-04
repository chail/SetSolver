//
//  TestClass.h
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>

@interface TestClass : NSObject

- (void)sampleMethod;

- (int)max:(int)num1 andNum2:(int)num2;

- (int *) testArray:(int) len;

- (std::vector<int>) testVector;

@end
