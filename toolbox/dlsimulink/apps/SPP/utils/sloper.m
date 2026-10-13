function [X,Y,U,V,W,S_lon,S_sag,x,y,u,v,w] = sloper(data0,Nxx,Nyy,FID,order,sym,is2D)

arguments (Input)
    data0 (:,:) double
    Nxx (1,1) double = 100
    Nyy (1,1) double = 20
    FID (1,1) logical = 0
    order (1,1) int16 = 3
    sym (1,1) logical = 0
    is2D (1,1) logical = 1
end

arguments (Output)
    X (:,:) double
    Y (:,:) double
    U (:,:) double
    V (:,:) double
    W (:,:) double
    S_lon (:,:) double
    S_sag (:,:) double
    x (:,:) double
    y (:,:) double
    u (:,:) double
    v (:,:) double
    w (:,:) double
end

try

if ~is2D
    Nyy = 1;
    sym = false;
end

x = data0(:,2);
y = data0(:,3);
u = data0(:,5);
v = data0(:,6);
w = data0(:,7);

xmin = min(x) + 0.01;
xmax = max(x) - 0.01;
ymin = min(y) + 0.01;
ymax = max(y) - 0.01;

xv = linspace(xmin,xmax,Nxx);
yv = linspace(ymin,ymax,Nyy);

[X,Y] = meshgrid(xv,yv);
X = X.';
Y = Y.';

if is2D
    U = griddata(x,y,u,X,Y,'linear');
    V = griddata(x,y,v,X,Y,'linear');
    W = griddata(x,y,w,X,Y,'linear');
else
    [x, sortIdx] = sort(x);
    y = y(sortIdx);
    u = u(sortIdx);
    v = v(sortIdx);
    w = w(sortIdx);
    U = interp1(x, u, xv(:), 'linear');
    V = interp1(x, v, xv(:), 'linear');
    W = interp1(x, w, xv(:), 'linear');
end

if sym
    xv = [xv, flip(xv)];
    yv = [yv, flip(yv)];
    X = [X; -1.*flipud(X)];
    Y = [Y; Y];
    W = [W; flipud(W)];
end

if FID
    for j = 1:Nyy
        c = polyfit(xv,W(:,j),order);
        W(:,j) = polyval(c,xv);
    end
end

dx = abs(xmax - xmin)/Nxx;
dy = abs(ymax - ymin)/max(Nyy,1);

if is2D
    [dWdy,dWdx] = gradient(W,dy,dx);
else
    dWdx = gradient(W,dx);
    dWdy = zeros(size(W));
end

S_lon = 1e6 * atan(dWdy);
S_sag = 1e6 * atan(dWdx);

x = x.';
y = y.';
u = u.';
v = v.';
w = w.';

catch ME
    errLine = ME.stack(1).line;
    error('sloper.m line %d: %s', errLine, ME.message);
end

end