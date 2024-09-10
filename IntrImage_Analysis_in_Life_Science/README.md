# Introductory Course to Image Analysis in Life Science using FiJi

clone from: 
https://github.com/leclercsimon74/2024_Introductory-Course-to-Image-Analysis-in-Life-Science_FiJi

**Important ressources:**
- ImageJ website for plugins: https://imagej.net/ij/
- Advice for macro writing: https://imagej.net/ij/developer/macro/macros.html
- **Built-in Macro function**: https://imagej.net/ij/developer/macro/functions.html


## Why scripting?
- Improve reproducibility on image analysis
- Automating repetitive tasks in image analysis
- Creating custom image processing workflows
- Batch processing large sets of images
- Extending ImageJ's functionality without writing Java plugins

A simple example, going from this movie of a bacterial 🦠 growth

![rounding_assay.gif](Images/Readme_images/rounding_assay.gif)

To, with the help of a simple macro

![Macro_example_macro.png](Images/Readme_images/Macro_example_macro.png)

At a result table showing the shape evolution of the bacterial population

![Macro_example_result.png](Images/Readme_images/Macro_example_result.png)

The objective of this course is to learn the basic of ImageJ Macro language, with the almighty `Recorder` and the basic block of programmation such as `for` loop and `if` condition. At the end, **you** should have the tools and knowledge to be able to write your own macro!

## Requirement
- Have ImageJ or [Fiji](https://fiji.sc/) version 1.53t or later installed on your computer (Help=>Update)
- Download the [repositery](https://github.com/leclercsimon74/2024_Introductory-Course-to-Image-Analysis-in-Life-Science_FiJi/archive/refs/heads/main.zip) to have all images

## The basics
### Hello World!

```Java
// This is a comment. The script starts below.

// Print "Hello World!" to the log window
print("Hello World!");

// Show a dialog box with the message
showMessage("Greetings", "Hello World!");
```

In the code is presented 2️⃣ ways to display the classical `Hello World!`:

- the `print()` function, that will print the content between parenthesis in a log window
- the `showMessage()` function that will open an interactive window displaying the message, with a 🆗 button to continue the code

To run the macro, go to `Plugin` > `New` > `Macro`, copy-paste the code and click the `Run` button. Et voila!

In ImageJ Macro language, all variables needs to be declared:

```Java
// Initialization
a = 6;
b = 3.0;
c = "one";

// some operation
d = a + b;

// result
print(d);
```

There is multiple type of variable, such as integer (`a`) and float (`b`) numbers and string (`c`), a serie of letter. Some variable can be combined, while other cannot and will throw an error.

There is a nice selection of mathematical and string maniplation already defined in ImageJ to simplify our life.

On the mathematical side:
```Java
// Initialization
a = 6;
b = 3.0;

// Mathematical print
print(pow(a,b)); //a to the power of b
print(sqrt(a)); // square root
print(round(b)); // round
print(abs(-b)); // absolute
```

On the string side:
```Java
// Initialization
a = "Hello";
b = "World";

// string manipulation print
print(a+" "+b); // concatenate
print(substring(a, 2, 4)); // substring
print(replace(b, "ld", "m")); // replace
print(startsWith(a, "He")); // check the start of the string
print(endsWith(b, "ld")); // check the send of the string
```

Lucky for us, ImageJ have now a nice auto-completion system, that can be enable with `Ctrl+Space`, and which contain most commun expression.

### The Recorder
One of the strong point of ImageJ is how easy it is to use and protoype an image analysis pipeline. Once we have an idea of what to do with a given image, the easiest is to turn on the `Recorder` (`Plugins` -> `Macros` -> `Recorder`). The recorder will record _most_ of the action realized in ImageJ, from image opening to selecting a window or running some process.

Let's make our first full Macro!

1. Open the `Recorder` (`Plugins` -> `Macros` -> `Recorder`)
2. Open the Blobs image (`File` -> `Open Sample` -> `Blobs`)
3. Run a Gaussian Blur with sigma of 3 (`Process` -> `Gaussian Blur...`)
4. Set a Otsu threshold (`Image` -> `Adjust` -> `Threshold...`)
5. Set the parameters to measure as area, centroid and shape (`Analyze` -> `Set Measurements...`)
6. Analyze the segmented image (`Analyze` -> `Analyze Particle...`)
7. Then on the `Recorder`, click on `Create` to automatically generate the macro

Congratulation on your first Macro!

You should have something similar to the following:
![Macro_1st_macro.png](Images/Readme_images/Macro_1st_macro.png)

Let's clean up a little bit to make it more readable:
![Macro_1st_macro_clean.png](Images/Readme_images/Macro_1st_macro_clean.png)

Close all the ImageJ window (except the Macro editor!), then click on the `Run` 🏃 button on the macro editor to rerun the analysis.

You can try changing the gaussian blur sigma value, the type of threshold and see how it impacts the analysis part.


```Java
//open the image
run("Blobs (25K)");

//Processing
run("Gaussian Blur...", "sigma=4");

//Segmentation
setAutoThreshold("Yen");
setOption("BlackBackground", true);
run("Convert to Mask");

//Analyze
run("Set Measurements...", "area centroid shape redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity display clear");
```

Most of the time, an image analysis pipeline will be as in this example:

- Open an image
- Preprocessing steps
- Segmentation steps
- Analysis steps

### The `Run` function
You may have observed a pattern in the first macro: the `run` function is called multiple times. And all the parameter(s) of this function is string.

The first parameter is the name of the process called, such as `Convert to Mask`. In the case the name ends with `...`, this means that this process require some additional parameters, which are describe in the second string, such as `sigma=4` for the `Gaussian Blur...` by example.

In this case, string manipulation, and mainly concatenation, is very important to be able to dynamically modify some parameters.

### Window manipulation
Most image manipulation, such as `run("Gaussian Blur...", "sigma=4");` will do the calculation in place, meaning that the original image will be replaced by the new image, resulting in the loss of the original image (except if saved on the disk).

In some case, such scenario is not recommended, and a duplicate of the image can be made in `Image` -> `Duplicate...`. This open a window prompting for a name and some extra option based on the image dimension.

But then you stumble accross an interesting trouble with ImageJ: most image manipulation are done on the image selected.
> [!WARNING]
> How can you change the selected image?

The easiest way is to use the `selectImage()`, which take the image name as argument (in this case, 'blobs-1.gif'). It is also possible to get the image name with the `getTitle()` command. Finally, it is possible to rename an image with the `rename()` command in order to simplify the naming convention of ImageJ that can quickly be a little messy.

The same code as above, but with some window manipulation in order to keep the original image intact:
```Java
//open the image
run("Blobs (25K)");
rename("original"); // -> renaming the window to original

//processing
run("Duplicate...", " "); // -> duplicate the original image without changing the generated name
rename("segmentation"); // -> renaming it
name = getTitle(); // -> save its name in a variable. it is a string
selectImage(name); // -> select the duplicate image
run("Gaussian Blur...", "sigma=4");

//Segmentation
setAutoThreshold("Yen");
setOption("BlackBackground", true);
run("Convert to Mask");

//Analyze
run("Set Measurements...", "area centroid shape redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity display clear");
```

> [!TIP]
> A lot of process will make the calculation in place! The one that does not tends to give you the option to keep the original image(s).

### Segmentation: Mask and ROI

To do most analysis, you are more than likely required to have a mask. There is two ways to generate them:

- Through thresholding (as shown before)
- Through a selection (`Edit` -> `Selection` -> `Create Mask`)

Sometimes, it is required to clean or manipulate the mask. This can be done using the MorphoLibJ (located in the Plugins. If not, installation is required, see at the bottom), using the `Morphological Filters` in `Filter`.

![Morpholib_binary_erosion.png](Images/Readme_images/Morpholib_binary_erosion.png)

Multiple binary operations is available, such as `erosion`, `dilation`, `closing` (erosion of the dilation), `opening` (dilation of the erosion) and `filling holes` by example. There is also the 3D version of them if working with Z-stack. The ImageJ legacy version of such operation is also present in `Process` -> `Binary`.

After cleaning the mask, it is time to extract some data from it, and for this ImageJ has a nice ROI (Region Of Interest) manager. It is possible to call it `Analyze` -> `Tools` -> `ROI Manager...`. It will open the following window.

![ROI_manager.png](Images/Readme_images/ROI_manager.png)

However, one of the most classical way to call the ROI Manager is through the through the `Analyze` -> `Analyze Particle`. Just be sure to `Analyze` -> `Set Measurements` to the one you want to measure before. Once in the `Analyze Particle` menu, you can selection the option to add the different object in the ROI manager.

![AnalyzeParticle_annoted.png](Images/Readme_images/AnalyzeParticle_annoted.png)

Then with the selection of the correct window and the ROI manager, it is possible to measure multiple parameters.

In the example below, the mask (blue box) has been analyzed, then the original image (red box) has been selected and the `Multi-measure` from the ROI manager (located in `More`, purple arrow) has been used to measure the properties of each object, presented in the result table. Of course, all these steps can be automatize whitin a Macro.

![Multimeasure_ex.png](Images/Readme_images/Multimeasure_ex.png)

## Programming
So far, we did not really did programming by itself. The `Macro Recorder` is doing most of the job for us, and we just did some clean up. The next step will involve a tiny bit more of writing, but once again, ImageJ simplify the work for us a little bit with the auto-completion tool. However, we still need to understand a couple of notion: the `for` loop and the `if` condition.

### The `for` loop
This can be translated as 'Do this job X times', or for example 'Stir the pot 10 times'.

In the ImageJ Macro language, it requires a little more information:

- such as the initialization stage (where we start, at 0 stir)
- A condition (when to stop, at 10 stir)
- An increment/decrement (how to change each time, 1 stir at a time)
- The code to be executed in each iteration (stir)

An example of a for loop, where `i` is set to 0, should be less than 10, and increment by one (++) at each loop.
```Java
for (i = 0; i < 10; i++) {
	//code here
}
```

> [!NOTE]
> Try to modify the above example so it prints the increment of `i`! You can also try modify the initial stage, the end condition and the increment step.

> [!CAUTION]
> Be carefull of infinite loop, loop which the condition will always be `false`, and as such, the program will **never** exit the loop!

ImageJ macro simplify our life with the auto-completion active, just typing `for` should prompt the following hints, with the first one being the classical `for` loop, the second a loop that go through the Result table and the last one that go through a list of file. These are the most commun loop, and you can use them as a template to loop through anything.

![for_loop_autocompletion.png](Images/Readme_images/for_loop_autocompletion.png)

There is also other kind of loop, such as the `while(condition){}`, where the condition is first evaluated and if `true`, it enters the loop until the condition is `false`, and the `do {...} while(condition);` that will excecute the loop first, then check the condition to determine to continue or not the loop.

### The `if` condition
Check if the condition is `true`, and `if` it is the case, realize the action. For example, if I am tired, I stop to stir the pot.

In the ImageJ Macro language, it requires that the condition stated to be a boolean, either `true` or `false`.

A boolean is returned in some case by some ImageJ function (for example: `is("grayscale");` to check if an image is gray or not) or by some operation:

- `==` to check equality
- `!=` to check inequality
- `>`, `<`, `>=`, `<=` for comparison (bigger, smaller than)

We can define a piece of code to activate if the condition does not apply (`false`) with the `else` keyword. In a same manner, we can chain condition checking with the `else if` keyword. Keep in mind that in this case, the program will check each `if` condition in order, and will only excecute the code of the first `true` statement. Finally, it is possible to check multiple condition at the same time with using boolean check, with `&&` for `and` (condition1 **AND** condition2, where both condition needs to be `true`) and `||` for `or` (condition1 **OR** condition2, where only one of the condition needs to be `true`).

```Java
a = 5;
b = 3.0;
to_print = true;

if (a == b){
	print("a is bigger than b");
}
else if (a <= b){
	print("a is smaller than b");
}
else {
	print("a is equal to b");
}

if (to_print || a > b){
	print("a is smaller than b");
	}
```

> [!NOTE]
> Try to correct the above example so it prints the correct statement!

> [!TIP]
> It is possible to combine a `loop` and a `if` statement to `break` the loop!
> ```Java
> for (i = 0; i < 10; i++) {
> 	// do or print something here!
>	if (i==5) break
>}```

### Functions
You define what a function is. Most of the time, if a piece of code is repeated, this can be a candidate for a function. A function is defined as `function(arguments){code}`, and can return a value with the `return` keyword, see the example below.

```Java
function sum(i, j) {
  return i + j;
}

a = 5;
b = 3.0;

print(sum(a,b))
```

> [!NOTE]
> Comment and describe excactly what a function is doing, or you may get lost very quickly!

## Extra

### Image Brightness/Contrast
By selecting `Image` -> `Adjust` -> `Brightness/Contrast...`, it will display the current image histogram and the possiblity to adjust the brightness and contrast of the image. Note that this does NOT change the data of the image, it is solely to make the image content easier to see, specially with a click on the `Auto` button. However, if you change the depth of the image (`Image` -> `Type`, the number of bit  by pixel), you will modify the data based on the current minimum and maximum!

![Adjust_BC.png](Images/Readme_images/Adjust_BC.png)

### Colors
Images can have multiple channels, represeneted by color. The `Image` -> `Color` allow you to manipulate this, by either splitting, merging or arrange channels. One easy way though is to pick the `Channels Tool...`, enable the `Composite`, then selecting the channel to show or not. It is then possible to transform the image as RGB, ready to export.

![channel_tool.png](Images/Readme_images/channel_tool.png)

### Stack
In a similar way, some images will have a Zstack, which can be manipulated with the `Image` -> `Stack`. From adding slices to remove only some, as well as realizing a Z projection or Z profile, a lot of tools are available to enable you a full control on Zstack.

![Stack_ex.png](Images/Readme_images/Stack_ex.png)

### Process
ImageJ has a lot of simple processing step that may be usefull, albeit a little obscure on how they are doing things.

A couple of them are usefull in case of uneven illumination, `Enhance Local Contrast (CLAHE)` and `Substract Background`. In the below example, you can see the original image on the left (red 🔴 rectangle) with its associated histogram, the CLAHE (default settings) correction (cyan 🔵 rectangle) and the background substraction (purple 🟣 rectangle). All images brightness and contrast are adjusted on the CLAHE correction. You can see that the CLAHE heavily adjust the histogram, pushing some values to higher value, which result in some spike in the histogram. On the opposite side, the background substraction push the histogram on the left, eliminating small values. The choice of the method used to diminush the background is up to you.

![Background_correction.png](Images/Readme_images/Background_correction.png)

One last thing about the process is the `Image Calculator...`. This calculator allows you to do mathematical or logical operation between images. Below is a small macro that threshold an image, then using the image calculator, combine the original intensity with the mask so that only the object of interest gives signal.

```Java
run("Embryos");
run("Duplicate...", " ");
run("8-bit"); // RGB to 8 bit, required for the threshold
setAutoThreshold("Default");
setOption("BlackBackground", true);
run("Convert to Mask");
// Delete the scale
makeRectangle(877, 1045, 556, 155);
setBackgroundColor(0, 0, 0);
run("Clear", "slice");
run("Select None");
//clean the binary
run("Fill Holes");
run("Close-");
// image calculation
imageCalculator("AND create", "embryos.jpg","embryos-1.jpg");
```

![ImageCalculation_ex.png](Images/Readme_images/ImageCalculation_ex.png)

> [!NOTE]
> Some calculation may require to manipulate the mask value (which is by default 255). This can be done in the `Process` -> `Math`.

> [!TIP]
> Basic ImageJ, in the binary section, have very convenient function. 'fill holes', 'skeleton', 'contour' are all generating operation on the mask, that can be further manipulated. Do not hesitate to try them!

### Graphic User Interface (GUI)
ImageJ has a powerful tool to set up a user interface. You can found it in the following [link 🔗](https://imagej.net/ij/developer/macro/functions.html#D) called Dialog. This can be very useful to make a window with options for further processing or on-the-fly adjustment. The `Dialog.createNonBlocking("Title")` will create a window that allow you to interact with opened image before continuing. It can only be done in a script, and have the following structure:

- create a window
- add element(s)
- show the GUI
- grab the value(s) of the setup element(s)

Here is a small example

```Java
Dialog.createNonBlocking("Testing GUI");
Dialog.addCheckbox("Keep working", true);
Dialog.show();
condition = Dialog.getCheckbox();
print(condition);
```

It is possible to grab paths, images, choices... And so make a complete interface. It is also possible to combine with 1if' condition to make an adaptable interface.

## Exercices
We will solve the first exercise together, step by step. Other exercises, with the material, are here to try more scripting options on Fiji and with more type of data.

### Counting dots accross time
You can download the image by cliking the [link 🔗](Images/Yeast%20meiosis/C2-1B_MAX_010618_Hsp104Htb1_Meiosis_01_47_zproj_R3D_D3D-1.tif)

If you download the full repositery, the image to try on is `C2-1B_MAX_010618_Hsp104Htb1_Meiosis_01_47_zproj_R3D_D3D-1.tif`, located in the `Yeast meiosis` folder.

Below is a montage of the image, that consist in the maxiumum projection of yeast population undergoing a meiosis. One easy way to analyse these data is to count the number of dots progression accross time. We can also see while looking at the data that the dot size seems to decrease, so let's measure the average size as well.

![Yeast2_C2_Montage.png](Images/Readme_images/Yeast2_C2_Montage.png)

One method is:

- Start the recording
- Segmenting the nuclei with a `Threshold`. Check the different option effect on the resulting mask (`Stack histogram` or `Calculate threshold` for each image)
- Does the mask need some cleaning or processing?
- Set the measurement then analyze the particles. There is an option to summarize the result!
- Save the resulting table as CSV
- Curate the macro
- Import the data in Excel (be sure to replace the `.` by `,`) and make one or a couple of quick graphes showing the result

![Exercice 1 Result.png](Images/Readme_images/Exercice_1_Result.png)

Then try the macro that you just record and curate on the other image (in the same folder) [link 🔗](Images/Yeast%20meiosis/C1-2E_MAX_09122017_Nsr1Hsp104Meiosis_04_R3D_D3Dzproj-1.tif). Just try to understand why it mays not work on this dataset.

### Myelin segmentation
You can found the Electron microscope images (FIB-SEM) of the optic nerves of a mouse in the following [folder 🔗](Images/Optic_nerve_FIB-SEM).
In this case, we are trying to segment the myelin, this thick protective layer around neurons, that appear pitch black on the data.

Since the myelin is so black and uniform, it is easy to found a segmentation protocol (such as Triangle, or even a manual one). In this specific case, it will perform quite well, even if smaller myelin sheet may not be correctly segmented, and that some noises can be found.

Let's make a small macro, that is segmenting the myelin sheet, then clean the mask. Then let's try again, but this time by blurring (either with `Process` -> `Smooth` or `Process` -> `Filters` -> `Gaussian Blur...`) and compare the results. Finally, try on another image in the same folder and let's discuss why it performs slightly differently.

However, if you want to segment parts that are not extreme white or black in the image, you are likely to use a machine learning program. Again, FiJi have you cover with Weka (`Plugin` -> `Segmentation` -> `Trainable Weka Segmentation`). This is a pixel trainer and classifier. I recommend you to select a small part of the image of interest, and to reduce the size (a 1024x1024 allows to capture a lot, reduce the size by a factor 2 `Image` -> `Adjust` -> `Size...`) in order to speed up the process. Then you need to assign pixel to as many classes that you want/can. In the follow example, the first class is background, then we have the myelin, mitochondria and blood vessel. Just select with your favorite tool (`freehands selection` is perfect for that) and assign the selection to the class. Once you are satisfied, just click on train classifier and wait until it perfoms the training and classify the test image. You can then correct the image by adding the places where the model is wrong, and retrain, until your are satisfy. Then this model can be applied to other images.

![Weka_ex_1.png](Images/Readme_images/Weka_ex_1.png)

It is possible to manually adjust which parameters the model can use for the training in setting. Have a look at the [documentation](https://imagej.net/plugins/tws/) if you are interested.

### 3D embryo timelapse
You can found the images (66!) of embryo in the following [folder 🔗](Images/Time_course_embryo). These images are 3D, take some time to explore the data! Native Fiji is not very well adapted for 3D analysis. Most of the analysis will be done by slice of a stack, leading to... interesting trouble. You can have a quick try by segmenting the image (an Otsu thresholding do a perfect job), then a little bit of cleaning (like an opening, followed by a watershed) and finish with an analyze particle (just the size). You may have realized that the cell are quite oddly segmented, and that there is no continuation in 3D.

![Embryo-t=60.gif](Images/Readme_images/Embryo-t=60.gif)

Luckily for us, some plugins are working in 3D. We then come back to MorphoLib, which can do an opening in 3D, allowing to separate a little better the different cells. For the sake of simplicity, let's extract an image at the center of the embryo (slice 70?), apply a watershed, set the measurement for the area and shape descriptor, then on the measure particle be sure to activate the summarize. This summarize have the nice effect that it will **NOT** be erased/emptied when you do a new measurment, meaning that you can process the full folder of image with one macro and save the average result of the given slice in one table - a lot simplier to analyze by Excel!

![embryo-measure.png](Images/Readme_images/embryo-measure.png)

### Rounding assay
Let's go back to the beginning, and let's analyze the roundess of yeast budding ([link 🔗](Images/rounding_analysis)).

To make things a little more interesting, try to categorize the different level of roundess and count the number of cell in each categories!

