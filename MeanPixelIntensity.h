//
//  MeanPixelIntensity.h
//  MyFirstApp
//
//  Created by Michael Weil on 28/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__MeanPixelIntensity__
#define __MyFirstApp__MeanPixelIntensity__

#include "FeatureComputer.h"
#include "Histogram1D.h"
#include <iostream>
#import <opencv2/opencv.hpp>


class MeanPixelIntensity : public FeatureComputer
{
public:
    MeanPixelIntensity() {}
    
    virtual std::vector<float> compute (const cv::Mat &mat, const std::string fileName) {
        cv::Mat gray;
        std::vector<float>measures;
        cvtColor( mat, gray, CV_RGB2GRAY );
        int mean=0;
        int n=gray.rows;
        int m=gray.cols;
        for (int i=0; i<n; i++) {
            for (int j=0; j<m; j++) {
                int intensity=static_cast<int>(gray.at<uchar>(i,j));
        mean+=intensity;
            }
        }
        
        float result=mean/(n*m);
        measures.push_back(result);
        return measures;
        
        
    
    
    
    
    }
     virtual std::string name() { return "mean pixel intensity"; }
    
};



#endif /* defined(__MyFirstApp__MeanPixelIntensity__) */
