function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

%Part 1: Feedforward
X = [ones(m,1) X];

for i = 1:m       %Loop over examples (Unregularized Cost Function)
  a_one = X(i,:)';
  a_two = sigmoid(Theta1*a_one);
  a_two = [1; a_two];
  a_three = sigmoid(Theta2*a_two);

  y_vec = zeros(num_labels,1);
  y_vec(y(i)) = 1;
  
  A = -1*y_vec.*log(a_three);
  B = (1-y_vec).*log(1 - a_three);
  J = J + sum(1/m * (A - B));
end

%Regularization added to the Cost[ J(Theta) ]
A = [Theta1(:,2:end)];
A = sum(sum(A.^2));
B = [Theta2(:,2:end)];
B = sum(sum(B.^2));

Reg = lambda/(2*m) * (A + B);

J = J + Reg;

%Part 2: Backpropagation
acc_Theta1 = 0; acc_Theta2 = 0;
for t = 1:m
  %StepOne: find z_2, z_3, a_1,a_2,a_3
  a_one = X(t,:)';
  z_two = Theta1*a_one;
  a_two = sigmoid(z_two);
  a_two = [1; a_two];
  z_three = Theta2*a_two;
  a_three = sigmoid(z_three);  
  
  %StepTwo: calc delta_3 (@ Output Layer - using direct relation h_theta(x) to y)
  y_vec = zeros(num_labels,1);
  y_vec(y(t)) = 1;  
  delta_three = (a_three - y_vec);
  
  %StepThree: calc delta_2 (@ Hidden Layer - using derivative)
  z_two_Mod = [100000; z_two];
  delta_two = ((Theta2)' * delta_three).* sigmoidGradient(z_two_Mod);
  
  %StepFour: Accumulate gradient for Theta1 and Theta2
  delta_two = [delta_two(2:end)];
  acc_Theta1 = acc_Theta1 + delta_two*(a_one)';
  acc_Theta2 = acc_Theta2 + delta_three*(a_two)';
end


Theta1_grad = 1/m .* acc_Theta1;
Theta2_grad = 1/m .* acc_Theta2;

%Part 3: Regularization
Theta1_grad(:,(2:end)) = Theta1_grad(:,(2:end)) + lambda/m * Theta1(:,(2:end));
Theta2_grad(:,(2:end)) = Theta2_grad(:,(2:end)) + lambda/m * Theta2(:,(2:end));

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
