//
//  Contrast.h
//  MyFirstApp
//
//  Created by WEIL on 22/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__Contrast__
#define __MyFirstApp__Contrast__

#include "FeatureComputer.h"
#include "Histogram1D.h"
#include <iostream>
#import <opencv2/opencv.hpp>

class Contrast : public FeatureComputer
{
public:
    Contrast() {}
    
    virtual std::vector<float> compute (const cv::Mat &mat, const std::string fileName) {
        cv::Mat equal;
        cv::Mat gray;
        cvtColor( mat, gray, CV_RGB2GRAY );
        equalizeHist( gray, equal );
        
        //cv::imwrite("/Users/weil/"+ fileName + "_equalized.jpg", equal);
        
        cv::MatND hist;
        cv::MatND hist_equal;
        
        Histogram1D histo;
        hist = histo.getHistogram(mat);
        //cv::imwrite("/Users/weil/"+ fileName + "_histo.jpg", histo.getHistogramImageFromHistogram(hist));
        
        
        hist_equal=Histogram1D().getHistogram(equal);
        //cv::imwrite("/Users/weil/"+ fileName + "_histo_equal.jpg", histo.getHistogramImageFromHistogram(hist_equal));
//        double maxVal=0.0;
//		double minVal=0.0;
//		cv::minMaxLoc(hist, &minVal, &maxVal, 0, 0);
        normalize ( hist, hist, 0, 1, cv::NORM_MINMAX, -1, cv::Mat() );
        //cv::imwrite("/Users/weil/"+ fileName + "_histo_norm.jpg", histo.getHistogramImageFromHistogram(hist));
        normalize ( hist_equal, hist_equal, 0, 1, cv::NORM_MINMAX, -1, cv::Mat() );
        //cv::imwrite("/Users/weil/"+ fileName + "_histo_equal_norm.jpg", histo.getHistogramImageFromHistogram(hist_equal));
        

        std::vector<float> res;
        //float contrast = ((float)maxVal-(float)minVal);
        
        
            float comp = compareHist( hist, hist_equal, 3 );
            
            
            res.push_back(comp);
         //   res.push_back(contrast);
        return res;
    }

    virtual std::string name() { return "contrast"; }

    
};
#endif /* defined(__MyFirstApp__Contrast__) */
