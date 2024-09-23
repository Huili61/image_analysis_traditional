// clear
run("Close All");
Table.create("Summary");


// config <data/output_path>
folder_dic = "C:/Users/lihu/Desktop/homework/Chromatin/";
output_dir = "C:/Users/lihu/Desktop/homework/output/";

// create result list
file_names = newArray();
nucleus_areas = newArray();
hetero_areas = newArray();
nucleus_mean_intensities = newArray();
hetero_mean_intensities = newArray();
npc_counts = newArray();
npc_mean_fluorescences = newArray();

// get file list
file_list = getFileList(folder_dic);
// iteration
min_num = 0;
max_num=file_list.length;
for (i=min_num; i<max_num; i++) {
	file_name = file_list[i];
	if (endsWith(file_name, ".tif")){
		// open images
	   open(folder_dic + file_name);
       Table.reset("Summary");
	   
	   // split channel
	   run("Split Channels");
	   
	   // 1. nucleus (channel3, blue)
	   run("Set Measurements...", "area mean integrated redirect=C3-"+file_name+" decimal=3");
	   // 1.1 segmentation
	   selectImage("C3-"+file_name);
	   run("Duplicate...", "title=nucleus_mask_"+i);
	   // blur
	   run("Gaussian Blur...", "sigma=5");
	   setMinAndMax(0, 1200);
	   run("Enhance Contrast", "saturated=0.35");
	   // threshold
	   setAutoThreshold("Otsu dark no-reset");
       run("Convert to Mask");
       // fill holes
       run("Maximum...", "radius=15");
       run("Close-");
       run("Fill Holes");
       run("Minimum...", "radius=15");

       // 1.2 measure nucleus area and intensity
       run("Analyze Particles...", "size=0-Infinity show=Overlay summarize");
       nucleus_area = Table.get("Total Area", 0, "Summary");
       nucleus_mean_intensity = Table.get("Mean", 0, "Summary");
       
       // 2. heterochromatin (channel3, high intensity)
       // 2.1 segmentation
       selectImage("C3-" + file_name);
       run("Duplicate...", "title=heterochromatin_"+i);
       // threshold
       run("Enhance Contrast", "saturated=0.35");
	   setAutoThreshold("MaxEntropy dark no-reset");
       run("Convert to Mask");
       
       // 2.2 measure heterochromatin area
       // select common area of nucleus and heterochromatin mask
       imageCalculator("AND create", "heterochromatin_"+i,"nucleus_mask_"+i);
       selectWindow("Result of heterochromatin_"+i);
       // measure
       run("Analyze Particles...", "size=0-Infinity show=Overlay summarize");
       hetero_area = Table.get("Total Area", 1, "Summary");
       hetero_mean_intensity = Table.get("Mean", 1, "Summary");
       
       // 3. Nuclear Pore Complex  (channel1, red)
       run("Set Measurements...", "area mean integrated redirect=C1-"+file_name+" decimal=3");
       // 3.1 segmentation
	   selectImage("C1-"+file_name);
	   run("Duplicate...", "title=npc_mask_"+i);
	   // threshold
	   setAutoThreshold("Otsu dark no-reset");
	   run("Convert to Mask");
	   
	   // 3.2 create nucleus surface mask
	   selectImage("nucleus_mask_"+i);
	   // large
	   run("Duplicate...", "title=nucleus_mask_l_"+i);
	   run("Maximum...", "radius=10");
	   // small
	   run("Duplicate...", "title=nucleus_mask_s_"+i);
	   run("Minimum...", "radius=20");
	   imageCalculator("XOR create", "nucleus_mask_l_"+i, "nucleus_mask_s_"+i);
	   selectWindow("Result of nucleus_mask_l_"+i);
	   run("Rename...", "title=nucleus_surface_mask_"+i);

	   // 3.3 measure quantity and average fluorescence on surface 
	   imageCalculator("AND create", "npc_mask_"+i,"nucleus_surface_mask_"+i);
	   selectWindow("Result of npc_mask_"+i);
	   run("Analyze Particles...", "size=0-Infinity show=Overlay summarize");
	   npc_count = Table.get("Count", 2, "Summary");
	   npc_mean_fluorescence = Table.get("Mean", 2, "Summary");

       // save result to lists
       file_names[i] = file_name;
       nucleus_areas[i] = nucleus_area;
       hetero_areas[i] = hetero_area;
       nucleus_mean_intensities[i] = nucleus_mean_intensity;
       hetero_mean_intensities[i] = hetero_mean_intensity;
       npc_counts[i] = npc_count;
       npc_mean_fluorescences[i] = npc_mean_fluorescence;  
       
       // clean
       close("*");
	}
}

// save results
Table.create("Results");
Table.setColumn("file_name", file_names);
Table.setColumn("nucleus_area", nucleus_areas);
Table.setColumn("hetero_area", hetero_areas);
Table.setColumn("nucleus_mean_intensity", nucleus_mean_intensities);
Table.setColumn("hetero_mean_intensity", hetero_mean_intensities);
Table.setColumn("npc_count", npc_counts);
Table.setColumn("npc_mean_fluorescence", npc_mean_fluorescences);
Table.save(output_dir + "results0.csv");
