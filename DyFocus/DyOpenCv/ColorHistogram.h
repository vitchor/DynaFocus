/*
 * ColorHistogram.h
 *
 *  Created on: Oct 18, 2012
 *      Author: marcelo
 */

#ifndef COLORHISTOGRAM_H_
#define COLORHISTOGRAM_H_

class ColorHistogram {
private:
	int histSize[3];
	float hranges[2];
	const float* ranges[3];
	int channels[3];

public:
	ColorHistogram();
	cv::MatND getHistogram(const cv::Mat &image);
	cv::SparseMat getSparseHistogram(const cv::Mat &image);
	virtual ~ColorHistogram();
};

#endif /* COLORHISTOGRAM_H_ */
