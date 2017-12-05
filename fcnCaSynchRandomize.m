function fcnCaSynchRandomize(arrDFF,arrStats)
    
    % flag - update in real time?
    vFlgVis = 0;
    
    % # iterations to perform
    vNumIters = 1000;
    
    % get size info from original data
    vNfrms = size(arrDFF.arr,1);
    vNROIs = size(arrDFF.arr,2);
    
    % plot original synchronous events for reference
    arrSynch = sum(arrDFF.arrbin,2);
    
    disp(' ')
    
    if vFlgVis
        % plot original experimental data
        figure('Name','synchronous events - real data','Position',[50,450,1100,250],'color','w');
        plot(arrSynch)
        hold on;
        plot([1 vNfrms],[1 1],'r--');
        hold off;
        xlim([1,inf])
        % plot new figure for showing randomized data
        hFigRand = figure('Name','synchronous events - randomized','Position',[50,50,1100,250],'color','w');
        hPltRand = plot(arrSynch);
        hold on;
        plot([1 vNfrms],[1 1],'r--');
        hold off;
        xlim([1,inf])
        ylim([0,10])
        % and figure for showing randomized event array
        hFigRstr = figure('Name','thresholded events','Position',[50,150,1300,600],'color','w');
        hImgRstr = imagesc(arrDFF.arrbin');
        ylim([1,inf])
        colormap(flipud(gray))
        caxis([0,0.5])  
    end
    
    % initialize arrays to hold results
    vProb = 0;
    vStatKS = 0;
    arrDFFbin = arrDFF.arrbin * 0;
    arrSynchRand = sum(arrDFFbin,2);
    arrHstSynchRandInt = (histcounts(arrSynchRand,(-0.5:1:11.5)))*0; 
    
    for kk = 1:vNumIters
        %reset randomized binary event array to zero
        arrDFFbin(:,:) = 0;
        % use same # events for each ROI; assign random times & insert into binary array
        for ii = 1:vNROIs
            if arrStats.Nevts(ii)>0
                for jj = 1:arrStats.Nevts(ii)
                    vRndFrm = randi([1 vNfrms-100],1,1);
                    arrDFFbin(vRndFrm:vRndFrm+arrStats.Durs(jj,ii),ii) = 1;
                end
            end
        end
        
        % evaluate synchronous activity from binary array
        arrSynchRand = sum(arrDFFbin,2);
        arrHstSynchRand = histcounts(arrSynchRand,(-0.5:1:11.5)); 
        arrHstSynchRandInt = arrHstSynchRandInt+arrHstSynchRand;
        
        % calc 
        [h, p, ks2stat] = kstest2(arrSynch, arrSynchRand);
        vProb = vProb+p;
        vStatKS = vStatKS+ks2stat;
        
        % if requested, plot on screen for each iteration
        if vFlgVis
            set(hImgRstr,'CData', arrDFFbin');
            set(hPltRand,'YData',arrSynchRand);
            drawnow;
            disp(['   iteration # : ',num2str(kk),' ;  max synch evts = ', ...
                  num2str(max(arrSynchRand))])
         else
            if kk/100 == round(kk/100)
                disp(['   done iterations # ',num2str(kk)])
            end
        end
        
    end
    
    % calc histogram for original experimental data
    arrHstSynch = histcounts(arrSynch,(-0.5:1:11.5));
    % normalize accumulated randomized histograms by # iterations
    arrHstSynchRand = arrHstSynchRandInt/vNumIters;
    vProb = vProb/vNumIters;
    vStatKS = vStatKS/vNumIters;
    disp(' ')
    disp(['   KS comparison:  stat = ',num2str(vStatKS), ...
          ' ;  prob = ',num2str(vProb)]);
    disp(' ')
     
    % plot standard histograms of original and randomized data
    figure;
    plot((0:1:11), arrHstSynch,'k');
    hold on;
    plot((0:1:11), arrHstSynchRand,'r');
    hold off;
    % and in semilog form
    figure;
    semilogy((0:1:11), arrHstSynch,'k');
    hold on;
    semilogy((0:1:11), arrHstSynchRand,'r');
    hold off;
    % and the ratio
    arrHstSynchRatio = arrHstSynchRand./arrHstSynch;
    figure;
    plot((0:1:11),arrHstSynchRatio);
    
    
    
end
