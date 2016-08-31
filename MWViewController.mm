//
//  MWViewController.m
//  MyFirstApp
//
//  Created by WEIL on 16/07/2014.
//  Copyright (c) 2014 MichaelWeil. All rights reserved.
//

#import "MWViewController.h"
#include "Contrast.h"
#include "SizeOfImage.h"
#include "Contrast_Color.h"
#include "MeanPixelIntensity.h"
#include "UniqueColorCount.h"
#import <opencv2/opencv.hpp>
#include <fstream>
#include "HueCount.h"

@interface MWViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MWViewController

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}







- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)Color:(id)sender {
    std::vector<std::string> Path={"/Users/weil/Desktop/ContrastFort","/Users/weil/Desktop/ContrastFaible"};
    for (int i=0; i<2; i++) {
        
    
    
    NSString *NSPath = [NSString stringWithUTF8String:Path[i].c_str()];
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSPath error:NULL];
    
    for(id obj in dirs){
        
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        
        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
            
            
            
            NSString *filePath = [NSPath stringByAppendingPathComponent:filename];
            std::string stdFilePath([filePath UTF8String]);
            std::string fileName = stdFilePath.substr( stdFilePath.find_last_of( '/' ) +1,stdFilePath.size()-5- stdFilePath.find_last_of( '/' ) );
    
            
            cv::Mat src = cv::imread(stdFilePath);
            cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
            
            
            Contrast_Color fc = *new Contrast_Color();
            std::vector<float> measure=fc.compute(src,fileName);
            std::fstream Validation("/Users/weil/Desktop/Color.csv");
            Validation.seekp(0,std::ios::end);
            Validation <<measure[0]<<","<<measure[1]<<","<<measure[2]<<","<<fileName <<std::endl;
            Validation.close();
            
            
        }
    }
    
    }
    
    
}

- (std::map<std::string,std::vector<float>>)getMeasure: (std::string) filePath NameOftheFile: (std::string) fileName   {
    
    
    cv::Mat src = cv::imread(filePath);
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    //cv::cvtColor(src, src, cv::COLOR_GRAY2RGB);
    
    
    //cv::imwrite("/Users/weil/desktop/"+fileName+".jpg", src);
    std::map<std::string, std::vector<float>>  measure;
    
    std::vector<FeatureComputer*>  fc;
    fc.push_back(new Contrast());
    fc.push_back(new SizeOfImage());
    fc.push_back(new MeanPixelIntensity());
    fc.push_back(new Contrast_Color());
    fc.push_back(new UniqueColorCount());
    fc.push_back(new HueCount());
    for (int i =0; i<fc.size(); i++) {
        
    
    std::string nom= fc[i]->name();
    
    measure[nom]=fc[i]->compute(src, fileName);
    }
    return measure;
    
    
    
   
    
    
        }

- (IBAction)CrossValidation:(id)sender {
    int frac=16;
    std::vector<std::string> paths = {"/Users/weil/Desktop/Dataset/Good","/Users/weil/Desktop/Dataset/Trash"};
    NSString *fileDirectory = @"/Users/weil/Desktop/CrossValidation";
    
    std::vector<float>LabelType={1.0,0.0};
    std::vector<float>LabelTypes;
    std::vector<std::string>PathsToDatasets;
    
    for (int i =1; i<=frac; i++) {
        std::vector<std::string> dst;
        for (int k =0; k<2; k++) {
            
            
            
            NSString *pathToCurrentDataSet = [NSString stringWithUTF8String:paths[k].c_str()];
            NSString *classtype = [pathToCurrentDataSet lastPathComponent];
            
            NSString* integer =[NSString stringWithFormat:@"%d",i];
            NSString* FileClass = [fileDirectory stringByAppendingString:[@"/" stringByAppendingString:[integer stringByAppendingString:  [@"/"  stringByAppendingString:classtype]]]];
            
            
            
            
            [[NSFileManager defaultManager] createDirectoryAtPath:FileClass withIntermediateDirectories:YES attributes:nil error:nil];
            std::string stdfileclass([FileClass UTF8String]);
            PathsToDatasets.push_back(stdfileclass);
            dst.push_back(stdfileclass);
            if (i!=frac) {
                
                
                LabelTypes.push_back(LabelType[k]);
            }
            
            
        }
        if (i!=frac) {
            [self RandomSort:paths Destination:dst Fraction:frac+1-i];
        }
        else {
            [self Tidy:paths Destination:dst];
            
            
        }
        
        
        
    }
    
   // LabelTypes.pop_back();
    //LabelTypes.pop_back();
    for (int j=1; j<=frac; j++) {
        std::vector<std::string>PathsForValidation;
        PathsForValidation.push_back(PathsToDatasets[2*(j-1)]);
        PathsForValidation.push_back(PathsToDatasets[2*(j-1)+1]);
        std::vector<std::string>PathsForTraining=PathsToDatasets;
        PathsForTraining.erase(PathsForTraining.begin()+2*(j-1), PathsForTraining.begin()+2*(j-1)+2);
        std::vector<std::vector<float>> trainingData;
        std::vector<float> labels;
        [self Train:PathsForTraining Data:trainingData Labels:labels Labeltype:LabelTypes];
        std::vector<std::vector<float>>precisionAndrecall =  [self Validate:PathsForValidation LabelType:{1,0}];
        std::fstream Validation("/Users/weil/Desktop/CrossValidation/Validation.csv");
        Validation.seekp(0,std::ios::end);
        Validation <<precisionAndrecall[0][0]<<","<<precisionAndrecall[0][1]<<","<<precisionAndrecall[1][0]<<","<<precisionAndrecall[1][1] <<std::endl;
        Validation.close();
        
        
    }
    for (int k =0; k<2; k++) {
        
        
        for (int n=1; n<=frac; n++) {
            
            [self Tidy:{PathsToDatasets[2*(n-1)+k]} Destination:{paths[k]}];
            
            
        }
        
        
        
    }
    
    
    
    
}

-(int)Predict:(std::string)stdFilePath{
    std::string fileName = stdFilePath.substr( stdFilePath.find_last_of( '/' ) +1,stdFilePath.size()-5- stdFilePath.find_last_of( '/' ) );
    std::map<std::string,std::vector<float>> measure = [self getMeasure:stdFilePath NameOftheFile:fileName];
    std::vector<float>measureVector;
    measureVector.reserve(2)
    ;
//    measureVector.insert(measureVector.end(),measure["contrast"].begin(), measure["contrast"].end());
//    measureVector.insert(measureVector.end(),measure["size of image"].begin(), measure["size of image"].end());
//    measureVector.insert(measureVector.end(),measure["mean pixel intensity"].begin(), measure["mean pixel intensity"].end());
//    measureVector.insert(measureVector.end(),measure["contrast color"].begin(), measure["contrast color"].end());
//    measureVector.insert(measureVector.end(),measure["unique color count"].begin(), measure["unique color count"].end());
     measureVector.insert(measureVector.end(),measure["hue count"].begin(), measure["hue count"].end());
    int metricSize=measureVector.size();
    float mes[metricSize];
    for (int i =0; i<metricSize; i++) {
        mes[i]=measureVector[i];
    }
    cv::Mat samplemat(1,metricSize,CV_32FC1,mes);
    CvSVM svm;
    svm.load("/Users/weil/Desktop/Dataset/svm.xml");
    float response = svm.predict(samplemat);
    NSFileManager *fichier = [NSFileManager defaultManager];
    NSString *Name = [NSString stringWithUTF8String:fileName.c_str()];
    NSString *source = [NSString stringWithUTF8String:stdFilePath.c_str()];
   
    
    if (response==1) {
         NSString *destination =[@"/Users/weil/Desktop/SmartGood/" stringByAppendingString:[Name stringByAppendingString:@".jpg"]] ;
        
                if ([fichier fileExistsAtPath:source]){
            [fichier copyItemAtPath:source toPath:destination error:nil];
        
                }
    }
    
                else{
                    NSString *destination =[@"/Users/weil/Desktop/SmartTrash/" stringByAppendingString:[Name stringByAppendingString:@".jpg"]] ;
                    
                    if ([fichier fileExistsAtPath:source]){
                        [fichier copyItemAtPath:source toPath:destination error:nil];
                        
                    }

                }
        
        
        
    
    
    
    return response;
}
- (IBAction)predire:(id)sender {
    
    
    NSString *filePath = @"/Users/weil/Desktop/ContrastFaible/image19.jpg";
   
    
            
    std::string stdFilePath([filePath UTF8String]);
    int response=[self Predict:stdFilePath];
    NSLog(@"%d",response);

    
}
- (IBAction)randomSort:(id)sender {
std::vector<std::string> pathToDataSets {"/Users/weil/Desktop/Dataset/Good","/Users/weil/Desktop/Dataset/Trash"};
    std::vector<std::string> dst={"/Users/weil/Desktop/Dataset/10/Good","/Users/weil/Desktop/Dataset/10/Trash"};
    [self RandomSort:pathToDataSets Destination:dst Fraction:2];
    
    NSLog(@"Fini");

}


- (IBAction)tidy:(id)sender {
    
    
    std::vector<std::string> dst {"/Users/weil/Desktop/Dataset/Good","/Users/weil/Desktop/Dataset/Trash"};
    std::vector<std::string> pathToDataSets={"/Users/weil/Desktop/Dataset/10/Good","/Users/weil/Desktop/Dataset/10/Trash"};
    [self Tidy:pathToDataSets Destination:dst];
    
    
    
    
     NSLog(@"Fini");
    
    
    
}



-(void) Tidy :(std::vector<std::string>)pathToDataSets Destination:(std::vector<std::string>)dst{
    
    for (int i=0; i<pathToDataSets.size();i++ ) {
        NSString *currentDst =[NSString stringWithUTF8String:dst[i].c_str()];
        NSString *pathToCurrentDataSet = [NSString stringWithUTF8String:pathToDataSets[i].c_str()];
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToCurrentDataSet error:NULL];
        for(id obj in dirs){
            
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            
            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                
                NSFileManager *fichier = [NSFileManager defaultManager];
                NSString *source = [pathToCurrentDataSet stringByAppendingPathComponent:filename];
                NSString *destination =[currentDst stringByAppendingPathComponent:filename] ;
               
                if ([fichier fileExistsAtPath:source]){
                    
                    [fichier moveItemAtPath:source toPath:destination error:nil];
                }

            
            
            
            }
        }
            }




}
-(void) RandomSort :(std::vector<std::string>)pathToDataSets Destination:(std::vector<std::string>)dst Fraction:(int)frac{
    for (int i=0; i<pathToDataSets.size();i++ ) {
        NSString *currentDst =[NSString stringWithUTF8String:dst[i].c_str()];
        NSString *pathToCurrentDataSet = [NSString stringWithUTF8String:pathToDataSets[i].c_str()];
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToCurrentDataSet error:NULL];
        int count = [dirs count];
        int numberOfSampleFiles=count/frac;
       NSMutableArray *files=[NSMutableArray array];
        for(id obj in dirs){
            
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            
            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                
                
                
                
                [files addObject:filename];
                
            }
            
        
    }
        for (int k = 0; k<numberOfSampleFiles; k++) {
            int randomInt=rand() % [files count];
            NSString *fileToPick= [files objectAtIndex:randomInt];
            [files removeObjectAtIndex:randomInt];
            
            
            
            NSFileManager *fichier = [NSFileManager defaultManager];
            NSString *source = [pathToCurrentDataSet stringByAppendingPathComponent:fileToPick];
            NSString *destination =[currentDst stringByAppendingPathComponent:fileToPick] ;
            if ([fichier fileExistsAtPath:source]){
                                [fichier moveItemAtPath:source toPath:destination error:nil];
            }
            
            
            
            
        }
    
    
    
    
    }
    
    
}
-(void) Train: (std::vector<std::string>)pathToDataSets Data:(std::vector<std::vector<float>>) trainingData Labels:(std::vector<float>) labels Labeltype :(std::vector<float>) labelType {
    NSLog(@"Training in process...");
    
    for (int i=0; i<pathToDataSets.size();i++ ) {
        
        NSString *pathToCurrentDataSet = [NSString stringWithUTF8String:pathToDataSets[i].c_str()];
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToCurrentDataSet error:NULL];
        
        for(id obj in dirs){
            
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            
            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
               
               
                
                NSString *filePath = [pathToCurrentDataSet stringByAppendingPathComponent:filename];
                std::string stdFilePath([filePath UTF8String]);
                std::string fileName = stdFilePath.substr( stdFilePath.find_last_of( '/' ) +1,stdFilePath.size()-5- stdFilePath.find_last_of( '/' ) );
                // NSLog(@"%@",filePath);
               
                std::map<std::string,std::vector<float>> measure = [self getMeasure:stdFilePath NameOftheFile:fileName];
                std::vector<float>measureVector;
                measureVector.reserve(2)
                ;
//                measureVector.insert(measureVector.end(),measure["contrast"].begin(), measure["contrast"].end());
//                 measureVector.insert(measureVector.end(),measure["size of image"].begin(), measure["size of image"].end());
//                measureVector.insert(measureVector.end(),measure["mean pixel intensity"].begin(), measure["mean pixel intensity"].end());
//                measureVector.insert(measureVector.end(),measure["contrast color"].begin(), measure["contrast color"].end());
//                measureVector.insert(measureVector.end(),measure["unique color count"].begin(), measure["unique color count"].end());
                measureVector.insert(measureVector.end(),measure["hue count"].begin(), measure["hue count"].end());
                
                trainingData.push_back(measureVector);
                labels.push_back(labelType[i]);
                std::fstream sizemeasures("/Users/weil/Desktop/Metrics/hue count.csv");
                sizemeasures.seekp(0,std::ios::end);
                sizemeasures <<measureVector[0]<<","<<labelType[i] <<std::endl;
                sizemeasures.close();
            }
        }
    }
    
    int s=labels.size();
    int metricSize=trainingData[0].size();
    float trainingDataMatrix[s][metricSize];
    float labelsMatrix[s];
    
    
    for (int i =0;i<s;i++){
        labelsMatrix[i]=labels[i];
        for (int j=0; j<metricSize; j++) {
            
        
        trainingDataMatrix[i][j]=trainingData[i][j];
    }
    }
    
    cv::Mat labelsMat(s, 1, CV_32FC1, &labelsMatrix);
    cv::Mat trainingDataMat(s, metricSize, CV_32FC1, &trainingDataMatrix);
    CvSVMParams params;
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    CvSVM SVM;
    SVM.train_auto(trainingDataMat, labelsMat, cv::Mat(), cv::Mat(), params);
    SVM.save("/Users/weil/Desktop/Dataset/svm.xml");
    NSLog(@"Training Done");
}

-(std::vector<std::vector<float>>) Validate: (std::vector<std::string>)pathToDataSets LabelType:(std::vector<int>) labelType{

    
       int numberFiles[2]={0};
    int numberGood[2]={0};
    int numberSVMFiles[2]={0};
    std::vector<std::vector<float>> precisionAndrecall={{0.0,0.0},{0.0,0.0}};
    for (int i=0; i<pathToDataSets.size(); i++) {
        
        
        NSString *pathToCurrentDataSet = [NSString stringWithUTF8String:pathToDataSets[i].c_str()];
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToCurrentDataSet error:NULL];
        for(id obj in dirs){
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            
            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                numberFiles[i]+=1;
                NSString *filePath = [pathToCurrentDataSet stringByAppendingPathComponent:filename];
                std::string stdFilePath([filePath UTF8String]);
                int response=[self Predict:stdFilePath];
                
                if(response==labelType[i]){
                    numberGood[i]+=1;
                    numberSVMFiles[i]+=1;
                    
                }
                else{
                    numberSVMFiles[(i+1)%2 ]+=1;
                    
                }
            }
            
            
            
            
        }
        
        
        
    }

    
    for (int k=0; k<2; k++) {
        
        precisionAndrecall[k][0]=(float)numberGood[k]/(float)numberSVMFiles[k];
        precisionAndrecall[k][1]=(float)numberGood[k]/(float)numberFiles[k];
       
        
    }
    
    return precisionAndrecall;
    
    
}


- (IBAction)valider:(id)sender {
    NSLog(@"Validation Processing...");
    
    std::vector<std::string> pathToDataSets {"/Users/weil/Desktop/Dataset/10/Good","/Users/weil/Desktop/Dataset/10/Trash"};
     std::vector<int> labelType ={1,0};
    std::vector<std::vector<float>>precisionAndrecall = [self Validate:pathToDataSets LabelType:labelType];
    
    std::fstream Validation("/Users/weil/Desktop/Dataset/Validation hue count.csv");
    Validation.seekp(0,std::ios::end);
    Validation <<precisionAndrecall[0][0]<<","<<precisionAndrecall[0][1]<<","<<precisionAndrecall[1][0]<<","<<precisionAndrecall[1][1] <<std::endl;
    Validation.close();
    
    NSLog(@"Precision and Recall for Class Good");
    NSLog(@"Precision : %f, Recall : %f",precisionAndrecall[0][0],precisionAndrecall[0][1]);
    
    NSLog(@"Precision and Recall for Class Trash");
    NSLog(@"Precision : %f, Recall : %f",precisionAndrecall[1][0],precisionAndrecall[1][1]);
    
    
    
    }
    



- (IBAction)onclick:(id)sender {
    NSLog (@"Hello, World!");

    std::vector<std::vector<float>> trainingData;
    std::vector<float> labels;
    std::vector<std::string> pathToDataSets {"/Users/weil/Desktop/Dataset/Good","/Users/weil/Desktop/Dataset/Trash"};
    std::vector<float> labelType ={1.0,0.0};
    
    
    
    [self Train:pathToDataSets Data:trainingData Labels:labels Labeltype:labelType];
    
    
    
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
