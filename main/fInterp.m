function [aInter] = fInterp(aArray, n)
sInterp = 'PCHIP';
X1 = linspace(1,size(aArray,1),size(aArray,1));
Xq = linspace(1,length(X1),n);
aInter = zeros(n, size(aArray,2),3);

for i = 1:size(aArray,2)
  xTemp = aArray(:,i,1);
  yTemp = aArray(:,i,2);
  zTemp = aArray(:,i,3);
  
  aInter(:,i,1) = interp1(X1,xTemp,Xq,sInterp);
  aInter(:,i,2) = interp1(X1,yTemp,Xq,sInterp);
  aInter(:,i,3) = interp1(X1,zTemp,Xq,sInterp);
end

% figure
% plot(X1,aArray(:,10,1),'o');
% hold on
% plot(Xq,aInter(:,10,1),'-');
% legend('samples',sInterp);
% hold off
end