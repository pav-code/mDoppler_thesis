%% Machine Learning Online Class - Exercise 4 Neural Network Learning

%  Instructions
%  ------------
% 
%  This file contains code that helps you get started on the
%  linear exercise. You will need to complete the following functions 
%  in this exericse:
%
%     sigmoidGradient.m
%     randInitializeWeights.m
%     nnCostFunction.m
%
%  For this exercise, you will not need to change any code in this file,
%  or any other files other than those mentioned above.
%

%% Initialization
clear all; 
close all; clc

%% Setup the parameters you will use for this exercise
input_X = 110; %110  % 110x146 Input Images of Digits (monochrome)
input_Y = 146; % 146
input_Depth = 1;
input_layer_size  = input_X*input_Y*input_Depth; 
hidden_layer_size = 45;         % 25 hidden units
num_labels = 3;                 % 10 labels, from 1 to 10   
num_string = 'W_M';

% (note that we have mapped "0" to label 10)

sTrained = 'false';
%% =========== Part 1: Loading and Visualizing Data =============
%  We start the exercise by first loading and visualizing the dataset. 
%  You will be working with a dataset that contains handwritten digits.
%

% Load Training Data
fprintf('Loading and Visualizing Data ...\n')

if strcmp(sTrained,'true')
    load('fileTag.mat');
    load('fileMatrix.mat');
else
    sDir = './../TrainingMWHalfSecond90/';
    sFile = dir(strcat(sDir,'*.png'));
    iCount = 1;
    %aFileTag;

    % Label Data
    for iFile=1:size(sFile,1)
      if regexp(sFile(iFile).name,num_string) == 1
          aFileTag(iCount) = 1;
          iCount = iCount + 1;
     elseif regexp(sFile(iFile).name,'R_') == 1
         aFileTag(iCount) = 2;      
         iCount = iCount + 1;          
      elseif regexp(sFile(iFile).name,'B_') == 1
          aFileTag(iCount) = 3;      
          iCount = iCount + 1;          
      end
    end

    % Input Data
    iCount = 1;
    for iFile=1:size(sFile,1)  
      %regexp(str,'W_STFT|R_STFT')  
      if regexp(sFile(iFile).name,'B_|W_|R_')
        aImg = imread(strcat(sDir, sFile(iFile).name)); 
       % load(strcat(sDir, sFile(iFile).name));   
       % aImg = struct2cell(aImg);
       % aImg = cell2mat(aImg);
       % aImg = 10*aImg./min(aImg);
        X(iCount,:) = double(reshape(aImg(:,:,1), ...
           [1,input_X*input_Y*input_Depth]));
        iCount = iCount + 1;
      end
    end
    
    save('fileTag.mat','aFileTag');
    save('fileMatrix.mat','X');
end
y = aFileTag';
m = size(X, 1);
%displayData(X(1:20, :),input_Y);

%% ================ Part 6: Initializing Pameters ================
%  In this part of the exercise, you will be starting to implment a two
%  layer neural network that classifies digits. You will start by
%  implementing a function to initialize the weights of the neural network
%  (randInitializeWeights.m)

fprintf('\nInitializing Neural Network Parameters ...\n')

initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);

% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

%% =================== Part 8: Training NN ===================
%  You have now implemented all the code necessary to train a neural 
%  network. To train your neural network, we will now use "fmincg", which
%  is a function which works similarly to "fminunc". Recall that these
%  advanced optimizers are able to train our cost functions efficiently as
%  long as we provide them with the gradient computations.
%
fprintf('\nTraining Neural Network... \n')
tic
%  After you have completed the assignment, change the MaxIter to a larger
%  value to see how more training helps.
options = optimset('MaxIter', 200);

%  You should also try different values of lambda
lambda = 0.01;

% Create "short hand" for the cost function to be minimized
costFunction = @(p) nnCostFunction(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, X, y, lambda);

% Now, costFunction is a function that takes in only one argument (the
% neural network parameters)
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% Obtain Theta1 and Theta2 back from nn_params
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));



%% ================= Part 9: Visualize Weights =================
%  You can now "visualize" what the neural network is learning by 
%  displaying the hidden units to see what features they are capturing in 
%  the data.

fprintf('\nVisualizing Neural Network... \n')

% displayData(Theta1(:, 2:end));
weight_grid = 6;
for i = 1:(weight_grid*weight_grid)
    subplot (weight_grid,weight_grid,i)
    imagesc(reshape((Theta1(i,2:end)),[110,146]))
end

fprintf('\nProgram paused. Press enter to continue.\n');
%pause;

%% ================= Part 10: Implement Predict =================
%  After training the neural network, we would like to use it to predict
%  the labels. You will now implement the "predict" function to use the
%  neural network to predict the labels of the training set. This lets
%  you compute the training set accuracy.

pred = predict(Theta1, Theta2, X);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
traintimer = toc
%% ================= Part 11: Testing Data =================
sDir = './../TrainingMWHalfSecond90/Testing/';
sFile = dir(strcat(sDir,'*.png'));
tic
% Label the test data
iCount = 1;
for iFile=1:size(sFile,1)
  if  regexp(sFile(iFile).name,num_string) == 1
     aTestTag(iCount) = 1;
     iCount = iCount + 1;
 elseif regexp(sFile(iFile).name,'R_') == 1
     aTestTag(iCount) = 2;      
     iCount = iCount + 1;          
  elseif regexp(sFile(iFile).name,'B_') == 1
     aTestTag(iCount) = 3;      
     iCount = iCount + 1;          
  end
end

% Shape the input iamge data
iCount = 1;
for iFile=1:size(sFile,1)  
  %regexp(str,'W_STFT|R_STFT')  
  if regexp(sFile(iFile).name,'B_|W_|R_')
    aImg = imread(strcat(sDir, sFile(iFile).name)); 
    %load(strcat(sDir, sFile(iFile).name));             %
  %  aImg = struct2cell(aImg);
   % aImg = cell2mat(aImg);
    
    X_test(iCount,:) = double(reshape(aImg(:,:,1), ...
       [1,input_X*input_Y*input_Depth]));
    iCount = iCount + 1;
  end
end

% for iFile=1:size(sFile,1)
%   aImg = imread(strcat(sDir, sFile(iFile).name));  
%   testSet(iFile,:) = double(reshape(aImg(:,:,1), ...
%            [1,input_X*input_Y*input_Depth]));   
% end

pred = predict(Theta1, Theta2, X_test);
trueValue = aTestTag';
%trueValue = ones(size(sFile,1),1)*2;

fprintf('\nTest Set Accuracy: %f\n', mean(double(pred == trueValue)) * 100);
testimer = toc
%% Debug statements:
% imagesc(reshape(X(100,:),[110,146]))

