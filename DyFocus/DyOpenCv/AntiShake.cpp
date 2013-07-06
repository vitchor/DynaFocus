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

#define MATCHES_MEAN_DIST 0
#define MATCHES_QUADRANTS 1
#define MATCHES_QUAD_PERIFERY 2
#define MATCHES_QUAD_CENTER 3
#define MATCHES_QUAD_DEFAULT 4

const std::string getCurrentDateTime();

// Singleton pattern:
AntiShake *AntiShake::instance;
AntiShake::AntiShake() {
	eye3x3 = (Mat_<double>(3, 3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
}
AntiShake *AntiShake::getInstance() {
	if (!instance) {
		instance = new AntiShake();
	}
	return instance;
}

cv::Mat AntiShake::fixPictures(Mat &img_1, Mat &img_2, int loops) {
	// Firstly we calculate the Homography matrix and refine it in the FeedbackController function:
	Mat H = getHomographyFeedbackController(img_1, img_2, loops);
	double det = determinant(H);
	cout << "STEP 11 final homography = " << endl << H << endl
    << " determinant = " << det << endl;
    
	//Secondly, lets transform the picture according to the calculated (resultant) smatrix.
	if (det > 1.0) {
		applyHomography(H, img_1, img_2);
		cout << "STEP 12 fixed original pictures 1->2" << endl;
		return H;
	} else {
		Mat H2 = H.inv();
		applyHomography(H2, img_2, img_1);
		cout << "STEP 12 fixed original pictures 2->1 " << endl;
		return H2;
	}
}

// Applies the correction matrix to one image so it becomes closed to the other one
void AntiShake::applyHomography(Mat &homography, Mat &img_1, Mat &img_2) {
	Mat original, compensated;
	// STEP 10: Compare with identity and if not equal, applies correction
	if (determinant(homography) == 1.0) {
		cout << "==== applyHomography -> EQUALS IDENTITY " << endl;
	} else {
		cout << "==== applyHomography -> DIFFERENT from identity" << endl;
		img_2.copyTo(original);
		cv::warpPerspective(img_1,  // input image
                            compensated,        // output image
                            homography, cv::Size(img_1.cols, img_1.rows), INTER_LINEAR); // size of output image
		original.copyTo(img_1);
		compensated.copyTo(img_2);
		cout << endl << "==== STEP 10 complete: distortion fix applied" << endl
        << endl;
	}
}

/* It is a function that call getHoography multiple times and measure its accuracy.
 * If it runs the function more than the maxLoop value or if the accuracy measure
 * starts to increase, the loop stops*/
cv::Mat AntiShake::getHomographyFeedbackController(Mat &img_1, Mat &img_2,
                                                   int loops) {
    
	// STEP 0: RE-ESCALE, SO THE BIGGEST RESOLUTION IS 590x(something smaller than 590)
	Mat workImage1, workImage2;
	double scale = 1.0 / (MAX(img_1.rows,img_1.cols) / 590.0);
	workImage1.create(scale * img_1.rows, scale * img_1.cols, img_1.type());
	workImage2.create(scale * img_2.rows, scale * img_2.cols, img_2.type());
	cv::resize(img_1, workImage1, workImage1.size());
	cv::resize(img_2, workImage2, workImage2.size());
	cout << "=== STEP 0 complete: RE-ESCALE" << endl;
    
	// LETS NOW START TO ITERATE IN ORTHER TO get a Homography matrix and refine it
	Mat homography;
	vector<cv::Mat> Hs, eigenvalues;
	vector<double> dets;
	int loopCounter = 0;
	do {
		loopCounter++;
		try {
			homography = antiShake(workImage1, workImage2, MATCHES_QUADRANTS, 20); // exceptions could appear here... //STEPS 1 to 8 there.
			double det = determinant(homography);

            if (det == 1){
                homography = antiShake(workImage1, workImage2, MATCHES_QUADRANTS, 90);
                det = determinant(homography);
                cout << " ==== AntiShake::getHomographyFeedbackController: tryied antiShake(MATCHES_QUADRANTS, 20) without success. Now lets try antiShake(MATCHES_QUADRANTS, 90)" << endl;
            }
            if (det == 1){
                homography = antiShake(workImage1, workImage2, MATCHES_MEAN_DIST, 90);
                det = determinant(homography);
            }

            
			Mat eigen;
			cv::eigen(homography, eigen);
			cout << endl << "==== STEP 9: HOMOGRAPHY: " << endl << homography
            << endl << "determinant: " << det << endl << "eigenvalues: "
            << eigen << endl;
            
			// Checks if the determinant is small enough. If not, the transformation could be awful.
			if (abs(det - 1.0) < 0.15) {
				Hs.push_back(homography);
				eigenvalues.push_back(eigen);
				dets.push_back(abs(det - 1));
                
				applyHomography(homography, workImage1, workImage2);
                
				//Checks if the error has decreased in the last iteration:
				int size = dets.size();
				if (size > 2) {
					if (dets[size - 1] > dets[size - 2]) {
						cout << "==== POP BACK" << endl;
						//Remove last element of the vectors
						Hs.pop_back();
						eigenvalues.pop_back();
						dets.pop_back();
						break;
					}
				}
			} else {
				homography = (Mat_<double>(3, 3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
				break;
			}
		} catch (Exception &e) {
			cout
            << "exception found in the function getHomographyFeedbackController. ERROR: "
            << e.err << endl;
			homography = (Mat_<double>(3, 3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
		}
	} while (loopCounter < loops || homography.empty());
    
	// CALCULATES RESULTANT HOMOGRAPHY:
	Mat resultantH = (Mat_<double>(3, 3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
	for (unsigned int position = 0; position < Hs.size(); ++position) {
		resultantH = (Hs[position]) * resultantH;
	}
	if(abs(determinant(resultantH) - 1.0) < 0.12){
		return resultantH;
	}else{
		return Hs[0];
	}
}

void AntiShake::reduceDifferences(Mat &img_1, Mat &img_2, Mat &workImage1,
                                  Mat &workImage2) {
    
	img_1.copyTo(workImage1);
	img_2.copyTo(workImage2);
	cout << "=== STEP 1 complete: created workImage" << endl;
    
	// STEP 2: COMPENSATE BRIGHTNES
	compensateBrightness(workImage1, workImage2, workImage1, workImage2);
	cout << "=== STEP 2 complete: compensateBrightness" << endl;
    
	// STEP 3: BLUR EVERYTHING TO NORMALIZE THE SOURCE IMAGES
	compensateBlurriness(workImage1, workImage1, 7);
	compensateBlurriness(workImage2, workImage2, 7);
	cout << "=== STEP 3 complete: compensate Blurriness" << endl;
    
	// STEP 4: SOBEL OPERATOR
	sobelOperator(workImage1, workImage1, 5, 1);
	sobelOperator(workImage2, workImage2, 5, 1);
	cout << "=== STEP 4 complete: sobelOperator" << endl;
}

// WARP 2 PICTURES
cv::Mat AntiShake::antiShake(Mat &img_1, Mat &img_2, int matches_type, int numberOfMatches) {
    
	Mat workImage1, workImage2;
	reduceDifferences(img_1, img_2, workImage1, workImage2); // STEPS 1 to 4 here
    
	// STEP 5: KeyPoint Detection:
	cv::FeatureDetector *detector = new cv::FastFeatureDetector(4, true);
	std::vector<KeyPoint> keypoints_1, keypoints_2;
	detector->detect(workImage1, keypoints_1);
	detector->detect(workImage2, keypoints_2);
	cout
    << "==== STEP 5 complete: keypoints detected, (keypoints1.size(), keypoints2.size()) = ("
    << keypoints_1.size() << ", " << keypoints_2.size() << ")" << endl;
	delete (detector);
    
	// STEP 6: Calculate descriptors (feature vectors)
	cv::DescriptorExtractor *extractor = new cv::BriefDescriptorExtractor();
	Mat descriptors_1, descriptors_2;
	extractor->compute(workImage1, keypoints_1, descriptors_1);
	extractor->compute(workImage2, keypoints_2, descriptors_2);
	cout << getCurrentDateTime() << " ==== STEP 6 complete: extract descriptors" << endl;
	delete (extractor);
    
	// STEP 7: Get Matches
	vector<DMatch> good_matches;
	std::vector<Point2f> pts1, pts2;
    
	this->getBestMatches(matches_type, numberOfMatches, good_matches,
                         pts1, pts2, descriptors_1, descriptors_2, keypoints_1, keypoints_2,
                         workImage1.rows, workImage1.cols);
//	Mat img_matches;
//	drawMatches(workImage1, keypoints_1, workImage2, keypoints_2, good_matches,
//                img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(),
//                DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
//	displayWindow(img_matches, "MATCHES");
	cout << getCurrentDateTime() << " ==== STEP 7 complete: finished matching descriptors: "
    << numberOfMatches << endl;
    
	// STEP 8: Find Homography:
	int index = 0;
	vector<uchar> inliers(pts1.size(), 0);
	Mat homography = getHomography(pts1, pts2, inliers, index);
	cout << getCurrentDateTime() << " ==== STEP 8 complete: finished calculating right homographY."
    << endl;
    
	return homography;
}

//Selects best calculated homography. If both are considered impropry, returns identity matrix
cv::Mat AntiShake::getHomography(std::vector<Point2f> &pts1,
                                 std::vector<Point2f> &pts2, std::vector<uchar> &inliers, int &index) {
	Mat H12 = findHomography(Mat(pts1), Mat(pts2), inliers, CV_RANSAC, 1);
    
	Mat HReference = H12;
	index = 0;
    
	if (abs(HReference.at<double>(2, 0) > 0.0002)
        || abs(HReference.at<double>(2, 1) > 0.0002)) {
		index = 2;
        cout << "Identity matrix set in AntiShake::getHomography" << endl <<
        "Matrix = "<<HReference << endl;
		HReference = (Mat_<double>(3, 3) << 1, 0, 0, 0, 1, 0, 0, 0, 1);
	}
	return HReference;
}

void AntiShake::getBestMatches(int method, int nthNumber,
                               std::vector<DMatch> &matches, vector<Point2f> &pts1,
                               vector<Point2f> &pts2, Mat descriptors_1, Mat descriptors_2,
                               vector<KeyPoint> keypoints_1, vector<KeyPoint> keypoints_2, int img_y,
                               int img_x) {
    cout << getCurrentDateTime() << " ==== A" << endl;
	// -- STEP A: Matching descriptor vectors using BruteForceMatcher
	BFMatcher matcher(NORM_L1, true);
	matcher.match(descriptors_1, descriptors_2, matches);
	vector<DMatch> centerPoints, periferyPoints;
    cout << getCurrentDateTime() << " ==== AntiShake::getBestMatches" << endl;
	switch (method) {
        case MATCHES_MEAN_DIST:
            meanDistancesMatches(nthNumber, matches, keypoints_1, keypoints_2);
            break;
        case MATCHES_QUADRANTS:
            cout << getCurrentDateTime() << " ==== AntiShake::getBestMatches" << endl;
            meanDistancesMatches(0, matches, keypoints_1, keypoints_2);
            cout << getCurrentDateTime() << " ==== AntiShake::meanDistancesMatches" << endl;
            quadrantMethod(nthNumber, matches, keypoints_1, keypoints_2, img_y / 2,
                           img_x / 2, MATCHES_QUADRANTS, 0);
            cout << getCurrentDateTime() << " ==== AntiShake::quadrantMethod" << endl;
            break;
        case MATCHES_QUAD_PERIFERY:
            meanDistancesMatches(0, matches, keypoints_1, keypoints_2);
            quadrantMethod(nthNumber, matches, keypoints_1, keypoints_2, img_y / 2,
                           img_x / 2, MATCHES_QUAD_PERIFERY, 0.1);
            break;
        case MATCHES_QUAD_CENTER:
            meanDistancesMatches(0, matches, keypoints_1, keypoints_2);
            quadrantMethod(nthNumber, matches, keypoints_1, keypoints_2, img_y / 2,
                           img_x / 2, MATCHES_QUAD_CENTER, 0.4);
            break;
        case MATCHES_QUAD_DEFAULT:
            meanDistancesMatches(0, matches, keypoints_1, keypoints_2);
            centerPoints.insert(centerPoints.end(), matches.begin(), matches.end());
            periferyPoints.insert(periferyPoints.end(), matches.begin(),
                                  matches.end());
            quadrantMethod(nthNumber / 2, centerPoints, keypoints_1, keypoints_2,
                           img_y / 2, img_x / 2, MATCHES_QUAD_CENTER, 0.4);
            quadrantMethod(nthNumber, periferyPoints, keypoints_1, keypoints_2,
                           img_y / 2, img_x / 2, MATCHES_QUAD_PERIFERY, 0.4);
            matches = periferyPoints;
            matches.insert(matches.end(), centerPoints.begin(), centerPoints.end());
            break;
        default:
            break;
	}
    
	// Lets now populate the pts1 and pts2 vector
	for (unsigned int index = 0; index < matches.size(); ++index) {
		pts1.push_back(keypoints_1[matches[index].queryIdx].pt);
		pts2.push_back(keypoints_2[matches[index].trainIdx].pt);
	}
}

void AntiShake::quadrantMethod(int nthNumber, std::vector<DMatch> &matches,
                               vector<KeyPoint> keypoints_1, vector<KeyPoint> keypoints_2, int Y,
                               int X, int quad_type, double centerEdgeLimit) {
	/* quad2  |  quad1
	 * _______________
	 * quad3  |  quad4
	 * */
	std::vector<DMatch> quad1, quad2, quad3, quad4;
	//-- STEP ?: Lets separate wach point per quadrant
	for (unsigned int i = 0; i < matches.size(); i++) {
		Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
		Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
        
		if ((p1.x > X) && (p2.x > X) && (p1.y < Y) && (p2.y < Y)) {
			if (quad_type == MATCHES_QUADRANTS) {
				quad1.push_back(matches[i]);
			} else if ((p1.y < Y - Y * centerEdgeLimit)
                       || (p1.x > X + X * centerEdgeLimit)) {
				if (quad_type == MATCHES_QUAD_PERIFERY) {
					quad1.push_back(matches[i]);
				}
			} else {
				if (quad_type == MATCHES_QUAD_CENTER) {
					quad1.push_back(matches[i]);
				}
			}
            
		} else if ((p1.x < X) && (p2.x < X) && (p1.y < Y) && (p2.y < Y)) {
			if (quad_type == MATCHES_QUADRANTS) {
				quad2.push_back(matches[i]);
			} else if ((p1.y < Y - Y * centerEdgeLimit)
                       || (p1.x < X - X * centerEdgeLimit)) {
				if (quad_type == MATCHES_QUAD_PERIFERY) {
					quad2.push_back(matches[i]);
				}
			} else {
				if (quad_type == MATCHES_QUAD_CENTER) {
					quad2.push_back(matches[i]);
				}
			}
		} else if ((p1.x < X) && (p2.x < X) && (p1.y > Y) && (p2.y > Y)) {
			if (quad_type == MATCHES_QUADRANTS) {
				quad3.push_back(matches[i]);
			} else if ((p1.y > Y + Y * centerEdgeLimit)
                       || (p1.x < X - X * centerEdgeLimit)) {
				if (quad_type == MATCHES_QUAD_PERIFERY) {
					quad3.push_back(matches[i]);
				}
			} else {
				if (quad_type == MATCHES_QUAD_CENTER) {
					quad3.push_back(matches[i]);
				}
			}
		} else if ((p1.x > X) && (p2.x > X) && (p1.y > Y) && (p2.y > Y)) {
			if (MATCHES_QUADRANTS) {
				quad4.push_back(matches[i]);
			} else if ((p1.y > Y + Y * centerEdgeLimit)
                       || (p1.x > X + X * centerEdgeLimit)) {
				if (quad_type == MATCHES_QUAD_PERIFERY) {
					quad4.push_back(matches[i]);
				}
			} else {
				if (quad_type == MATCHES_QUAD_CENTER) {
					quad4.push_back(matches[i]);
				}
			}
		}
	}
    
	int minSize = min(min(quad1.size(), quad2.size()),
                      min(quad3.size(), quad4.size()));
	vector<vector<DMatch> > allQuads;
	if (minSize == 0) {
		if (!quad1.empty())
			allQuads.push_back(quad1);
		if (!quad2.empty())
			allQuads.push_back(quad2);
		if (!quad3.empty())
			allQuads.push_back(quad3);
		if (!quad4.empty())
			allQuads.push_back(quad4);
        
		if (allQuads.empty() || allQuads.size() < 3) {
			cout << " ==== ERROR, less than 3 quadrants contain points" << endl;
		} else {
			cout << " ==== Number of good quadrants: " << allQuads.size()
            << " of 4" << endl;
		}
	} else if (minSize >= nthNumber) {
		minSize = nthNumber; // increasing this number makes the algorithm go slower. So it shouldn't be very big
	}
    
	// if minSize wasn't null, the allQuads will be empty, so we populate it
	if (allQuads.empty()) {
		allQuads.push_back(quad1);
		allQuads.push_back(quad2);
		allQuads.push_back(quad3);
		allQuads.push_back(quad4);
	}
    
	// Getting the best matches for each vector and unifying them into the unique allPoints vector
	vector<DMatch> allPoints;
	for (unsigned int index = 0; index < allQuads.size(); ++index) {
		vector<DMatch> quad = allQuads[index];
		filterElements(quad, minSize);			// Gets the best matches
		allPoints.insert(allPoints.end(), quad.begin(), quad.end()); // append the vectors together
	}
    
	matches = allPoints;
}

void AntiShake::filterElements(std::vector<DMatch> &matches, int nthNumber) {
	std::nth_element(matches.begin(),	// initial position
                     matches.begin() + nthNumber - 1,// position of the sorted element
                     matches.end());	// end position
	matches.erase(matches.begin() + nthNumber, matches.end()); // remove all elements after the nthNumber(th)
}

/*
 * Filters all points by the meanDistance between the pts1 and pts2
 * */
void AntiShake::meanDistancesMatches(int nthNumber,
                                     std::vector<DMatch> &matches, vector<KeyPoint> keypoints_1,
                                     vector<KeyPoint> keypoints_2) {
    
	//-- STEP A: Finds mean distance
	double meanDistance = 0;
	for (unsigned int i = 0; i < matches.size(); i++) {
		Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
		Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
		double dist = sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2));
		meanDistance += dist;
	}
	meanDistance = meanDistance / matches.size();
    
    //	steb B: filters the points by mean Distance
	std::vector<DMatch> new_matches;
	for (unsigned int i = 0; i < matches.size(); i++) {
		Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
		Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
		double dist = sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2));
		if (dist <= 0.4 * meanDistance) {
			new_matches.push_back(matches[i]);
		}
	}
    
	// STEP C: if number of points is too low, filters again using a more loose filter
	if (new_matches.size() <= 30) {
		new_matches.clear();
		for (unsigned int i = 0; i < matches.size(); i++) {
			Point2f p1 = keypoints_1[matches[i].queryIdx].pt;
			Point2f p2 = keypoints_2[matches[i].trainIdx].pt;
			double dist = sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2));
			if (dist <= meanDistance) {
				new_matches.push_back(matches[i]);
			}
		}
	}
    
	if (nthNumber != 0) {
		//-- STEP B: gets just the first N matches with the smaller value for distance (N=nthNumber)
		filterElements(new_matches, nthNumber);
	}
	matches = new_matches;
}

void AntiShake::compensateBrightness(Mat &src1, Mat &src2, Mat &output1,
                                     Mat &output2) {
	// STEP A: Create copies
	src1.copyTo(output1);
	src2.copyTo(output2);
    
	// STEP B: Calculates overall brightness?
	double brightness1 = 0;
	double brightness2 = 1;
	for (int y = 0; y < output1.rows; y++) {
		for (int x = 0; x < output1.cols; x++) {
			brightness1 = brightness1 + output1.at<Vec3b>(y, x)[0]
            + output1.at<Vec3b>(y, x)[1] + output1.at<Vec3b>(y, x)[2];
			brightness2 = brightness2 + output2.at<Vec3b>(y, x)[0]
            + output2.at<Vec3b>(y, x)[1] + output2.at<Vec3b>(y, x)[2];
		}
	}
	brightness1 = brightness1 / ((output1.rows) * (output1.cols));
	brightness2 = brightness2 / ((output2.rows) * (output2.cols));
    
	// STEP C: Equalizes brightness:
	double brightDiff, beta;
	beta = abs(brightness1 - brightness2) / 50;
	if (brightness1 > brightness2) {
		brightDiff = brightness1 / brightness2;
		for (int y = 0; y < output2.rows; y++) {
			for (int x = 0; x < output2.cols; x++) {
				output2.at<Vec3b>(y, x)[0] = saturate_cast<uchar>(
                                                                  brightDiff * (output2.at<Vec3b>(y, x)[0]) + beta);
				output2.at<Vec3b>(y, x)[1] = saturate_cast<uchar>(
                                                                  brightDiff * (output2.at<Vec3b>(y, x)[1]) + beta);
				output2.at<Vec3b>(y, x)[2] = saturate_cast<uchar>(
                                                                  brightDiff * (output2.at<Vec3b>(y, x)[2]) + beta);
			}
		}
	} else {
		brightDiff = brightness2 / brightness1;
		for (int y = 0; y < output1.rows; y++) {
			for (int x = 0; x < output1.cols; x++) {
				output1.at<Vec3b>(y, x)[0] = saturate_cast<uchar>(
                                                                  brightDiff * (output1.at<Vec3b>(y, x)[0]) + beta);
				output1.at<Vec3b>(y, x)[1] = saturate_cast<uchar>(
                                                                  brightDiff * (output1.at<Vec3b>(y, x)[1]) + beta);
				output1.at<Vec3b>(y, x)[2] = saturate_cast<uchar>(
                                                                  brightDiff * (output1.at<Vec3b>(y, x)[2]) + beta);
			}
		}
	}
}

// Blur both images so blurriness will not continue to be a difference but a common caracteristic
void AntiShake::compensateBlurriness(Mat &src, Mat &output, int oddNumber) {
	blur(src, output, Size(oddNumber, oddNumber), Point(-1, -1));
}

void AntiShake::sobelOperator(Mat &src, Mat &output, int scale, int delta) {
	int ddepth = CV_16S;
    
	GaussianBlur(src, output, Size(3, 3), 0, 0, BORDER_DEFAULT);
    //	blur( src1, output1, Size( blurSize, blurSize), Point(point, point) );
    
	if (output.type() == 16) {
		/// Convert it to gray
		cvtColor(output, output, CV_RGB2GRAY);
	}
	/// Generate grad_x and grad_y
	Mat grad_x, grad_y, grad;
	Mat abs_grad_x, abs_grad_y;
    
	int border = BORDER_ISOLATED;
	/// Gradient X
	//Scharr( src_gray, grad_x, ddepth, 1, 0, scale, delta, BORDER_DEFAULT );
	Sobel(output, grad_x, ddepth, 1, 0, 3, scale, delta, border);
	convertScaleAbs(grad_x, abs_grad_x);
    
	/// Gradient Y
	//Scharr( src_gray, grad_y, ddepth, 0, 1, scale, delta, BORDER_DEFAULT );
	Sobel(output, grad_y, ddepth, 0, 1, 3, scale, delta, border);
	convertScaleAbs(grad_y, abs_grad_y);
    
	/// Total Gradient (approximate)
	addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad);
	grad.copyTo(output);
    
	grad_x.release();
	grad_y.release();
	abs_grad_x.release();
	abs_grad_y.release();
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

// Get current date/time, format is YYYY-MM-DD.HH:mm:ss
const std::string getCurrentDateTime() {
    time_t     now = time(0);
    struct tm  tstruct;
    char       buf[80];
    tstruct = *localtime(&now);
    // Visit http://www.cplusplus.com/reference/clibrary/ctime/strftime/
    // for more information about date/time format
    strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
    
    return buf;
}

AntiShake::~AntiShake() {
}

