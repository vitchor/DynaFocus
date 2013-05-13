/*
 * PointInfo.h
 *
 *  Created on: Oct 19, 2012
 *      Author: marcelo
 */

#ifndef POINTINFO_H_
#define POINTINFO_H_

#include <stdio.h>

using namespace cv;
using namespace std;

class AntiShake {
public:
	void meanMaxMin(Mat &image, double &max, double &minimal, double &mean);
	void antiShake(Mat &img_1, Mat &img_2);
	static AntiShake *getInstance(); 				// Singleton Pattern
	static void displayWindow(Mat image, string fileName, bool mightSave);
	static void displayWindow(Mat image, string filename);
	static void readme(string info);
	virtual ~AntiShake();
private:
	static AntiShake *instance;						// Singleton Pattern
	void getBestMatches(int nthNumber, std::vector<DMatch> &matches, vector<Point2f> &pts1,
			vector<Point2f> &pts2, Mat descriptors_1, Mat descriptors_2,
			vector<KeyPoint> keypoints_1, vector<KeyPoint> keypoints_2);
protected:
	AntiShake(); 								// Singleton Pattern
};

#endif /* POINTINFO_H_ */
