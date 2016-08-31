//
//  HueCount.h
//  MyFirstApp
//
//  Created by WEIL on 29/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__HueCount__
#define __MyFirstApp__HueCount__

#include "FeatureComputer.h"
#include "Histogram1D.h"
#include <iostream>
#import <opencv2/opencv.hpp>

class HueCount : public FeatureComputer
{
public:
    HueCount() {}
    
    virtual std::vector<float> compute (const cv::Mat &mat, const std::string fileName) {
        std::vector<float>measures;
        cv::Mat gray;
        cv::Mat hsv;
        cv::Mat t1;
        cv::Mat t2;
        cv::Mat col;
        cv::MatND hist_hsv;
        cv::vector<cv::Mat> channels;
        cv::cvtColor(mat, col, cv::COLOR_BGR2RGB)  ;
        
        cv::imwrite("/Users/weil/Desktop/"+fileName+"_mat.jpg", mat);
        
    
              cv::imwrite("/Users/weil/Desktop/"+fileName+"_col.jpg", col);
        
//        cv::threshold(gray, t1, 38.0,255.0,cv::THRESH_TOZERO);
        
//        cv::threshold(t1, t2, 243.0, 255.0, cv::THRESH_TOZERO_INV);
        
        
        
//        cv::cvtColor(t2, col, cv::COLOR_GRAY2RGB);
        
//        cv::cvtColor(col, hsv, cv::COLOR_RGB2HSV);
        cv::cvtColor(col, hsv, cv::COLOR_RGB2HSV);
       cv::imwrite("/Users/weil/Desktop/"+fileName+"_hsv.jpg", hsv);
        
        cv::split(hsv,channels);
       cv::imwrite("/Users/weil/Desktop/"+fileName+"_hueinit.jpg", channels[0]);
               cv::threshold(channels[0], t1, 26.0,179.0,cv::THRESH_TOZERO);
        cv::imwrite("/Users/weil/Desktop/"+fileName+"_t1.jpg", t1);
                cv::threshold(t1, t2, 170.0, 179.0, cv::THRESH_TOZERO_INV);
        cv::imwrite("/Users/weil/Desktop/"+fileName+"_t2.jpg", t2);

        
        for (int i=0; i<hsv.rows; ++i) {
            for (int j=0; j<hsv.cols; ++j) {
                int pixel = static_cast<int>(channels[1].at<uchar>(i,j));
                if (pixel<51) {
                    t2.at<uchar>(i,j)=0;
                }
            }
            
            }
       cv::imwrite("/Users/weil/Desktop/"+fileName+"_hue.jpg", t2);
            Histogram1D histo;
            histo.setNBins(20);
            histo.setRange(0.0, 179.0);
            hist_hsv=histo.getHistogram(t2);
            
            double maxVal=0;
            double minVal=0;
            cv::minMaxLoc(hist_hsv, &minVal,&maxVal,0,0);
            int q=0;
            for( int h = 0; h < 20; h++ ) {
                float binVal = hist_hsv.at<float>(h);
                
                
                if (binVal>0.05*maxVal) {
                    q+=1;
                    
                }
            }
            float mes=20-q;
            
        
        measures.push_back(mes);
        
    
    
    
    
    
    
        return measures;
    }








    
    virtual std::string name() { return "hue count"; }
    



};

#endif /* defined(__MyFirstApp__HueCount__) */
