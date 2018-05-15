function [exy] = ellipse(xy,k)
%CONFELLIPSE2 Draws a confidence ellipse.
% CONFELLIPSE2(XY,CONF) draws a confidence ellipse on the current axes
% which is calculated from the n-by-2 matrix XY and encloses the
% fraction CONF (e.g., 0.95 for a 95% confidence ellipse).
% H = CONFELLIPSE2(...) returns a handle to the line.

% written by Douglas M. Schwarz
% schwarz@kodak.com
% last modified: 12 June 1998

n = size(xy,1);
mxy = mean(xy);

numPts = 181; % The number of points in the ellipse.
th = linspace(0,2*pi,numPts)';


p = 2; % Dimensionality of the data, 2-D in this case.

%k = finv(conf,p,n-p)*p*(n-1)/(n-p);
%k = 2.9960; %using conf = 0.95, p = 2, n = the length of the matrix xy, use R2009A at LRC computer
% Comment out line above and uncomment line below to use ftest toolbox.
%k = fdistinv(p,n-p,1-conf)*p*(n-1)/(n-p);

%[pc,score,lat] = princomp(xy);
% Comment out line above and uncomment 3 lines below to use ftest toolbox.
xyp = (xy - repmat(mxy,n,1))/sqrt(n - 1);
[u,lat,pc] = svd(xyp,0);
lat = diag(lat).^2;

ab = diag(sqrt(k*lat));
exy = [cos(th),sin(th)]*ab*pc' + repmat(mxy,numPts,1);

% Add ellipse to current plot
% h = line(exy(:,1),exy(:,2),'Clipping','off','LineStyle','-','Color',[0 0 0]/255,'LineWidth',4);
% %h = line(exy(:,1),exy(:,2),'Clipping','off','LineStyle','-','Color',[223 102 15]/255,'LineWidth',2.5);%[200 102 15]/255 orange [223 102 15]
% if nargout > 0
%     hh = h;
% end 
