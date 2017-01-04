//
//  OpenCVWrapper.m
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"
#import "TestClass.h"
#import "ImageMatching.h"


@implementation OpenCVWrapper

struct setCard {
    char shape;
    int num;
    cv::Mat img;
};

int numTrainingCards = 12;
std::vector<setCard> cards;
ImageMatching *imageMatcher = [[ImageMatching alloc]init];

std::vector<cv::Mat> testImgs;

+(NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}


+(std::vector<cv::Mat>) detectCards:(UIImage *) image {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    cv::Mat grayMat = [imageMatcher preprocess:imageMat];
    std::vector<cv::Mat> cardImgs = [imageMatcher getCards:imageMat];
    return cardImgs;
}


void split(const std::string &s, char delim, std::vector<std::string> &elems) {
    std::stringstream ss;
    ss.str(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
}

+(void) train:(UIImage *) image1 andImg2: (UIImage *) image2{
    std::vector<cv::Mat> cardImgs = [self detectCards:image1];
    std::vector<cv::Mat> cardImgs2 = [self detectCards:image2];
    
    std::string labels1 = "3d 2d 3s 3d 3s 1o 2d 3o 3o 1o 1o 2d";
    std::string labels2 = "1s 1o 3o 2o 2s 3d 1d 3o 2s 3o 3s 2s";
//    std::vector<int> keptIndices1 = {0, 1, 2, 3, 4};
//    std::vector<int> keptIndices2 = {2, 3, 6, 10};
    
    std::vector<std::string> elems1;
    split(labels1, ' ', elems1);
    std::vector<std::string> elems2;
    split(labels2, ' ', elems2);
    
    for (int i = 0; i < numTrainingCards; i++) {
        setCard s;
        std::string word = elems1.at(i);
        s.img = cardImgs.at(i);
        s.num = word.at(0) - '0';
        s.shape = word.at(1);
        cards.push_back(s);
    }
    
    for (int i = 0; i < numTrainingCards; i++) {
        setCard s;
        std::string word = elems2.at(i);
        s.img = cardImgs2.at(i);
        s.num = word.at(0) - '0';
        s.shape = word.at(1);
        cards.push_back(s);
    }
}

+(UIImage *) getCardAtIndex:(int) idx {
    cv::Mat card = testImgs.at(idx);
    return MatToUIImage(card);
}

+(NSString *) test:(UIImage *) image {
    NSMutableString *string = [NSMutableString stringWithString:@""];
    
    testImgs = [self detectCards:image];
    
    //NSLog(@"size %lu\n", testImgs.size());
    if (testImgs.size() == 0) {
        return @"";
    }
    
    for (auto & card : testImgs) {
        double mindiffvalue;
        try {
            mindiffvalue = [imageMatcher imgdiff:card andImg2:cards[0].img];
        } catch (...) {
            return @"";
        }
        char mindiffshape = cards[0].shape;
        int mindiffnum = cards[0].num;
        
        for (auto & trainCard : cards) {
            double diff = [imageMatcher imgdiff:card andImg2:trainCard.img];
            if (diff < mindiffvalue) {
                mindiffvalue = diff;
                mindiffshape = trainCard.shape;
                mindiffnum = trainCard.num;
            }
        }
        
//        NSLog(@"num: %d\n", mindiffnum);
//        NSLog(@"shape: %c\n", mindiffshape);
        char c = [imageMatcher getColor:card];
        char t = [imageMatcher getTexture:card andNumShapes:mindiffnum];
//        NSLog(@"color: %c\n", c);
//        NSLog(@"texture: %c\n", t);
        
        NSString *str_card = [NSString stringWithFormat:@"%c%c%c%c ", mindiffnum + '0', mindiffshape, c, t];
        [string appendString:str_card];
    }
    return string;
}

@end
