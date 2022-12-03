//This macro analyses time series microscopy for fluorescence
//Regions of Interest ROIs are initialised by ML WEKA segmentation
//Cells are tracked over time by centering circle ROIs starting from initial over the nearest centroid
//It accepts time series data stored a a folder of sequential tif slices
//If stored as a stack (ND2 format for example, convert to slices first
//This program requires the mouse to interact with the Time Series Analyzer V3 plug-in
//The mouse must find the button to click through the dialogue, this may be display resolution-dependent
//For reference, this macro was scripted in 1920*1080p

// select first frame of time course for cell finding
//convert to RGB to collapse channels
open("C:/Users/mc01535/OneDrive - University of Surrey/Michael Clarke-Whittet MICROSCOPY/13JAN2022 MCW 571 571f 562f 563f/MPT5MNGmBSb/6jan2022_451_562_563_554_r1t001r1.tif");
run("RGB Color");
run("Trainable Weka Segmentation");
selectWindow("Trainable Weka Segmentation v3.3.2");

// input your classifier file path in the next line:
//call("trainableSegmentation.Weka_Segmentation.loadClassifier", "C:\\Users\\mc01535\\OneDrive - University of Surrey\\Classifier RGB.model");
//call("trainableSegmentation.Weka_Segmentation.getProbability");
waitForUser("Select Classifier", "Please choose or create a classifier model. Generate Probability map before continuing!");


// open many images in a folder as a sequential stack in directory specified
File.openSequence("C:/Users/mc01535/OneDrive - University of Surrey/Michael Clarke-Whittet MICROSCOPY/13JAN2022 MCW 571 571f 562f 563f/MPT5MNGmBSb/", "virtual bitdepth=24");

// convert probability map from weka segmentation to ROI mask
selectWindow("Probability maps");
run("Next Slice [>]");
run("Delete Slice");
run("Threshold...");
setAutoThreshold("Default dark");
run("Convert to Mask", "method=Default background=Dark calculate");
run("Close");
run("Erode");
run("Watershed")
run("Dilate");
//selectWindow("Trainable Weka Segmentation v3.3.2");
//close();
selectWindow("Probability maps");
saveAs("Tiff", "C:/Users/mc01535/OneDrive - University of Surrey/Michael Clarke-Whittet MICROSCOPY/13JAN2022 MCW 571 571f 562f 563fMPT5MNGmBSbStarting location.tif");

// Setup data collection parameters and filter ROIs. Measures to get co-ords
run("Set Measurements...", "area mean standard modal min centroid center perimeter integrated median skewness area_fraction stack redirect=None decimal=3");
run("Analyze Particles...", "size=0-400 display clear add stack");
roiManager("Deselect");
roiManager("multi-measure");
saveAs("Results", "C:/Users/mc01535/Downloads/Results1.csv");

//Identify ROIs after segmentation
number_objects = getValue("results.count");
current_object = (getValue("results.count") - getValue("results.count"));
WEKA_array = newArray(0,0);
WEKA_array = Array.trim(WEKA_array, 1);
Array.print(WEKA_array);

//Loop creating movable ROIs over initialised ROIs.
while (current_object +1 <= number_objects){
	xcord = getResultString("X",current_object);
	ycord = getResultString("Y",current_object);
	run("Specify...", "width=10 height=10 x=xcord y=ycord oval");
	roiManager("Add");
	//	Renumber ROI by passing to new array
	current_object = (current_object +1);
	roi_array2 = newArray(current_object,current_object);
	roi_array2 = Array.trim(roi_array2, 1);
	Array.print(roi_array2);
	WEKA_array = Array.concat(WEKA_array,roi_array2);
	WEKA_array = Array.trim(WEKA_array,1);
	Array.print(WEKA_array);
	roiManager("Select", WEKA_array);
	roiManager("Delete");
	}
print("ROIs reassigned");

// Clear results at this stage if satisfied
//can close probability map at this stage

//Center ROIs over centroid in next slice, runs through loaded stack
run("Time Series Analyzer V3");
setSlice(1);
run("Set Measurements...", "area mean standard modal min centroid center perimeter integrated median skewness area_fraction stack redirect=None decimal=3");
//run("Measure");

// (i = 2; i <= 271; i+=3) if redundant RGB channels are included to measure only 1 channel (G)
// (i = 1; i <= 90; i++)

for (i = 2; i <= 271; i+=3) {
    setSlice(i);
//    waitForUser("Please Recenter!","");
	run("IJ Robot", "order=Left_Click x_point=86 y_point=68 delay=500 keypress=[]");
	roiManager("Measure");
	}
print("Slices measured")

//while (getSliceNumber() +1 <= nSlices){
//	run("IJ Robot", "order=Left_Click x_point=86 y_point=68 delay=1000 keypress=[]");
//	roiManager("multi measure");
//	setSlice((getSliceNumber())+1);}

saveAs("Results", "C:/Users/mc01535/OneDrive - University of Surrey/Michael Clarke-Whittet MICROSCOPY/RESULTS/13JAN2022 MCW 571 571f 562f 563fMPT5MNGmBSb.csv");