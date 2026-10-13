function sloper_export(expdir,expname,x,y,X,Y,u,v,w,U,V,W)
%SLOPER_EXPORT Summary of this function goes here
%   Detailed explanation goes here

% arguments (Input)
%     inputArg1
%     inputArg2
% end
% 
% arguments (Output)
%     outputArg1
%     outputArg2
% end

filename = fullfile(expdir,expname);

% Flatten
U = U(:);
V = V(:);
W = W(:);

u = u(:);
v = v(:);
w = w(:);

X = X(:);
Y = Y(:);

x = x(:);
y = y(:);


% Triangulated mesh exports
T = table(X, Y, W, 'VariableNames', {'x_mm','y_mm','dZ_mm'});
writetable(T, filename + "-dZ-TriangulatedMesh.txt",'Delimiter','tab');

T = table(X, Y, U, 'VariableNames', {'x_mm','y_mm','dX_mm'});
writetable(T, filename + "-dX-TriangulatedMesh.txt", 'Delimiter','tab');

T = table(X, Y, V, 'VariableNames', {'x_mm','y_mm','dY_mm'});
writetable(T, filename + "-dY-TriangulatedMesh.txt", 'Delimiter','tab');

% Original FEA mesh exports
T = table(x, y, w, 'VariableNames', {'x_mm','y_mm','dZ_mm'});
writetable(T, filename + "-dZ-FEAMesh.txt", 'Delimiter','tab');

T = table(x, y, u, 'VariableNames', {'x_mm','y_mm','dX_mm'});
writetable(T, filename + "-dX-FEAMesh.txt", 'Delimiter','tab');

T = table(x, y, v, 'VariableNames', {'x_mm','y_mm','dY_mm'});
writetable(T, filename + "-dY-FEAMesh.txt", 'Delimiter','tab');

end