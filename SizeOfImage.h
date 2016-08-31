//
//  SizeOfImage.h
//  MyFirstApp
//
//  Created by WEIL on 28/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__SizeOfImage__
#define __MyFirstApp__SizeOfImage__

#include "FeatureComputer.h"
#include "Histogram1D.h"
#include <iostream>
#import <opencv2/opencv.hpp>


class SizeOfImage : public FeatureComputer
{
public:
    SizeOfImage() {}
    
    virtual std::vector<float> compute (const cv::Mat &mat, const std::string fileName) {
        std::vector<float> measures;
        float n=mat.rows;
        float m=mat.cols;
        float s=n+m;
        float shape=n/m;
        measures.push_back(s);
        measures.push_back(shape);
        return measures;
        
        
    }
    
    
    
    
    
    virtual std::string name() { return "size of image"; }
};


#endif /* defined(__MyFirstApp__SizeOfImage__) */
