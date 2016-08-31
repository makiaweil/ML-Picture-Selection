//
//  UniqueColorCount.h
//  MyFirstApp
//
//  Created by WEIL on 29/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#ifndef __MyFirstApp__UniqueColorCount__
#define __MyFirstApp__UniqueColorCount__

#include <iostream>

#endif /* defined(__MyFirstApp__UniqueColorCount__) */

#include "FeatureComputer.h"
#include "Histogram1D.h"
#include <iostream>
#import <opencv2/opencv.hpp>

class UniqueColorCount : public FeatureComputer
{
public:
    UniqueColorCount() {}
    
    virtual std::vector<float> compute (const cv::Mat &mat, const std::string fileName) {
     //   std::printf(mat.type());
        cv::Mat amat;
        
        std::vector<float>measures;
        cv::Size size(100,100);
        cv::resize(mat,amat,size);
        int n=amat.rows;
        int m=amat.cols;
        
        //NSMutableArray * pixel = [NSMutableArray array];
        std::set<std::vector<int>>pixels;
        //unsigned char *input = (unsigned char*)(mat.data);
        
        for (int i=0; i<n; ++i) {
            for (int j=0; j<m; ++j) {
        //        NSMutableArray* pixelvalue=[NSMutableArray array];
                std::vector<int>pixelvalue;
                const cv::Vec3b& s = amat.at<cv::Vec3b>(i, j);
                
                for (int c = 0; c < 3; ++c) {
                     int pxl_val = (int)s.val[c];
                    pixelvalue.push_back(pxl_val);
                    //[pixelvalue addObject:[NSNumber numberWithInt: pxl_val]];
                    //[pixel addObject:pixelvalue];
                    
                }
                pixels.insert(pixelvalue);
            }
        }
       // std::set<std::vector<int>> distinct_container;
        //NSArray *uniquePixels = [[NSSet setWithArray:pixel] allObjects];
//        for(auto curr_int = pixels.begin(), end = pixels.end(); // no need to call v.end() multiple times
//            curr_int != end;
//            ++curr_int)
//        {
//            // std::set only allows single entries
//            // since that is what we want, we don't care that this fails
//            // if the second (or more) of the same value is attempted to
//            // be inserted.
//            distinct_container.insert(*curr_int);
//        }
//        
        float number= pixels.size();
    
    
        //int number=[uniquePixels count];
        
        
       // float uniqueRatio=(float)number/(n*m);
        
       // NSLog(@"%f",uniqueRatio);
        measures.push_back(number);
        return measures;
    }
virtual std::string name() { return "unique color count";}
};