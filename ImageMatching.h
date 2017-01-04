//
//  ImageMatching.h
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>

@interface ImageMatching : NSObject

- (cv::Mat) preprocess:(cv::Mat) img;

- (double) imgdiff:(cv::Mat) img1 andImg2:(cv::Mat) img2;

- (std::vector<cv::Mat>) getCards:(cv::Mat) img;

- (char) getTexture:(cv::Mat) card andNumShapes:(int) n ;

- (char) getColor:(cv::Mat) card;

@end
