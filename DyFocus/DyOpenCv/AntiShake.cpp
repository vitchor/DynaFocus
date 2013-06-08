/*
 * AntiShake.cpp
 *
 *  Created on: Oct 19, 2012
 *      Author: marcelo
 *      This class was created to extract some information from features points
 */

#include <stdlib.h>
#include "AntiShake.h"
#include "Histogram1D.h"
#include <opencv2/nonfree/features2d.hpp>

// Singleton pattern:
AntiShake *AntiShake::instance;
AntiShake::AntiShake() {
	eye3x3 = (Mat_<double>(3,3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
}
AntiShake *AntiShake::getInstance() {
	if (!instance) {
		instance = new AntiShake();
	}
	return instance;
}

//Selects best calculated homography. If both are considered impropry, returns identity matrix
cv::Mat getHomography(std::vector<Point2f> &pts1, std::vector<Point2f> &pts2,
                      std::vector<uchar> &inliers, int &index) {
	Mat H12 = findHomography(Mat(pts1), Mat(pts2), inliers, CV_RANSAC, 1);
    
	Mat HReference = H12;
	index = 0;
    
	if(abs(HReference.at<double>(2,0) > 0.0002) || abs(HReference.at<double>(2,1) > 0.0002)){
		index = 2;
		HReference = (Mat_<double>(3,3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
	}
	return HReference;
}

void compensateBrightness(Mat &src1, Mat &src2, Mat &output1, Mat &output2){
	// STEP A: Create copies
	src1.copyTo(output1);
	src2.copyTo(output2);
    
	// STEP B: Calculates overall brightness?
	double brightness1 = 0;
	double brightness2 = 1;
	for (int y = 0; y < output1.rows; y++) {
		for (int x = 0; x < output1.cols; x++) {
			brightness1 = brightness1 + output1.at<Vec3b>(y, x)[0] + output1.at<Vec3b>(y, x)[1] + output1.at<Vec3b>(y, x)[2];
			brightness2 = brightness2 + output2.at<Vec3b>(y, x)[0] + output2.at<Vec3b>(y, x)[1] + output2.at<Vec3b>(y, x)[2];
		}
	}
	brightness1 = brightness1/((output1.rows)*(output1.cols));
	brightness2 = brightness2/((output2.rows)*(output2.cols));
    
	// STEP C: Equalizes brightness:
	double brightDiff, beta;
	beta = abs(brightness1 - brightness2)/50;
	if(brightness1 > brightness2){
		brightDiff = brightness1/brightness2;
		for (int y = 0; y < output2.rows; y++) {
			for (int x = 0; x < output2.cols; x++) {
				output2.at<Vec3b>(y, x)[0] = saturate_cast<uchar>(brightDiff*(output2.at<Vec3b>(y, x)[0]) + beta);
				output2.at<Vec3b>(y, x)[1] = saturate_cast<uchar>(brightDiff*(output2.at<Vec3b>(y, x)[1]) + beta);
				output2.at<Vec3b>(y, x)[2] = saturate_cast<uchar>(brightDiff*(output2.at<Vec3b>(y, x)[2]) + beta);
			}
		}
	}else{
		brightDiff = brightness2/brightness1;
		for (int y = 0; y < output1.rows; y++) {
			for (int x = 0; x < output1.cols; x++) {
				output1.at<Vec3b>(y, x)[0] = saturate_cast<uchar>(brightDiff*(output1.at<Vec3b>(y, x)[0]) + beta);
				output1.at<Vec3b>(y, x)[1] = saturate_cast<uchar>(brightDiff*(output1.at<Vec3b>(y, x)[1]) + beta);
				output1.at<Vec3b>(y, x)[2] = saturate_cast<uchar>(brightDiff*(output1.at<Vec3b>(y, x)[2]) + beta);
			}
		}
	}
}

// Blur both images so blurriness will not continue to be a difference but a common caracteristic
void compensateBlurriness(Mat &src1, Mat &src2, Mat &output1, Mat &output2, int oddNumber){
	blur( src1, output1, Size( oddNumber, oddNumber ), Point(-1,-1) );
	blur( src2, output2, Size( oddNumber, oddNumber ), Point(-1,-1) );
}

void sobelOperator(Mat &src1, Mat &output1, Mat &src2, Mat &output2, int scale, int delta/*, int blurSize, int point*/){
	int ddepth = CV_16S;
    
	GaussianBlur( src1, output1, Size(3,3), 0, 0, BORDER_DEFAULT );
    //	blur( src1, output1, Size( blurSize, blurSize), Point(point, point) );
    
    
	if(output1.type() == 16){
		/// Convert it to gray
		cvtColor( output1, output1, CV_RGB2GRAY );
	}
	/// Generate grad_x and grad_y
	Mat grad_x, grad_y, grad;
	Mat abs_grad_x, abs_grad_y;
    
	int border = BORDER_ISOLATED;
	/// Gradient X
	//Scharr( src_gray, grad_x, ddepth, 1, 0, scale, delta, BORDER_DEFAULT );
	Sobel( output1, grad_x, ddepth, 1, 0, 3, scale, delta, border );
	convertScaleAbs( grad_x, abs_grad_x );
    
	/// Gradient Y
	//Scharr( src_gray, grad_y, ddepth, 0, 1, scale, delta, BORDER_DEFAULT );
	Sobel( output1, grad_y, ddepth, 0, 1, 3, scale, delta, border );
	convertScaleAbs( grad_y, abs_grad_y );
    
	/// Total Gradient (approximate)
	addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad );
	grad.copyTo(output1);
    
	grad_x.release();
	grad_y.release();
	abs_grad_x.release();
	abs_grad_y.release();
    
	GaussianBlur( src2, output2, Size(3,3), 0, 0, BORDER_DEFAULT );
    //	blur( src2, output2, Size( blurSize, blurSize), Point(point) );
    
	if(output2.type() == 16){
		/// Convert it to gray
		cvtColor( output2, output2, CV_RGB2GRAY );
	}
	/// Generate grad_x and grad_y
	Mat grad_x2, grad_y2, grad2;
	Mat abs_grad_x2, abs_grad_y2;
    
	/// Gradient X
	//Scharr( src_gray, grad_x, ddepth, 1, 0, scale, delta, BORDER_DEFAULT );
	Sobel( output2, grad_x2, ddepth, 1, 0, 3, scale, delta, border );
	convertScaleAbs( grad_x2, abs_grad_x2 );
    
	/// Gradient Y
	//Scharr( src_gray, grad_y, ddepth, 0, 1, scale, delta, BORDER_DEFAULT );
	Sobel( output2, grad_y2, ddepth, 0, 1, 3, scale, delta, border );
	convertScaleAbs( grad_y2, abs_grad_y2 );
    
	/// Total Gradient (approximate)
	addWeighted( abs_grad_x2, 0.5, abs_grad_y2, 0.5, 0, grad2 );
	grad2.copyTo(output2);
    
	grad_x2.release();
	grad_y2.release();
	abs_grad_x2.release();
	abs_grad_y2.release();
}

cv::Mat AntiShake::fixPictures(Mat &img_1, Mat &img_2, int loops){
	// Firstly we calculate the Homography matrix than we reffine it in the FeedbackController function:
	Mat H = getHomographyFeedbackController(img_1, img_2, loops);
	double det = determinant(H);
	cout << "STEP 11 final homography = " << endl << H << endl << " determinant = " <<det << endl;
	//Secondly, lets transform the picture according to the calculated (resultant) smatrix.
    
	if(det > 1.0){
		applyHomography(H, img_1, img_2);
		cout << "STEP 12 fixed original pictures" << endl;
		return H;
	}else{
		Mat H2 = H.inv();
		applyHomography(H2, img_2, img_1);
		cout << "STEP 12 fixed original pictures" << endl;
		return H2;
	}
	// TODO ERASE WHEN RUNNING IN MOBILE
    //	displayWindow(img_1, "aux/Wrapped/img1", true);
    //	displayWindow(img_2, "aux/Wrapped/img2", true);
}

void AntiShake::applyHomography(Mat &homography, Mat &img_1, Mat &img_2){
	Mat original, compensated;
	// STEP 10: Compare with identity and if not equal, applies correction
	if(determinant(homography) == 1.0){
		cout << "==== applyHomography -> EQUALS IDENTITY " << endl;
	}else{
		cout << "==== applyHomography -> DIFFERENT from identity" << endl;
		img_2.copyTo(original);
		cv::warpPerspective(img_1,  // input image
                            compensated,        // output image
                            homography,
                            cv::Size(img_1.cols, img_1.rows), INTER_LINEAR);// size of output image
		original.copyTo(img_1);
		compensated.copyTo(img_2);
		cout << endl << "==== STEP 10 complete: distortion fix applied" << endl <<endl;
	}
}

cv::Mat AntiShake::getHomographyFeedbackController(Mat &img_1, Mat &img_2, int loops){
	// STEP 1: RE-ESCALE SO THE BIGGEST RESOLUTION IS 590x(something smaller than 590)
	Mat workImage1, workImage2;
	double scale = 1.0/(MAX(img_1.rows,img_1.cols)/590.0);
    
	workImage1.create(scale*img_1.rows, scale*img_1.cols, img_1.type());
	workImage2.create(scale*img_2.rows, scale*img_2.cols, img_2.type());
    
	cv::resize(img_1, workImage1, workImage1.size());
	cv::resize(img_2, workImage2, workImage2.size());
	cout << "=== STEP 0 complete: RE-ESCALE" << endl;
    
	// LETS NOW START TO ITERATE IN ORTHER TO get a Homography matrix and reffine it
	Mat homography;
	vector<cv::Mat> Hs, eigenvalues;
	vector<double> dets;
    
	int loopCounter = 0;
	do{
		loopCounter++;
		try {
			// Calc homography matrix, its determinant and eigenvalues for this iteration;
			homography = antiShake(workImage1, workImage2);  // exceptions could appear here...
			double det = determinant(homography);
			Mat eigen;
			cv::eigen(homography, eigen);
			cout << endl << "==== STEP 9: HOMOGRAPHY: " << endl << homography << endl << "determinant: "<< det << endl << "eigenvalues: "<< eigen << endl << endl;
            
			// Checks if the determinant is small enough. If not, the transformation could be awful.
			if(abs(det-1.0) < 0.1){
				Hs.push_back(homography);
				eigenvalues.push_back(eigen);
				dets.push_back( abs(det - 1) );
                
				applyHomography(homography, workImage1, workImage2);
                
				//Checks if the error has decreased in the last iteration:
				int size = dets.size();
				if(size > 2){
					if(dets[size-1] > dets[size-2]){
						cout << "==== POP BACK" << endl;
						//Remove last element of the vectors
						Hs.pop_back();
						eigenvalues.pop_back();
						dets.pop_back();
						break;
					}
				}
			}else{
				homography = (Mat_<double>(3,3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
				break;
			}
            
		} catch (Exception &e) {
			cout << "exception found in the function getHomographyFeedbackController. ERROR: " << e.err << endl;
			homography = (Mat_<double>(3,3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
		}
	}while(loopCounter < loops || homography.empty());
    
	// CALCULATES RESULTANT HOMOGRAPHY:
	Mat resultantH = (Mat_<double>(3,3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
	for (unsigned int position = 0; position < Hs.size(); ++position) {
		resultantH = (Hs[position])*resultantH;
	}
	return resultantH;
}

// WARP 2 PICTURES
cv::Mat AntiShake::antiShake(Mat &img_1, Mat &img_2) {
	Mat workImage1, workImage2;
    
	img_1.copyTo(workImage1);
	img_2.copyTo(workImage2);
	cout << "=== STEP 1 complete: RE-ESCALE" << endl;
    
	// STEP 2: COMPENSATE BRIGHTNES
	compensateBrightness(workImage1, workImage2, workImage1, workImage2);
	cout << "=== STEP 2 complete: compensateBrightness" << endl;
    
	// STEP 3: BLUR EVERYTHING TO NORMALIZE THE SOURCE IMAGES
	compensateBlurriness(workImage1, workImage2, workImage1, workImage2, 3);
	cout << "=== STEP 3 complete: compensate Blurriness" << endl;
    
	// STEP 4: SOBEL OPERATOR
	sobelOperator(workImage1, workImage1, workImage2, workImage2, 3, 1);
	cout << "=== STEP 4 complete: sobelOperator" << endl;
    
	// STEP 5: KeyPoint Detection:
	//	cv::FeatureDetector *detector = new cv::DenseFeatureDetector()
	//	cv::FeatureDetector *detector = new cv::GFTTDetector();
	//	cv::FeatureDetector *detector = new cv::MSER();
	//	cv::FeatureDetector *detector = new cv::OTB();
	//	cv::FeatureDetector *detector = new cv::SIFT();
	//	cv::FeatureDetector *detector = new cv::StarFeatureDetector();
	//	cv::FeatureDetector *detector = new cv::SURF(400);
	//	cv::FeatureDetector *detector = new cv::BRISK();
	cv::FeatureDetector *detector = new cv::FastFeatureDetector(5, true);
	std::vector<KeyPoint> keypoints_1, keypoints_2;
	detector->detect(workImage1, keypoints_1);
	detector->detect(workImage2, keypoints_2);
	cout << "==== STEP 5 complete: keypoints detected, (keypoints1.size(), keypoints2.size()) = (" << keypoints_1.size() << ", " << keypoints_2.size() << ")" << endl;
	delete(detector);
    
	// STEP 6: Calculate descriptors (feature vectors)
	// The extractor can be any of (see OpenCV features2d.hpp):
	//	cv:: DescriptorExtractor *extractor = new cv::ORB();
	//	cv:: DescriptorExtractor *extractor = new cv::SIFT();
	//	cv:: DescriptorExtractor *extractor = new cv::SURF(400);
	//	cv:: DescriptorExtractor *extractor = new cv::BRISK();
	//	cv:: DescriptorExtractor *extractor = new cv::FREAK();
	cv:: DescriptorExtractor *extractor = new cv::BriefDescriptorExtractor();
	Mat descriptors_1, descriptors_2;
	extractor->compute(workImage1, keypoints_1, descriptors_1);
	extractor->compute(workImage2, keypoints_2, descriptors_2);
	cout << "==== STEP 6 complete: extract descriptors" << endl;
	delete(extractor);
    
    
	// STEP 7: Get Matches
	// Tries the algorithm in one direction
	vector<DMatch> good_matches;
	std::vector<Point2f> pts1, pts2;
    
	//	int numberOfMatches = MIN(MAX(25, 0.1*MIN(keypo ints_1.size(), keypoints_2.size())),250);
	int numberOfMatches = MAX(25, 0.1*MIN(keypoints_1.size(), keypoints_2.size()));
	this->getBestMatches(numberOfMatches , good_matches, pts1, pts2, descriptors_1, descriptors_2, keypoints_1, keypoints_2);
//	Mat img_matches;	// TODO ERASE WHEN RUNNING IN MOBILE
//	drawMatches(workImage1, keypoints_1, workImage2, keypoints_2, good_matches,
//                img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(),
//                DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
//	displayWindow(img_matches, "MATCHES");
	cout << "==== STEP 7 complete: finished matching descriptors: " << numberOfMatches << endl;
    
    
	// STEP 8: Find Homography:
	int index = 0;
	vector<uchar> inliers(pts1.size(), 0);
	Mat homography = getHomography(pts1, pts2, inliers, index);
	cout << "==== STEP 8 complete: finished calculating right homographY." << endl;
    
	return homography;
}

// FILLS matches, points1 and points 2 vectors
void AntiShake::getBestMatches(int nthNumber, std::vector<DMatch> &matches,
                               vector<Point2f> &pts1, vector<Point2f> &pts2, Mat descriptors_1,
                               Mat descriptors_2, vector<KeyPoint> keypoints_1,
                               vector<KeyPoint> keypoints_2) {
	//-- STEP A: Matching descriptor vectors using BruteForceMatcher
	BFMatcher matcher(NORM_L1, true);
	//	FlannBasedMatcher matcher;
	matcher.match(descriptors_1, descriptors_2, matches);
    
	//-- STEP B: gets just the first N matches with the smaller value for distance (N=nthNumber)
	std::nth_element(matches.begin(),    					// initial position
                     matches.begin() + nthNumber - 1, // position of the sorted element
                     matches.end());     								// end position
	matches.erase(matches.begin() + nthNumber, matches.end()); // remove all elements after the nthNumber(th)
	//-- STEP C: Eliminates the worst fetched points
	double meanDistance = 0;
	for (unsigned int i = 0; i < matches.size(); i++) {
		Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
		Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
		double dist = sqrt(pow((p1.x - p2.x),2) + pow((p1.y - p2.y),2));
		meanDistance += dist;
	}
	meanDistance = meanDistance/matches.size();
	//	cout << " ==== mean distance = " << meanDistance << endl;
	std::vector<DMatch> new_matches;
	//	cout<< "mean distance = (px) " << meanDistance << endl;
	for (unsigned int i = 0; i < matches.size(); i++) {
		Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
		Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
		double dist = sqrt(pow((p1.x - p2.x),2) + pow((p1.y - p2.y),2));
		if(dist <= 0.4*meanDistance){
			pts1.push_back(keypoints_1[matches[i].queryIdx].pt);
			pts2.push_back(keypoints_2[matches[i].trainIdx].pt);
			new_matches.push_back(matches[i]);
		}
	}
	//	cout << "==== MATCHES SIZE: "<< new_matches.size()<< endl;
    
	if(new_matches.size() <= 30){
		for (unsigned int i = 0; i < matches.size(); i++) {
			Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
			Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
			double dist = sqrt(pow((p1.x - p2.x),2) + pow((p1.y - p2.y),2));
			if(dist <= 1.05*meanDistance){
				pts1.push_back(keypoints_1[matches[i].queryIdx].pt);
				pts2.push_back(keypoints_2[matches[i].trainIdx].pt);
				new_matches.push_back(matches[i]);
			}
		}
	}
	matches = new_matches;
}

// Shows the image in a window, allowing it to be saved in a
void AntiShake::displayWindow(Mat image, string fileName, bool mightSave) {
	namedWindow(fileName); //Define the window
	imshow(fileName, image);
	if (mightSave) {
		fileName.append(".jpg");
		imwrite(fileName, image); // Saves the image
	}
}

// Shows the image in a window
void AntiShake::displayWindow(Mat image, string filename) {
	displayWindow(image, filename, false);
}

// Prints the given info String
void AntiShake::readme(string info) {
	std::cout << info << std::endl;
}

AntiShake::~AntiShake() {
}

