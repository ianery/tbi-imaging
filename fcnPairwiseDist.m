function [ arrDist ] = fcnPairwiseDist(arrXYZ)

    % arrXYZ = N x 3 array containing coordinates of neurons 

    arrDist = pdist(arrXYZ)';
    disp(' ')
    disp('pairwise distances:')
    disp(arrDist)
    vMeanDist = mean(arrDist);
    disp([' mean distance = ',num2str(vMeanDist)])
    disp(' ')
   
end

