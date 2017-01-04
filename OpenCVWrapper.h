//
//  OpenCVWrapper.h
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface OpenCVWrapper : NSObject

// Function to get OpenCV Version
+(NSString *) openCVVersionString;

+(void) train:(UIImage *) image1 andImg2: (UIImage *) image2;

+(UIImage *) getCardAtIndex:(int) idx;

+(NSString *) test:(UIImage *) image;

@end
