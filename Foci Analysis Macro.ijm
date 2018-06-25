//This is a macro to automatically gather the areas captured
//by the Moments threshold algorithm in the selected window.
//This program collects results that should be thresholded
//according to minimum and maximum values determined by the user
close("*");
run("Clear Results"); 
dir = getDirectory("Choose a Directory");
fileList = getFileList(dir);
channel = getNumber("Please type the number of the channel to be analyzed", 1);
channel = toString(channel);

//open all .czi and .lsm files and analyze their foci. the results at the end will be for all of them
for (i = 0; i < fileList.length; i++){
	
	if((endsWith(fileList[i], ".czi")) || (endsWith(fileList[i], ".lsm"))){
		run("Bio-Formats Windowless Importer", "open=[" + dir + fileList[i] + "] " +
  "autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
		//open(dir + fileList[i]);
		AnalyzeFoci();
	}
}


function AnalyzeFoci(){
	
//first, determine if the selected window is a hyperstack
//if so, z-project the average intensity
	if(Stack.isHyperstack){
	run("Z Project...", "projection=[Average Intensity]");
	}
	imageTitle = getTitle();
	slices = nSlices;
	//next, if there is more than one slice, split the slices by color
	if(slices > 1){
	run("Split Channels");
	//select the first  split channel, duplicate it, and threshold using the moments algorithm
	selectWindow("C" + channel + "-" + imageTitle);
	}
	run("Duplicate...", " ");
	setAutoThreshold("Moments dark");
	run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//reduce the graininess of the image, then find all particles and measure them in the original
	//the results will be in the results window
	run("Despeckle");
	run("Analyze Particles...", "add");
	if(slices > 1){
		selectWindow("C" + channel + "-" + imageTitle);
	}
	roiManager("Measure");
	roiManager("Reset");
	close("*");

}
