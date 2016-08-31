//
//  BlurMetrics.h
//  MyFirstApp
//
//  Created by WEIL on 28/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__Blur__
#define __MyFirstApp__Blur__

#include <iostream>
#include "FeatureComputer.h"
#import <opencv2/opencv.hpp>
class BlurMetrics {
    
    public :
    
    // OpenCV port of 'LAPM' algorithm (Nayar89)
    double modifiedLaplacian(const cv::Mat& src)
    {
        cv::Mat M = (cv::Mat_<double>(3, 1) << -1, 2, -1);
        cv::Mat G = cv::getGaussianKernel(3, -1, CV_64F);
        
        cv::Mat Lx;
        cv::sepFilter2D(src, Lx, CV_64F, M, G);
        
        cv::Mat Ly;
        cv::sepFilter2D(src, Ly, CV_64F, G, M);
        
        cv::Mat FM = cv::abs(Lx) + cv::abs(Ly);
        
        double focusMeasure = cv::mean(FM).val[0];
        return focusMeasure;
    }
    
    // OpenCV port of 'LAPV' algorithm (Pech2000)
    double varianceOfLaplacian(const cv::Mat& src)
    {
        cv::Mat lap;
        cv::Laplacian(src, lap, CV_64F);
        
        cv::Scalar mu, sigma;
        cv::meanStdDev(lap, mu, sigma);
        
        double focusMeasure = sigma.val[0]*sigma.val[0];
        return focusMeasure;
    }
    
    // OpenCV port of 'TENG' algorithm (Krotkov86)
    double tenengrad(const cv::Mat& src, int ksize)
    {
        cv::Mat Gx, Gy;
        cv::Sobel(src, Gx, CV_64F, 1, 0, ksize);
        cv::Sobel(src, Gy, CV_64F, 0, 1, ksize);
        
        cv::Mat FM = Gx.mul(Gx) + Gy.mul(Gy);
        
        double focusMeasure = cv::mean(FM).val[0];
        return focusMeasure;
    }
    
    // OpenCV port of 'GLVN' algorithm (Santos97)
    double normalizedGraylevelVariance(const cv::Mat& src)
    {
        cv::Scalar mu, sigma;
        cv::meanStdDev(src, mu, sigma);
        
        double focusMeasure = (sigma.val[0]*sigma.val[0]) / mu.val[0];
        return focusMeasure;
    }
    
};








#endif /* defined(__MyFirstApp__BlurMetrics__) */
