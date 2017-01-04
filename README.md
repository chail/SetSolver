# SetSolver
Solver for set card game built with OpenCV and Swift

Set is an awesome card game where each card is determined by 4 features. The features are color: red, green, violet; shape: 
oval, diamond, squiggle; number: one, two, three; and fill: filled, open, hatched (81 cards in total). The goal of the game 
is to find a set of 3 cards such that the cards are either all the same or all different for each feature.

##Setup Instructions
1. Download [OpenCV 3][open-cv] for iOS.
2. Unzip the downloaded directory.
3. Open the `.xcodeproj` file and drag the unzipped opencv2.framework into the project directory.

##How it works
###Detecting Cards
The first step was to detect the set cards from an image -- this was done by finding the largest contours on the input 
image and taking those as cards. Next, the cards had to be warped to fit a rectangular shape and normalized in size. The final
step was to compare each test card to the training cards, and determine which one was most similar. This approach worked 
reasonably well for determining the number and shapes of the cards. Many thanks to this great [blog post][blog-post] which was 
really helpful for this part of the project.
###Detecting Fill
After the cards have been normalized, doing a second contour detection on each card could tell us the fill of the card. Hatched
cards have the most contours, filled cards have the least, and open cards have two contours per number of shapes.
###Detecting Color
To detect color, I converted the image to HSV, and looked at a histogram of hue values for each card. A challenge in this process
was the color of the background light, which would confound the hues in the card. I determined color by comparing the total number
of pixels in the red, violet, and green ranges, but the whitebalancing aspect of the image could still be improved.
###Putting it together
The last part was writing the solution algorithm and putting together the user interface. The algorithm is not all that 
difficult -- given 3 cards, you need to check that for each feature, they are all unique or all different, which can be done 
using a set data structure and computing the size of it. I added a feature so that the user and adjust the cards, if the image
processing algorithm makes mistakes. Then, the user can ask for hints or the complete solution to the set of cards.

[open-cv]:http://opencv.org/
[blog-post]:http://arnab.org/blog/so-i-suck-24-automating-card-games-using-opencv-and-python
