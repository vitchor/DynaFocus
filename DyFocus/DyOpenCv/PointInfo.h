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

class PointInfo {
public:
	void divideHorizontally(char *filePath, char *the_path, char *name,
			int divisions, bool includeBorders);
	void standardDeviation(Mat &image, double &mean, double &std_dev,
			double &var);
	void meanMaxMin(Mat &image, double &max, double &minimal, double &mean);
	void processEachPic(char* filePath, string fileName);
	void warpPath(char **argv);
	void warpPictures(Mat &img_1, Mat &img_2, char *path, char *name_1,
			char *name_2);
	void warpPictures(Mat &img_1, Mat &img_2, char *path);
	void warpPictures(Mat &img_1, Mat &img_2);
	void showFocus(Mat img_original);
	void crop(Mat &img_original, float resizeFactor);
	void crop(Mat &img_1, Mat &img_2);

	vector<DMatch> tryMatches(float X0, float Y0, float minRadius, float k,
			float distanceFactor, int matchesSize, vector<DMatch> matches,
			float min_dist, vector<KeyPoint> keypoints_1,
			vector<KeyPoint> keypoints_2);
	int resizeAndCrop(Mat img_1, Mat img_2);
	int matchPoints(Mat img_1, Mat img_2);
	static PointInfo *getInstance(); 				// Singleton Pattern
	static float getDistance(float X0, float Y0, cv::Point2f point);
	static float getTan(float X0, float Y0, cv::Point2f point);
	static void reduceColourTopPerformance(cv::Mat input, cv::Mat output,
			int divideBy);
	static void displayWindow(Mat image, string fileName, bool mightSave);
	static void displayWindow(Mat image, string filename);
	static void readme(string info);
	virtual ~PointInfo();
private:
	static PointInfo *instance;						// Singleton Pattern
//	Mat homography;
	float distanceRelation;
	void matchPoints(vector<DMatch> &good_matches, vector<Point2f> &pts1,
			vector<Point2f> &pts2, Mat descriptors_1, Mat descriptors_2,
			vector<KeyPoint> keypoints_1, vector<KeyPoint> keypoints_2);
protected:
	PointInfo(); 								// Singleton Pattern
};

#endif /* POINTINFO_H_ */
