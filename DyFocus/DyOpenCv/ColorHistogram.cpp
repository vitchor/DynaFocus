/*
 * ColorHistogram.cpp
 *
 *  Created on: Oct 18, 2012
 *      Author: marcelo
 */

#include "ColorHistogram.h"
#include "opencv2/highgui/highgui.hpp"
using namespace cv;

ColorHistogram::ColorHistogram() {
	// Prepare arguments for a color histogram
	histSize[0] = histSize[1] = histSize[2] = 256;
	// BRG range:
	hranges[0] = 0.0;
	hranges[1] = 255.0;
	// all channels have the same range:
	ranges[0] = hranges;
	ranges[1] = hranges;
	ranges[2] = hranges;
	// the three channels:
	channels[0] = 0;
	channels[1] = 1;
	channels[2] = 2;
}

MatND ColorHistogram::getHistogram(const cv::Mat &image) {
	MatND hist;
	// Compute histogram
	calcHist(&image, 1, 	// histogram of 1 image only
			channels, 		// the channel used
			Mat(), 			// no mask is used
			hist, 			// the resulting histogram
			3, 				// it is a 3D histogram
			histSize, 		// number of bins
			ranges);		// pixel value range
	return hist;
}

SparseMat ColorHistogram::getSparseHistogram(const cv::Mat &image) {
	cv::SparseMat hist(3, histSize, CV_32F);
// Compute histogram
	cv::calcHist(&image, 1, 	// histogram of 1 image only
			channels, 			// the channel used
			cv::Mat(), 			// no mask is used
			hist,   			// the resulting histogram
			3,   				// it is a 3D histogram
			histSize, 			// number of bins
			ranges				// pixel value range
			);
	return hist;
}

ColorHistogram::~ColorHistogram() {
	// TODO Auto-generated destructor stub
}
