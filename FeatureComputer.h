//
//  FeatureComputer.h
//  MyFirstApp
//
//  Created by WEIL on 22/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__FeatureComputer__
#define __MyFirstApp__FeatureComputer__

#include <iostream>
#import <opencv2/opencv.hpp>


class FeatureComputer
{
public:
    
    FeatureComputer() {}
    virtual ~FeatureComputer() {}
    
    virtual std::vector<float> compute(const cv::Mat &mat, std::string fileName)=0;
    virtual std::string name()=0;
    
    
};

#endif /* defined(__MyFirstApp__FeatureComputer__) */
