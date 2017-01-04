//
//  ImageMatching.m
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

#import "ImageMatching.h"

@implementation ImageMatching

struct cardLocation {
    int y;
    int x;
    cv::Mat img;
};

// threshold image
- (cv::Mat) preprocess:(cv::Mat) img{
    cv::Mat gray;
    cv::cvtColor(img, gray, CV_BGR2GRAY);
    cv::Mat blur;
    cv::GaussianBlur(gray, blur, cv::Size( 5, 5), 2);
    cv::Mat thresh;
    cv::adaptiveThreshold(blur, thresh, 255, 1, 1, 11, 1);
    return thresh;
}

// compute difference between 2 images
- (double) imgdiff:(cv::Mat) img1 andImg2:(cv::Mat) img2 {
    img1 = [self preprocess:img1];
    img2 = [self preprocess:img2];
    cv::Mat blur1;
    cv::GaussianBlur(img1, blur1, cv::Size( 5, 5), 5);
    cv::Mat blur2;
    cv::GaussianBlur(img2, blur2, cv::Size( 5, 5), 5);
    cv::Mat diff;
    cv::absdiff(blur1, blur2, diff);
    
    cv::Mat diffblur;
    cv::GaussianBlur(diff, diffblur, cv::Size( 5, 5), 5);
    cv::Mat thresh;
    cv::threshold(diffblur, thresh, 200, 255, CV_THRESH_BINARY);
    
    // TODO: check channels
    return cv::sum(diff)[0];
}

// get contours and sort in descending order
- (std::vector<std::vector<cv::Point>>) getContours:(cv::Mat) img {
    cv::Mat gray;
    cv::cvtColor(img, gray, CV_BGR2GRAY);
    cv::Mat blur;
    cv::GaussianBlur(gray, blur, cv::Size(1, 1), 1000);
    cv::Mat thresh;
    cv::threshold(blur, thresh, 120, 255, CV_THRESH_BINARY);
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(thresh, contours, hierarchy, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    std::sort(contours.begin(), contours.end(), SortContourAreaDesc());
    return contours;
}


// find cards and arrange from top left to bottom right
- (std::vector<cv::Mat>) getCards:(cv::Mat) img {
    std::vector<cardLocation> locations;
    std::vector<std::vector<cv::Point>> contours = [self getContours:img];
    
    //error case : return if not enough contours found
    std::vector<cv::Mat> cards;
    
    if (contours.size() < 13) {
        return cards;
    }
    int start = 0;
    
    // handle if irregular large contour found at front
    int numcards = 12;
    if (cv::contourArea(contours.at(0)) > 1.5*cv::contourArea(contours.at(1))) {
        start = 1;
    }
    
    int i = start;
    for (auto & element : contours) {
        double peri = cv::arcLength(element, true);
        
        //fit rectangle to card contour
        std::vector<cv::Point> approx;
        cv::approxPolyDP(element, approx, 0.02*peri, true);
        
        // order points clockwise
        std::vector<cv::Point> ord = [self rectify:approx];
        cv::Mat ordered = cv::Mat(ord);
        
        // error case: make sure enough points are found in the ordered polygon
        if (ord.size() < 4) {
            return cards;
        }
        
        //transform to non-rotated rectangle
        std::vector<cv::Point> rect = {cv::Point(0.0, 0.0), cv::Point(0.0, 449.0), cv::Point(449.0, 449.0), cv::Point(449.0, 0.0)};
        cv::Mat h = cv::Mat(rect);
        
        // convert types
        cv::Mat orderedTyped;
        ordered.convertTo(orderedTyped, CV_32FC2);
        cv::Mat hTyped;
        h.convertTo(hTyped, CV_32FC2);

        cv::Mat transform = cv::getPerspectiveTransform(orderedTyped, hTyped);
        cv::Mat warp;
        cv::warpPerspective(img, warp, transform, cv::Size(450, 450));
        
        cardLocation loc;
        loc.img = warp;
        loc.x = ord[0].x;
        loc.y = ord[0].y;
        
        locations.push_back(loc);
        
        i++;
        if (i == numcards + start) {
            break;
        }
    }
    
    cards = [self orderByLocation:locations];
    
    return cards;
    
}

// order cards from top left to bottom right
- (std::vector<cv::Mat>) orderByLocation: (std::vector<cardLocation>) locations {
    std::vector<cardLocation> copyX;
    std::vector<cardLocation> copyY;
    for (auto & element : locations) {
        copyX.push_back(element);
        copyY.push_back(element);
    }
    
    std::sort(copyX.begin(), copyX.end(), SortLocX());
    std::sort(copyY.begin(), copyY.end(), SortLocY());
    
    std::vector<cardLocation> col1 = {copyX[0], copyX[1], copyX[2], copyX[3]};
    std::vector<cardLocation> col2 = {copyX[4], copyX[5], copyX[6], copyX[7]};
    std::vector<cardLocation> col3 = {copyX[8], copyX[9], copyX[10], copyX[11]};
    
    std::vector<cardLocation> row1 = {copyY[0], copyY[1], copyY[2]};
    std::vector<cardLocation> row2 = {copyY[3], copyY[4], copyY[5]};
    std::vector<cardLocation> row3 = {copyY[6], copyY[7], copyY[8]};
    std::vector<cardLocation> row4 = {copyY[9], copyY[10], copyY[11]};

    std::vector<cv::Mat> cards;
    cardLocation s;
    
    s = [self IntersectRowCol:row1 andCol:col1];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row1 andCol:col2];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row1 andCol:col3];
    cards.push_back(s.img);
    
    s = [self IntersectRowCol:row2 andCol:col1];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row2 andCol:col2];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row2 andCol:col3];
    cards.push_back(s.img);
    
    
    s = [self IntersectRowCol:row3 andCol:col1];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row3 andCol:col2];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row3 andCol:col3];
    cards.push_back(s.img);
    
    s = [self IntersectRowCol:row4 andCol:col1];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row4 andCol:col2];
    cards.push_back(s.img);
    s = [self IntersectRowCol:row4 andCol:col3];
    cards.push_back(s.img);
    
    return cards;
}

// sorting card location
struct SortLocX
{
    bool operator()( const cardLocation& lx, const cardLocation& rx ) const {
        return lx.x < rx.x;
    }
};

// sorting card location
struct SortLocY
{
    bool operator()( const cardLocation& lx, const cardLocation& rx ) const {
        return lx.y < rx.y;
    }
};

// find intersection
- (cardLocation) IntersectRowCol:(std::vector<cardLocation>) s1 andCol: (std::vector<cardLocation>) s2 {
    for (std::vector<cardLocation>::iterator it = s1.begin(); it != s1.end(); it++) {
        for (std::vector<cardLocation>::iterator it2 = s2.begin(); it2 != s2.end(); it2++) {
            if (it->x == it2->x && it->y == it2->y) {
                return *it;
            }
        }
    }
    cardLocation c;
    return c;
}

// put points in clockwise order
- (std::vector<cv::Point>) rectify:(std::vector<cv::Point>) h {
    std::vector<float> add;
    std::vector<float> diff;
    for (std::vector<cv::Point>::iterator it = h.begin(); it != h.end(); ++it) {
        add.push_back(it->x + it->y);
        diff.push_back(it->x - it->y);
    }
    
    // find max and min indices of add
    int add_max_index = 0;
    int add_max_value = add.at(0);
    int add_min_index = 0;
    int add_min_value = add.at(0);
    int i = 0;
    for (std::vector<float>::iterator it = add.begin(); it != add.end(); ++it) {
        if (*it > add_max_value) {
            add_max_value = *it;
            add_max_index = i;
        }
        if (*it < add_min_value) {
            add_min_value = *it;
            add_min_index = i;
        }
        i++;
    }
    
    // find max and min indices of diff
    int diff_max_index = 0;
    int diff_max_value = diff.at(0);
    int diff_min_index = 0;
    int diff_min_value = diff.at(0);
    i = 0;
    for (std::vector<float>::iterator it = diff.begin(); it != diff.end(); ++it) {
        if (*it > diff_max_value) {
            diff_max_value = *it;
            diff_max_index = i;
        }
        if (*it < diff_min_value) {
            diff_min_value = *it;
            diff_min_index = i;
        }
        i++;
    }
    
    int third = add_max_index;
    int first = add_min_index;
    int fourth = diff_max_index;
    int second = diff_min_index;
    
    std::vector<cv::Point> ordered = {h.at(first), h.at(second), h.at(third), h.at(fourth)};
    return ordered;
}

// sort by area
struct SortContourAreaDesc
{
    bool operator()( const std::vector<cv::Point>& lx, const std::vector<cv::Point>& rx ) const {
        return cv::contourArea(lx) > cv::contourArea(rx);
    }
};

// determine texture
- (char) getTexture:(cv::Mat) card andNumShapes:(int) n {
    std::vector<std::vector<cv::Point>> contours = [self getContours:card];
    //NSLog(@"Contours size: %lu\n", contours.size());
    
    if (contours.size() > 10) {
        //NSLog(@"Hatched");
        return 'h';
    }
    
    if (contours.size() >= 2*n + 1) {
        //NSLog(@"Open");
        return 'o';
    }
    //NSLog(@"Filled");
    return 'f';
    
}

// determine color
- (char) getColor:(cv::Mat) card {
    
    // convert to HSV
    cv::Mat hsv;
    cv::cvtColor(card, hsv, CV_RGB2HSV);
    
    // split out H channel
    std::vector<cv::Mat> hsvPlanes;
    cv::split(hsv, hsvPlanes);
    
    // build H histogram
    int histSize = 180;
    float range[] = {0, 180};
    const float* histRange = { range };
    bool uniform = true; bool accumulate = false;
    cv::Mat h_hist, s_hist, v_hist;
    calcHist( &hsvPlanes[0], 1, 0, cv::Mat(), h_hist, 1, &histSize, &histRange, uniform, accumulate );
    
    // compute elements in red/violet/green ranges
    //NSLog(@"Histogram: %d\n", hsv.channels());
    float green = 0;
    for (int i = 35; i < 75; i++) {
        green += h_hist.at<float>(i);
    }
    //NSLog(@"green: %f\n", green);
    float red = 0;
    for (int i = 160; i < 180; i++) {
        red += h_hist.at<float>(i);
    }
    //NSLog(@"red: %f\n", red);
    float violet = 0;
    for (int i = 130; i < 160; i++) {
        violet += h_hist.at<float>(i);
    }
    //NSLog(@"violet: %f\n", violet);
    
    if (red < 1000 && violet < 1000) {
        //NSLog(@"green\n");
        return 'g';
    }
    
    if (red > violet) {
        //NSLog(@"red\n");
        return 'r';
    }
    
    //NSLog(@"violet\n");
    return 'v';
}

@end
