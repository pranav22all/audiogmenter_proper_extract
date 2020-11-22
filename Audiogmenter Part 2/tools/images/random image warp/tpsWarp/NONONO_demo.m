%xGrid is the number of distance between consecutive perturbed pixels in
%the x axis
%yGrid is the number of distance between consecutive perturbed pixels in
%the y axis
%xNoise is the size of the random perturbation in th x axis
%yNoise is the size of the random perturbation in th y axis
%I actually don't know exactly what maxChange stands for.
%it seems we get a more natural image if we use small grids.

load 'samples\gatto.mat' 'tmp';
IM1 = imread('samples\first.jpg');
%IM2 = imread('samples\second.jpg');
IM2 = tmp;
%IM3 = imread('samples\third.jpg');

%IM1 = imresize(IM1,[227,227]);
IM2 = imresize(IM2,[227,227]);
%IM3 = imresize(IM3,[227,227]);

xGrid = 8;
yGrid = 10;
xNoise = 10;
yNoise = 5;
maxChange = 20;
%newIM1 = changeImage22(IM1, xGrid, yGrid, maxChange);

xGrid = 8;
yGrid = 8;
xNoise = 10;
numPunti=4;
maxChange = 16;
newIM2 = changeImage_Interp(IM2, xGrid, yGrid,xNoise,numPunti, maxChange);

xGrid = 24;
yGrid = 18;
xNoise = 16;
yNoise = 16;
maxChange = 40;
%newIM3 = changeImage(IM3, xGrid, yGrid, xNoise, yNoise, maxChange);

%figure, imshow([IM1,newIM1])
figure, imshow([IM2,newIM2],[]),axis on;
%figure, imshow([IM3,newIM3])