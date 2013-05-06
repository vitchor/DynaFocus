/*
 * PointInfo.cpp
 *
 *  Created on: Oct 19, 2012
 *      Author: marcelo
 *      This class was created to extract some information from features points
 */

#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include "PointInfo.h"
#include "Histogram1D.h"
#include <opencv2/nonfree/features2d.hpp>
#include <opencv2/contrib/contrib.hpp>

// Singleton pattern:
PointInfo *PointInfo::instance;
PointInfo::PointInfo() {
	distanceRelation = 0;
}
PointInfo *PointInfo::getInstance() {
	if (!instance) {
		instance = new PointInfo();
	}
	return instance;
}

// Warp all pictures within a path so the scale and rotation differances will be compensated
void PointInfo::warpPath(char **argv) {
	char the_path[151];
//	getcwd(the_path, 150);
	strcat(the_path, "/");
	strcat(the_path, argv[1]);

	DIR *dir;
	struct dirent *ent;
	dir = opendir(the_path);
	if (dir != NULL) {
		int index = 0;
		int size = 26;
		char *allPaths[size];
		char *newPaths[size];
		char *allNames[size];
		/* print all the files and directories within directory */
		while ((ent = readdir(dir)) != NULL) {
			if ((ent->d_name[0] != '.') && (ent->d_name[0] != 'W')) {
				char* filePath = new char[256];
				strcpy(filePath, the_path);
				strcat(filePath, ent->d_name);
				allPaths[index] = filePath;

				char* newPath = new char[256];
				strcpy(newPath, the_path);
				strcat(newPath, "Wrapped/");
				strcat(newPath, ent->d_name);
				newPaths[index] = newPath;

				allNames[index] = ent->d_name;
				index++;
			}
		}

		for (int var = (size - 1); var > 0; var--) {
//			cout << "var: " << var << endl;
			int i = size - var;
			for (; i > 0; i--) {
				cout << "  i: " << i << endl;
				Mat img_1 = imread(allPaths[i - 1], CV_32F);
				Mat img_2;
				if (i == (size - var)) {
					img_2 = imread(allPaths[i], CV_32F);
				} else {
					img_2 = imread(newPaths[i], CV_32F);
				}
				warpPictures(img_1, img_2, the_path, allNames[i - 1],
						allNames[i]);
				img_1.release();
				img_2.release();
			}
		}
		closedir(dir);
	} else {
		/* could not open directory */
		perror("");
	}
}

// Takes all kinds of blur measures within a picture
void PointInfo::processEachPic(char* filePath, string fileName) {
	Mat img_1 = imread(filePath, CV_8U);

	double maximum, minimal, mean;
	meanMaxMin(img_1, maximum, minimal, mean);

	double std_dev, variance;
	standardDeviation(img_1, mean, std_dev, variance);

	Histogram1D h;
	Mat normalizedHist = h.getHistogram(h.stretch(img_1)); // Normalize Histogram

	float min2, min3, max1, max2, max3, max4;
	h.findMaxMin(normalizedHist, 0, 63, min2, max1);
	h.findMaxMin(normalizedHist, 64, 127, min2, max2);
	h.findMaxMin(normalizedHist, 192, 255, min3, max4);
	h.findMaxMin(normalizedHist, 128, 191, min3, max3);

	float valley = min(min2, min3);
	float top = max(max(max1, max2), max(max3, max4));
	float diff = top - valley;

	cout << " >>>>>> " << fileName << ", STD DEV: " << std_dev
			<< "(HIST AMPLITUDE): " << diff << endl;
}

// Calculates standard deviation of the hole picture
void PointInfo::standardDeviation(Mat &image, double &mean, double &std_dev,
		double &var) {
	//Calculate the standard deviation of the image
	var = 0;

	int nl = image.rows; //Number of lines
	int nc = (image.cols) * (image.channels()); // number of elements per line

	// Iterates all Lines
	for (int j = 0; j < nl; j++) {
		uchar* data = image.ptr<uchar>(j); //Gets the address of row j. This row contains 'nc' elements
		// Goes through each pixel:
		for (int i = 0; i < nc; i++) {
			var += ((data[i] - mean) * (data[i] - mean));
		}
	}
	var /= (nc * nl);
	std_dev = sqrt(var);
}

// Finds the mean, max and min values of a pixel. It is called for the StandardDeviation Function
void PointInfo::meanMaxMin(Mat &image, double &max, double &minimal,
		double &mean) {
	minimal = max = 0;
	double sum = 0;
	int nl = image.rows; //Number of lines
	int nc = (image.cols) * (image.channels()); // number of elements per line

	// Iterates all Lines
	for (int j = 0; j < nl; j++) {
		uchar* data = image.ptr<uchar>(j); //Gets the address of row j. This row contains 'nc' elements
		// Goes through each pixel:
		for (int i = 0; i < nc; i++) {
			sum += data[i];
			if (data[i] < minimal)
				minimal = data[i];
			if (data[i] > max)
				max = data[i];
		}
	}

	mean = sum / (nl * nc);
}

// WARP 2 PICTURES
void PointInfo::warpPictures(Mat &img_1, Mat &img_2, char *path, char *name_1,
		char *name_2) {
	// STEP 1: Detect the keypoints using SURF Detector
	FastFeatureDetector detector(25, true);
	std::vector<KeyPoint> keypoints_1, keypoints_2;
	detector.detect(img_1, keypoints_1);
	detector.detect(img_2, keypoints_2);

	// STEP 2: Calculate descriptors (feature vectors)
	Mat descriptors_1, descriptors_2;
	DescriptorExtractor *extractor = new SIFT();
	extractor->compute(img_1, keypoints_1, descriptors_1);
	extractor->compute(img_2, keypoints_2, descriptors_2);

	//-- STEP 3: Matching descriptor vectors using FLANN matcher
	FlannBasedMatcher matcher;
	std::vector<DMatch> matches;
	matcher.match(descriptors_1, descriptors_2, matches);
	double max_dist = 0;
	double min_dist = 100;

	//-- Quick calculation of max and min distances between keypoints
	for (int i = 0; i < descriptors_1.rows; i++) {
		double dist = matches[i].distance;
		if (dist < min_dist)
			min_dist = dist;
		if (dist > max_dist)
			max_dist = dist;
	}

	// GOOD MATCHES: Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
	std::vector<DMatch> good_matches;

	for (int i = 0; i < descriptors_1.rows; i++) {
		if (matches[i].distance < 4 * min_dist) { //todo
			good_matches.push_back(matches[i]);
		}
	}

	Mat img_matches;
	drawMatches(img_1, keypoints_1, img_2, keypoints_2, good_matches,
			img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(),
			DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);

	// FIND the object from img_1 in img_2
	std::vector<Point2f> pts1;
	std::vector<Point2f> pts2;

	for (unsigned int i = 0; i < good_matches.size(); i++) {
		//-- KEYPOINTS: Get the keypoints from the good matches
		pts1.push_back(keypoints_1[good_matches[i].queryIdx].pt);
		pts2.push_back(keypoints_2[good_matches[i].trainIdx].pt);
	}

	vector<uchar> inliers(pts1.size(), 0);
	Mat H = findHomography(Mat(pts1), Mat(pts2), inliers, CV_RANSAC, 1);

	// Warp image 1 to image 2
	cv::Mat result;

	cv::warpPerspective(img_1, 					// input image
			result,									// output image
			H,										// homography
			cv::Size(img_1.cols, img_1.rows), INTER_LINEAR); // size of output image

	char *path1 = new char[256];
	strcpy(path1, path);
	strcat(path1, "Wrapped/");
	strcat(path1, name_1);
	cout << "Path1: " << path1 << endl;

	char *path2 = new char[256];
	strcpy(path2, path);
	strcat(path2, "Wrapped/");
	strcat(path2, name_2);
	cout << "Path2: " << path2 << endl;

	imwrite(path2, img_2); // Saves the image
	imwrite(path1, result); // Saves the image
}

//// WARP 2 PICTURES
//void PointInfo::warpPictures(Mat &img_1, Mat &img_2) {
//	// STEP 1: Detect the keypoints using SURF Detector
//	int minHessian = 100;
//	SurfFeatureDetector detector(minHessian);
//	std::vector<KeyPoint> keypoints_1, keypoints_2;
//	detector.detect(img_1, keypoints_1);
//	detector.detect(img_2, keypoints_2);
//
//	// STEP 2: Calculate descriptors (feature vectors)
//	Mat descriptors_1, descriptors_2;
//	DescriptorExtractor *extractor = new SIFT();
//	extractor->compute(img_1, keypoints_1, descriptors_1);
//	extractor->compute(img_2, keypoints_2, descriptors_2);
//
//	//-- STEP 3: Matching descriptor vectors using FLANN matcher
//	FlannBasedMatcher matcher;
//	std::vector<DMatch> matches;
//	matcher.match(descriptors_1, descriptors_2, matches);
//	double max_dist = 0;
//	double min_dist = 100;
//
//	//-- Quick calculation of max and min distances between keypoints
//	for (int i = 0; i < descriptors_1.rows; i++) {
//		double dist = matches[i].distance;
//		if (dist < min_dist)
//			min_dist = dist;
//		if (dist > max_dist)
//			max_dist = dist;
//	}
//
//	// FIND the object from img_1 in img_2
//	std::vector<Point2f> pts1;
//	std::vector<Point2f> pts2;
//	// GOOD MATCHES: Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
//	std::vector<DMatch> good_matches;
//	for (int i = 0; i < descriptors_1.rows; i++) {
//		if (matches[i].distance < 4 * min_dist) {
//			good_matches.push_back(matches[i]);
//			pts1.push_back(keypoints_1[matches[i].queryIdx].pt);
//			pts2.push_back(keypoints_2[matches[i].trainIdx].pt);
//		}
//	}
//
//	Mat img_matches;
//	drawMatches(img_1, keypoints_1, img_2, keypoints_2, good_matches,
//			img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(),
//			DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
//	displayWindow(img_matches,"MATCHES");
//
//	vector<uchar> inliers(pts1.size(), 0);
//	Mat H = findHomography(Mat(pts1), Mat(pts2), inliers, CV_RANSAC, 1);
//	cout << "H = " << endl << " " << H << endl << endl;
//
//
//	// decision rules:
//	// Mandatory: (H.at<double>(0,2) > 0) -> RX
//	// Mandatory: (H.at<double>(1,2) > 0) -> RY
//	// Good: (H.at<double>(0,0) > 1) ->TX
//	// Good: (H.at<double>(1,1) > 1) ->TY
//
//	// Try Homography in both ways to:
//	// minimize 'abs(RX - 1)' and 'abs(RY - 1)'
//	// minimize TX and TY
//
//	cv::Mat warped, reference;
//	// TESTS WHICH IMAGE SHOULD BE REDUCED
////	(H.at<double>(0,0) < 1) || (H.at<double>(1,1) < 1) ||
//	if((H.at<double>(0,2) > 0) || (H.at<double>(1,2) > 0)){
//		H = findHomography(Mat(pts2), Mat(pts1), inliers, CV_RANSAC, 1);
//		reference = img_1;
//		// Warp image 1 to image 2
//		cv::warpPerspective(img_2, 					// input image
//				warped,									// output image
//				H,										// homography
//				cv::Size(img_2.cols, img_2.rows), INTER_LINEAR); // size of output image
//		cout << "new H = " << endl << " " << H << endl << endl;
//	}else{
//		reference = img_2;
//		// Warp image 1 to image 2
//		cv::warpPerspective(img_1, 					// input image
//				warped,									// output image
//				H,										// homography
//				cv::Size(img_1.cols, img_1.rows), INTER_LINEAR); // size of output image
//	}
//
//	this->displayWindow(reference, "aux/Wrapped/praia_0", true);
//	this->displayWindow(warped, "aux/Wrapped/praia_1", true);
//}

// WARP 2 PICTURES
void PointInfo::warpPictures(Mat &img_1, Mat &img_2) {
	// STEP 1: Detect the keypoints using SURF Detector
	FastFeatureDetector detector = FastFeatureDetector(30, true);
	std::vector<KeyPoint> keypoints_1, keypoints_2;
	detector.detect(img_1, keypoints_1);
	detector.detect(img_2, keypoints_2);
	cout << "Step1 complete: detected k1: " << keypoints_1.size() << " and k2: " << keypoints_2.size() << " keypoints" << endl;

	// STEP 2: Calculate descriptors (feature vectors)
	Mat descriptors_1, descriptors_2;
	SurfDescriptorExtractor extractor;
	extractor.compute(img_1, keypoints_1, descriptors_1);
	extractor.compute(img_2, keypoints_2, descriptors_2);
	cout << "Step 2 complete: extract descriptors" << endl;

	// Tries the algorithm in one direction
	vector<DMatch> good_matches;
	std::vector<Point2f> pts1, pts2;
	this->matchPoints(good_matches, pts1, pts2, descriptors_1, descriptors_2,
			keypoints_1, keypoints_2);
	vector<uchar> inliers(pts1.size(), 0);
	Mat H12 = findHomography(Mat(pts1), Mat(pts2), inliers, CV_RANSAC, 1);
	cout << "H12 = " << endl << " " << H12 << endl << endl;
	cout << "Step 3 complete: found Homography 12" << endl;

	//CHECKS WHICH MATRIX IS BETTER AND RETURN THAT MATRIX
	int mand12 = 0;
	int opt12 = 0;
	if ((H12.at<double>(0, 2) < 0) && (H12.at<double>(1, 2) < 0)) {
		mand12 = 2;
	} else if ((H12.at<double>(0, 2) < 0) || (H12.at<double>(1, 2) < 0)) {
		mand12 = 1;
	}
	if ((H12.at<double>(0, 0) < 0) && (H12.at<double>(1, 1) < 0)) {
		opt12 = 2;
	} else if ((H12.at<double>(0, 0) < 0) || (H12.at<double>(1, 1) < 0)) {
		opt12 = 1;
	}

	int mand21 = 0;
	int opt21 = 0;
	Mat H21 = H12.inv();
	cout << "H21 = " << endl << " " << H21 << endl << endl;
	if ((H21.at<double>(0, 2) < 0) && (H21.at<double>(1, 2) < 0)) {
		mand21 = 2;
	} else if ((H21.at<double>(0, 2) < 0) || (H21.at<double>(1, 2) < 0)) {
		mand21 = 1;
	}
	if ((H21.at<double>(0, 0) < 0) && (H21.at<double>(1, 1) < 0)) {
		opt21 = 2;
	} else if ((H21.at<double>(0, 0) < 0) || (H21.at<double>(1, 1) < 0)) {
		opt21 = 1;
	}

	bool put12 = false;
	if (mand12 > mand21) {
		cout << "H12 is better, mand12 > mand21" << endl;
		put12 = true;
	} else if (mand21 > mand12) {
		cout << "H21 is better, mand21 > mand12" << endl;
		put12 = false;
	} else {
		if (opt12 > opt21) {
			put12 = true;
			cout << "H12 is better, opt12 > opt21" << endl;
		} else if (opt21 > opt12) {
			put12 = false;
			cout << "H21 is better, opt21 > opt12" << endl;
		} else {
			cout << "Can't decide between Homography matrixes" << endl;
		}
	}

	cv::Mat warped, reference;
    if(put12){
        reference = img_2;
        // Warp image 1 to image 2
        cout << "calculating H12" << endl;
        cv::warpPerspective(img_1,                                  // input image
                warped,                                             // output image
                H12,                                                // homography
                cv::Size(img_1.cols, img_1.rows), INTER_LINEAR);    // size of output image
        cout << "FINISHED calculating H12" << endl;
        
    }else{
        reference = img_1;
        // Warp image 2 to image 1
        cout << "calculating H21" << endl;
        cv::warpPerspective(img_2,                                  // input image
                warped,                                             // output image
                H21,                                                // homography
                cv::Size(img_2.cols, img_2.rows), INTER_LINEAR);    // size of output image
        cout << "FINISHED calculating H21" << endl;
    }
    img_1 = reference;
    img_2 = warped;
}
// decision rules:
// Mandatory: (H.at<double>(0,2) < 0) -> RX
// Mandatory: (H.at<double>(1,2) < 0) -> RY
// Good: (H.at<double>(0,0) > 1) ->TX
// Good: (H.at<double>(1,1) > 1) ->TY

// Try Homography in both ways to:
// minimize 'abs(RX - 1)' and 'abs(RY - 1)'
// minimize TX and TY

// Tries the algorithm in the other direction
//	vector<DMatch> good_matchesAB;
//	std::vector<Point2f> ptsA, ptsB;
//	this->matchPoints(good_matchesAB, ptsA, ptsB, descriptors_2, descriptors_1,
//			keypoints_2, keypoints_1);
//	vector<uchar> inliersAB(ptsA.size(), 0);
//	Mat HAB = findHomography(Mat(ptsA), Mat(ptsB), inliersAB, CV_RANSAC, 1);

//	Mat img_matches;
//	drawMatches(img_1, keypoints_1, img_2, keypoints_2, good_matches,
//			img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(),
//			DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
//	displayWindow(img_matches, "MATCHES");

//	cv::Mat warped, reference;
//	 TESTS WHICH IMAGE SHOULD BE REDUCED
//	(H.at<double>(0,0) < 1) || (H.at<double>(1,1) < 1) ||
//	if ((H.at<double>(0, 2) > 0) || (H.at<double>(1, 2) > 0)) {
//		H = findHomography(Mat(pts2), Mat(pts1), inliers, CV_RANSAC, 1);
//		reference = img_1;
//		// Warp image 1 to image 2
//		cv::warpPerspective(img_2, 					// input image
//				warped,									// output image
//				H,										// homography
//				cv::Size(img_2.cols, img_2.rows), INTER_LINEAR); // size of output image
//		cout << "new H = " << endl << " " << H << endl << endl;
//	} else {
//		reference = img_2;
//		// Warp image 1 to image 2
//		cv::warpPerspective(img_1, 					// input image
//				warped,									// output image
//				H,										// homography
//				cv::Size(img_1.cols, img_1.rows), INTER_LINEAR); // size of output image
//	}

//	this->displayWindow(reference, "aux/Wrapped/praia_0", true);
//	this->displayWindow(warped, "aux/Wrapped/praia_1", true);
//}

// FILLS good_matches, points1 and points 2 vectors
void PointInfo::matchPoints(vector<DMatch> &good_matches, vector<Point2f> &pts1,
		vector<Point2f> &pts2, Mat descriptors_1, Mat descriptors_2,
		vector<KeyPoint> keypoints_1, vector<KeyPoint> keypoints_2) {
	//-- STEP 3: Matching descriptor vectors using FLANN matcher
	FlannBasedMatcher matcher;
	std::vector<DMatch> matches;
	matcher.match(descriptors_1, descriptors_2, matches);
	double max_dist = 0;
	double min_dist = 100;

	//-- Quick calculation of max and min distances between keypoints
	for (int i = 0; i < descriptors_1.rows; i++) {
		double dist = matches[i].distance;
		if (dist < min_dist)
			min_dist = dist;
		if (dist > max_dist)
			max_dist = dist;
	}

	// FIND the object from img_1 in img_2
	// GOOD MATCHES: Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
	for (int i = 0; i < descriptors_1.rows; i++) {
		if (matches[i].distance < 3 * min_dist) {
			good_matches.push_back(matches[i]);
			pts1.push_back(keypoints_1[matches[i].queryIdx].pt);
			pts2.push_back(keypoints_2[matches[i].trainIdx].pt);
		}
	}
}

// Gets distance from a reference point, usually the center point (coordinates (X0, Y0))
float PointInfo::getDistance(float X0, float Y0, Point2f point) {
	return sqrtf(pow((point.y - Y0), 2) + pow((point.x - X0), 2));
}

// Returns the value of the tan of a given point in relation with the reference coordinates (X0, Y0)
float PointInfo::getTan(float X0, float Y0, Point2f point) {
	return (point.y - Y0) / pow((point.x - X0), 2);
}

// Prints the given info String
void PointInfo::readme(string info) {
	std::cout << info << std::endl;
}

// Shows the image in a window, allowing it to be saved in a
void PointInfo::displayWindow(Mat image, string fileName, bool mightSave) {
	namedWindow(fileName); //Define the window
	imshow(fileName, image);
	if (mightSave) {
		fileName.append(".jpg");
		imwrite(fileName, image); // Saves the image
	}
}

// Shows the image in a window
void PointInfo::displayWindow(Mat image, string filename) {
	displayWindow(image, filename, false);
}

//????
void PointInfo::showFocus(Mat img_original) {
	displayWindow(img_original, "input");
	Mat output;
	output = img_original.clone();
	applyColorMap(img_original, output, COLORMAP_HOT);
	displayWindow(output, "colormap");
}

// Reduces the color of the image to allow faster processing or easier feature detection
void PointInfo::reduceColourTopPerformance(Mat input, Mat output,
		int divideBy) {
	int nl = input.rows; //Number of lines
	int nc = input.cols;

	// PERFORMANCE: Reduces de number of loops
	if (input.isContinuous() && output.isContinuous()) {
		nc = nc * nl;
		nl = 1;
		cout << "Input is continuous? " << input.isContinuous()
				<< "\nOutput is continuous? " << output.isContinuous() << "\n";
	}
	// PERFORMANCE: Recommended by many authors:
	if (divideBy % 2 == 0) {
		uchar mask;
		int n = static_cast<int>(log(static_cast<double>(divideBy)) / log(2.0)); // mask used to round the pixel value
		mask = 0xFF << n;
		// Iterates all Lines
		for (int j = 0; j < nl; j++) {
			const uchar* dataInput = input.ptr<uchar>(j); //Gets the address of row j. This row contains 'nc' elements
			uchar* dataOutput = output.ptr<uchar>(j); //Gets the address of row j. This row contains 'nc' elements
			// Goes throught each pixel:
			for (int i = 0; i < nc; i++) {
				*dataOutput++ = ((*dataInput++) & mask) + divideBy / 2; // Processing each pixel
				*dataOutput++ = ((*dataInput++) & mask) + divideBy / 2; // Processing each pixel
				*dataOutput++ = ((*dataInput++) & mask) + divideBy / 2; // Processing each pixel
			}
		}
	} else {
		// Iterates all Lines
		for (int j = 0; j < nl; j++) {
			const uchar* dataInput = input.ptr<uchar>(j); //Gets the address of row j. This row contains 'nc' elements
			uchar* dataOutput = output.ptr<uchar>(j); //Gets the address of row j. This row contains 'nc' elements
			// Goes throught each pixel:
			for (int i = 0; i < nc; i++) {
				*dataOutput++ = (((*dataInput++) / divideBy) * divideBy)
						+ divideBy / 2; // Processing each pixel
				*dataOutput++ = (((*dataInput++) / divideBy) * divideBy)
						+ divideBy / 2; // Processing each pixel
				*dataOutput++ = (((*dataInput++) / divideBy) * divideBy)
						+ divideBy / 2; // Processing each pixel
			}
		}
	}
}

//Match points of 2 given pictures
int PointInfo::matchPoints(Mat img_1, Mat img_2) {
	//////////////////////////////////////
	// EXTRACT KEYPOINTS
	//////////////////////////////////////
	std::vector<KeyPoint> keypoints_1, keypoints_2;
	FeatureDetector *detector = new StarFeatureDetector();
	detector->detect(img_1, keypoints_1);
	detector->detect(img_2, keypoints_2);
	delete detector;

	//////////////////////////////////////
	// EXTRACT DESCRIPTORS
	//////////////////////////////////////
	Mat descriptors_1, descriptors_2;
	DescriptorExtractor *extractor = new SIFT();
	extractor->compute(img_1, keypoints_1, descriptors_1);
	extractor->compute(img_2, keypoints_2, descriptors_2);
	delete extractor;

	////////////////////////////
	// Finds Matches
	////////////////////////////
	FlannBasedMatcher matcher;
	std::vector<DMatch> matches;
	matcher.match(descriptors_1, descriptors_2, matches);

	double max_dist = 0;
	double min_dist = 100;

	int count = 0;
	double average = 0;
	//-- Quick calculation of max and min distances between keypoints
	for (int i = 0; i < descriptors_1.rows; i++) {
		double dist = matches[i].distance;
		count++;
		average = average + dist;
		if (dist < min_dist)
			min_dist = dist;
		if (dist > max_dist)
			max_dist = dist;
	}
	cout << "min = " << min_dist << ", max = " << max_dist << endl;

	////////////////////////////
	// Refines Found Matches
	////////////////////////////
	vector<DMatch> good_matches;
	int matchesSize = matches.size();
	if (matchesSize < 2) {
		printf(
				"-- Sorry, the number of similar points found is not enough to complete this algorithm. Sorry, matchhesSize = %i \n",
				matchesSize);
		return -1;
	} else {
		// Gets center points:
		int X0 = img_1.cols / 2;
		int Y0 = img_1.rows / 2;

		// ATTENTION !!: THESE LINES WILL DEFINE AN INTERVAL WHERE THE NUMBER OF MATCH POINTS WILL BE ACCEPTED:
		int minExpectedMatches = 10;
		int maxExpectedMatches = 25 * minExpectedMatches;

		// CALCULATES THE minRadius THAT WILL PRODUCE A DISPLACEMENT GREATHER THAN 1 PIXEL:
		int radiusReference = min(X0, Y0);
		float s = 2; 				 //safety factor, must be >= 1 PIXEL
		float minRadius = s / 0.05;
//		float minRadius = max((s / 0.05),(0.2*radiusReference));
		float distanceFactor = 2;
		// k [%]: THIS IS THE MAX ALLOWED DISPLACEMENT BETWEEN THE MATCH POINTS. THIS IS ACTUALLY CLOSER TO 0.05 BUT THIS VALUE MAY BE INCREASED DEPENDING ON NOISE
		float k = 0.1;

		// SAYS THE MINRADIUS MUST BE SMALLER THAN radiusReference:
		if (minRadius >= 0.75 * radiusReference) {
			minRadius = 0.75 * radiusReference;
			s = 0.05 * minRadius;
		}

		// READS THE NUMBER OF FOUND MATCH POINTS
		good_matches = tryMatches(X0, Y0, minRadius, k, distanceFactor,
				matchesSize, matches, min_dist, keypoints_1, keypoints_2);
		// ACCORDING TO THE NUMBER OF FOUND MATCHES IT CHANGES THE PARAMETERS AND TRYES TO REFINE THE SEARCH
		static int counter = good_matches.size();
		for (int var = 0; var < 3; ++var) {
			if (counter < minExpectedMatches) {
				minRadius = 1 / 0.05;
				distanceFactor = distanceFactor * 2;
				good_matches = tryMatches(X0, Y0, minRadius, k, distanceFactor,
						matchesSize, matches, min_dist, keypoints_1,
						keypoints_2);
			} else if (counter > maxExpectedMatches) {
				minRadius = minRadius * 1.2;
				distanceFactor = distanceFactor * 0.8;
				good_matches = tryMatches(X0, Y0, minRadius, k, distanceFactor,
						matchesSize, matches, min_dist, keypoints_1,
						keypoints_2);
			}
		}
	}

	////////////////////////////
	// Draws Those good Matches
	////////////////////////////
	Mat img_matches;
	drawMatches(img_1, keypoints_1, img_2, keypoints_2, matches, img_matches,
			Scalar::all(-1), Scalar::all(-1), vector<char>(),
			DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
	imshow("Good Matches", img_matches); 	//-- Show detected matches

	return 1;
}

// Recize and crop considering just radial distortion
int PointInfo::resizeAndCrop(Mat img_1, Mat img_2) {
	// Checks if the image could be loaded
	if (!img_1.data || !img_2.data) {
		std::cout << " --(!) Error reading images " << std::endl;
		return -1;
	}

	matchPoints(img_1, img_2);
	if (abs(distanceRelation - 1) > 0.008) {
		crop(img_1, img_2);
	}

	for (int var = 0; var < 3; ++var) {
		matchPoints(img_1, img_2);
		if (abs(distanceRelation - 1) > 0.008) {
			crop(img_1, img_2);
		}
	}
	displayWindow(img_1, "img_11", true);
	displayWindow(img_2, "img_22", true);
	return 1;
}

void PointInfo::crop(Mat &img_1, Mat &img_2) {
	if (distanceRelation <= 1) {
		cout << "Average Radius Relation: PIC2 = PIC2*"
				<< (1 / distanceRelation) << endl;
		crop(img_2, (1 / distanceRelation));
	} else {
		crop(img_1, (distanceRelation));
		cout << "Average Radius Relation: PIC1 = PIC1*" << distanceRelation
				<< endl;
	}
}

void PointInfo::crop(Mat &img_original, float resizeFactor) {
	Mat img_resized;
	resize(img_original, img_resized, cv::Size(), resizeFactor, resizeFactor,
			INTER_LINEAR);
	displayWindow(img_resized, "Image resized");
	int x0 = (img_resized.cols - img_original.cols) / 2;
	int y0 = (img_resized.rows - img_original.rows) / 2;
	cv::Rect roi = cv::Rect(x0, y0, img_original.cols, img_original.rows);
	img_original = cv::Mat(img_resized, roi);
}
// TODO TESTAR ESTA FUNCAO EM UMA UNICA FOTO, LEMBRANDO DE CRIAR PASTAS 1, 2, 3
void PointInfo::divideHorizontally(char *filePath, char *the_path, char *name,
		int divisions, bool includeBorders) {
	if (divisions > 1) {
		int deltaX, x0, y0, x;
		x0 = 0;
		y0 = 0;
		x = 0;
		Mat img_original = imread(filePath, CV_32F);
		int deltaY = img_original.rows;
		if (!includeBorders) {
			deltaX = img_original.cols / ((2 * divisions) + 1);
			for (int var = divisions; var > 0; var--) {
				char* pathName = new char[256];
				strcpy(pathName, the_path);
				sprintf(pathName, "%s%d", pathName, (divisions - var + 1));
				strcat(pathName, "_");
				strcat(pathName, name);
				x0 = x + deltaX;
				x = x0 + deltaX;
				cv::Rect roi = cv::Rect(x0, y0, deltaX, deltaY);
				cv::Mat A = cv::Mat(img_original, roi);
				imwrite(pathName, A);
			}
		} else {
			deltaX = img_original.cols / ((2 * divisions) - 1);
			if (divisions % 2 != 0) {
				for (int var = divisions; var > 0; var--) {
					char* pathName = new char[256];
					strcpy(pathName, the_path);
					sprintf(pathName, "%s%d", pathName, (divisions - var + 1));
					strcat(pathName, "_");
					strcat(pathName, name);
					cout << "x0, x: " << x0 << ", " << x << ", DELTAx = "
							<< deltaX << endl;
					if (x == 0) {
					} else {
						x0 = x + deltaX;
					}
					x = x0 + deltaX;
					cout << "x0, x: " << x0 << ", " << x << endl;
					cv::Rect roi = cv::Rect(x0, y0, deltaX, deltaY);
					cv::Mat A = cv::Mat(img_original, roi);
					imwrite(pathName, A);
				}
			}
		}
	}

}

// FINDS THE BEST MATCHES ACCORDING TO THE GIVEN PARAMETERS AND RETURNS THE NUMBER OF FOUND MATCHED POINTS
// IT ALSO CHANGES THE VALUE OF THE distanceRelation VARIABLE, THAT WILL BE USED IN THE FUTURE TO RESIZE AND CROP THE PICTURE
vector<DMatch> PointInfo::tryMatches(float X0, float Y0, float minRadius,
		float k, float distanceFactor, int matchesSize, vector<DMatch> matches,
		float min_dist, vector<KeyPoint> keypoints_1,
		vector<KeyPoint> keypoints_2) {
	int counter = 0;
	distanceRelation = 0.0; // THE SUM OF ALL RADIUS2/RADIUS1 VALUES.
	float SUMdistance = 0.0;
	vector<DMatch> good_matches;
	vector<Point2f> points1, points2;

	for (int i = 0; i < matchesSize; i++) {
		if (matches[i].distance <= distanceFactor * min_dist) {
			Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
			Point2f p2 = keypoints_2[matches[i].trainIdx].pt;

			// Gets X and Y for the points, in telation to centerpoint
			float deltaX1 = abs(X0 - p1.x);
			float deltaY1 = abs(Y0 - p1.y);
			float deltaX2 = abs(X0 - p2.x);
			float deltaY2 = abs(Y0 - p2.y);

			// Assures the minimum distance from the center point is greather than minRadius
			if (min(min(deltaX1, deltaX2), min(deltaY1, deltaY2))
					<= minRadius) {
			} else {
				// Gets the difference between Xs and Ys distances
				float deltaX = deltaX1 - deltaX2;
				float deltaY = deltaY1 - deltaY2;

				// It will be considered to be a good match if both X and Y rise (or decrease)  together
				if (abs(deltaX + deltaY) == abs(deltaX) + abs(deltaY)) {
					float deformation = abs(
							(deltaX1 / deltaX2) / (deltaY1 / deltaY2));
					// if there is a big difference between deltaX and deltaY, it won't be added
					if ((deformation < (1 + k)) && (deformation > (1 - k))) {
//						cout << "deformation " << deformation << endl;
						good_matches.push_back(matches[i]);
						float radius1 = getDistance(X0, Y0, p1);
						float radius2 = getDistance(X0, Y0, p2);
						SUMdistance += radius2 / radius1;
						points1.push_back(p1);
						points2.push_back(p2);
						counter++;
					}
				}
			}
		}
	}
	if (counter > 0)
		distanceRelation = SUMdistance / counter;
	cout << "======= DISTANCE RELATION = " << distanceRelation << endl;
	return good_matches;
}
PointInfo::~PointInfo() {
}

