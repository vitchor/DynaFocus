/*
 * Histogram1D.h
 *
 *  Created on: Oct 18, 2012
 *      Author: marcelo
 */

#ifndef HISTOGRAM1D_H_
#define HISTOGRAM1D_H_

#include "opencv2/highgui/highgui.hpp"
using namespace cv;

class Histogram1D {
private:
	int histSize[1]; // number of bins
	float hranges[2]; // min and max pixel value
	const float* ranges[1];
	int channels[1]; // only 1 channel used here

public:
	Histogram1D();
	void findMaxMin(MatND &hist, int start, int finish, float &min, float &max);
	cv::MatND getHistogram(const cv::Mat &image);
	cv::Mat getHistogramImage(const cv::Mat &image);
	cv::Mat applyLookUp(const cv::Mat& image, const cv::Mat& lookup);
	cv::Mat stretch(const cv::Mat &image, int minValue=0);
	virtual ~Histogram1D();
};

#endif /* HISTOGRAM1D_H_ */
