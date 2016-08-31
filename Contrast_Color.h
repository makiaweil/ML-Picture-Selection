//
//  Contrast_Color.h
//  MyFirstApp
//
//  Created by WEIL on 28/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__Contrast_Color__
#define __MyFirstApp__Contrast_Color__

#include "FeatureComputer.h"
#include "Histogram1D.h"
#include <iostream>
#import <opencv2/opencv.hpp>

class Contrast_Color : public FeatureComputer
{
public:
    Contrast_Color() {}
    
    virtual std::vector<float> compute (const cv::Mat &mat, const std::string fileName) {
        cv::Mat equal;
        cv::Mat color;
        std::vector<float> res;
        std::vector<cv::Mat> channels;
        cvtColor( mat, color, CV_BGR2HSV );
        cv::split(color,channels);
        
        
        
        //equalizeHist( gray, equal );
        
        //cv::imwrite("/Users/weil/"+ fileName + "_equalized.jpg", equal);
        
        cv::MatND hist;
        Histogram1D histo;
        histo.setChannel(1);
        histo.setNBins(20);
        hist=histo.getHistogram(color);
        double maxVal=0;
        double minVal=0;
        cv::minMaxLoc(hist, &minVal,&maxVal,0,0);
        
        float ratio=minVal/maxVal;
        res.push_back(ratio);
        return res;
    
    
    
    
    }
    
    virtual std::string name() { return "contrast color"; }
    
    
};
#endif /* defined(__MyFirstApp__Contrast_Color__) */
