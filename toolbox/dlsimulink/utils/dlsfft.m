function [P,Y] = dlsfft(X,n,dim)
%DLSFFT A DLS standard wrapper for the MATLAB fft() function
%   A wrapper for the standard fft() function, which calculates the 
%   Discrete Fourier Transform (DFT) of an array X. In terms of required 
%   inputs, this function can be used interchangeably with fft(). However, 
%   this function outputs the single-sided spectrum of the input data, 
%   which is more intuitive and useful for most applications.
%
%   Inputs:
%   X - vector, matrix, or multidimensional array to compute DFT, double
%   n - to define the n-point DFT, uint32
%   dim - dimension along which to calculate FFT, uint32
%
%   Outputs:
%   P - single-sided spectrum, double
%   Y - raw fft() spectrum, double
%
%   See also FFT
%
%   DLSimulink Toolbox

arguments (Input)
    X (:,:) double
    n (1,1) uint32 = 0
    dim (1,1) uint32 = 0
end

arguments (Output)
    P (:,:) double
    Y (:,:) double
end

% Depending on input variables, different usage of fft()
if n == 0
    Y = fft(X);
elseif n ~= 0 && dim == 0
    Y = fft(X,n);
elseif n ~= 0 && dim ~= 0
    Y = fft(X,n,dim);
else
    disp('Invalid input arguments.\n')
end

% Get length of output FFT array
L = length(Y);

% Extract one sided spectrum
P2 = abs(Y/L);
P = P2(1:L/2+1);
P(2:end-1) = 2*P(2:end-1);

end