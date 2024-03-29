% script to build Figure 8: where do words fall?
% general format:
% run plotting function
% tidy plot (ticks, ranges)
% export
% exportfig(h,[figpath 'Fig_' figID],'Color',color,'Format',format,'Resolution',dpi)


clear all; close all

% where are the data? Intermediate results too large for GitHub
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

localpath = '../Analysis code/';

% style sheet
run figure_properties

invertCloseness = -1;  % so that identical to Post = 1, and identical to Pre = -1;

% kernel density vector: same for all!
% XI = linspace(0.005,0.995,100);

% which data for examples
type = 'Learn';  % 'Learn'
N = 35;
iBin = 3; % 5 ms
iSession = 7;

figsize  = [10 15 11 4];
figalldens = [10 15 15 4];
    
% which example type: determine color
switch type
    case 'Learn'
        Mcolor = [0 0 0]; colours.learning.marker;
        Lcolor = [0 0 0]; colours.learning.line;
        MEdgeColor = [1 1 1];

    case 'Stable85'  %% not all data available for this analysis: Shuffled Stable datasets do not have locations
        Mcolor = colours.stable.marker;
        Lcolor = colours.stable.line;
        MEdgeColor = [1 1 1];

end

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')

%% process the shuffled data: get median locations
load([filepath 'LocationWord_Shuffled_N35_Learn'])
Nshuffles = numel(LocData(1).Shuffle);
Nsessions = numel(LocData);

for iB = 1:numel(binsizes)
    overShufmeds = [];
    for iSh = 1:Nshuffles
        allmeds = [];
        for iS = 1:Nsessions
            meds = zeros(numel(LocData(iS).Shuffle(iSh).Bins(iB).Word),1); 
            for iW = 2:numel(LocData(iS).Shuffle(iSh).Bins(iB).Word)
                meds(iW) = LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).Yspread(2);
            end
            meds(1) = [];  % eliminate empty word  
            allmeds = [allmeds; meds]; 
        end
        overShufmeds = [overShufmeds; allmeds];
        % make kernel density estimate over all sessions
        [KernelDens.Shufmeds{iSh,iB},XDens.Shufmeds{iSh,iB}]=ksdensity(allmeds,'Support',[0 1]);
    end
    [KernelDens.OverShufmeds{iB},XDens.OverShufmeds{iB}]=ksdensity(overShufmeds,'Support',[0 1]);
    
end

%% load everything we want to compare
load([filepath 'delta_PWord_Data_N' num2str(N) '_' type], 'DeltaWord');
load([filepath 'LocationWord_Data_N' num2str(N) '_' type]);
load([filepath 'PosData_' type],'PosLimits');

Nsessions = numel(DeltaWord);

%% correlation of mean(Closeness) and Distance per binsize analysis: some in wrong direction!

load([localpath 'Dictionary_Convergence_Analyses_N35_' type])

for iB = 1:numel(binsizes)
    for iS = 1:Nsessions
        IndexDiff.Median(iS,iB) = median(DeltaWord(iS).Bins(iB).Trials.IndexDifference);
    end
end

% figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 5 5]);
plotScatter([Data.DTrial.IConvergence(:)],[IndexDiff.Median(:)],[],[5 5],colours.learning,widths,...
    fontsize,fontname,'Convergence','Median closeness',0,M);
axis([-1 1 -1 1])

%% get per binsize density of medians, and gather IQRs and Closeness
allmeds = cell(numel(binsizes),1); alliqrs = cell(numel(binsizes),1); allCloseness = cell(numel(binsizes),1);
for iB = 1:numel(binsizes)
    for iS = 1:Nsessions
    % get all medians and IQRs
        meds = zeros(numel(LocData(iS).Bins(iB).Word),1); 
        iqrs = zeros(numel(LocData(iS).Bins(iB).Word),1); 
        closeness = zeros(numel(LocData(iS).Bins(iB).Word),1); 
        for iW = 2:numel(LocData(iS).Bins(iB).Word)
            meds(iW) = LocData(iS).Bins(iB).Word(iW).Yspread(2);
            iqrs(iW) = LocData(iS).Bins(iB).Word(iW).Yspread(3) - LocData(iS).Bins(iB).Word(iW).Yspread(1);
            closeness(iW) = DeltaWord(iS).Bins(iB).Trials.IndexDifference(iW);
        end
        meds(1) = [];  % eliminate empty word  
        iqrs(1) = [];
        closeness(1) = [];
        allmeds{iB} = [allmeds{iB}; meds]; 
        alliqrs{iB} = [alliqrs{iB}; iqrs];
        allCloseness{iB} = [allCloseness{iB}; closeness];
    end
    % make kernel density estimate over all sessions
    [KernelDens.meds{iB},XDens.meds{iB}]=ksdensity(allmeds{iB},'Support',[0 1]);
    [KernelDens.iqr{iB},XDens.iqr{iB}]=ksdensity(alliqrs{iB},'Support',[-0.0001 1]);
    [KernelDens.close{iB},XDens.close{iB}]=ksdensity(allCloseness{iB},'Support',[-1 1]);
    [KernelDens.abs_close{iB},XDens.abs_close{iB}]=ksdensity(abs(allCloseness{iB}),'Support',[0 1]);

end

%% locations of all sessions at one binsize
clear alpha
hSessionAll = figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',figsize,'Renderer','Painters'); 
    
for iS = 1:Nsessions
    % get median & IQR location of y-axis over all words
    y = zeros(numel(LocData(iS).Bins(iBin).Word),1); y_upper = zeros(1,numel(LocData(iS).Bins(iBin).Word)); y_lower = zeros(1,numel(LocData(iS).Bins(iBin).Word)); y_IQR = zeros(1,numel(LocData(iS).Bins(iBin).Word));
    for iW = 2:numel(LocData(iS).Bins(iBin).Word)
        y(iW) = LocData(iS).Bins(iBin).Word(iW).Yspread(2);
        y_upper(iW) = LocData(iS).Bins(iBin).Word(iW).Yspread(3);
        y_lower(iW) = LocData(iS).Bins(iBin).Word(iW).Yspread(1);
        y_IQR(iW) = y_upper(iW) - y_lower(iW);
    end
    %% all on one figure
    figure(hSessionAll); hold on
    
    % as function of Closeness
%     % IQR
%     line([DeltaWord(iS).Bins(iBin).Trials.IndexDifference';DeltaWord(iS).Bins(iBin).Trials.IndexDifference'],[y_lower;y_upper], 'Color',Lcolor)
%     % median
%     plot(DeltaWord(iS).Bins(iBin).Trials.IndexDifference,y,'o','Markersize',M,'MarkerFaceColor',Mcolor,'MarkerEdgeColor',MEdgeColor);
    
    % as function of IQR...
    % IQR
    line([y_IQR(2:end);y_IQR(2:end)],[y_lower(2:end);y_upper(2:end)], 'Color',Lcolor)
    % median
    plot(y_IQR(2:end),y(2:end),'o','Markersize',M,'MarkerFaceColor',Mcolor,'MarkerEdgeColor',MEdgeColor);
    
end
    
figure(hSessionAll); 
line([0 1],[PosLimits.ChoiceY(1) PosLimits.ChoiceY(1)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');
line([0 1],[PosLimits.ChoiceY(2) PosLimits.ChoiceY(2)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');
xlabel('Spread in maze location')
ylabel('Maze location')

FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_LocationvsIQR_' type],'-dsvg');    


%% density plot of median locations for example scatter

pos = get(get(hSessionAll,'Children'),'Position');
yaxislength = pos(4);

% 
% plot vertically
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[figsize(1:2),2, figsize(4)]);
hp = patch(KernelDens.meds{iBin}./sum(KernelDens.meds{iBin}),XDens.meds{iBin},colours.trials.marker,'EdgeColor',colours.learning.edge); hold on % data
alpha(0.3)
plot(KernelDens.OverShufmeds{iBin}./sum(KernelDens.OverShufmeds{iBin}),XDens.OverShufmeds{iBin},'Color',colours.shuf.line,'Linewidth',widths.plot)
line([0 1],[PosLimits.ChoiceY(1) PosLimits.ChoiceY(1)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');
line([0 1],[PosLimits.ChoiceY(2) PosLimits.ChoiceY(2)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');

xlabel('Density')
set(gca,'XLim',[0 0.05],'YLim',[0 1])
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_LocationDensityExample_' type],'-dsvg');    


%% density plot per bin size

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',figalldens);

for iB = 1:numel(binsizes)
    pData = KernelDens.meds{iB}./sum(KernelDens.meds{iB});
    pShuf = KernelDens.OverShufmeds{iBin}./sum(KernelDens.OverShufmeds{iBin});
    scle = max(max(pData,pShuf));
    
    % keyboard
    patch((iB*2-1) + pData./scle,XDens.meds{iB},colours.trials.marker,'EdgeColor',colours.learning.edge); hold on
    alpha(0.3)
    plot((iB*2-1) + pShuf./scle,XDens.OverShufmeds{iBin},'Color',colours.shuf.line,'Linewidth',widths.plot)
    
    line([(iB*2-1) (iB*2-1)]-0.5,[0 1],'Color',colours.shuf.line); % separate each by a vertical line
    xtcks(iB) = (iB*2-1) + 0.75;
end
line([0 (numel(binsizes)*2+1)],[PosLimits.ChoiceY(1) PosLimits.ChoiceY(1)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');
line([0 (numel(binsizes)*2+1)],[PosLimits.ChoiceY(2) PosLimits.ChoiceY(2)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');

set(gca,'XLim',[0 (numel(binsizes)*2+1)],'YLim',[0 1])

ylabel('Location')
xlabel('Bin size (ms)')
set(gca,'XTick',xtcks,'XTickLabel',{'1','2','3','5','10','20','50','100'});
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_LocationDensityByBins_' type],'-dsvg');    

%% Closeness and IQR - probably need to eliminate zero IQRs here...
for iB = 1:numel(binsizes)
    % find all non-zero IQRS;
    ixNz = alliqrs{iB} > 0;
    % plot those
    plotScatter((allCloseness{iB}(ixNz)),alliqrs{iB}(ixNz),[],[5 5],colours.learning,widths,...
    fontsize,fontname,'Closeness','Location Variation',0,M);
    axis([-1 1 0 1])
    title(['Binsize ' num2str(binsizes(iB))])
end

%% Closness vs median location
hClose = figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 5 8]); 
    
for iS = 1:Nsessions
    % get median & IQR location of y-axis over all words
    y = zeros(numel(LocData(iS).Bins(iBin).Word),1); y_upper = zeros(1,numel(LocData(iS).Bins(iBin).Word)); y_lower = zeros(1,numel(LocData(iS).Bins(iBin).Word)); y_IQR = zeros(1,numel(LocData(iS).Bins(iBin).Word));
    for iW = 2:numel(LocData(iS).Bins(iBin).Word)
        y(iW) = LocData(iS).Bins(iBin).Word(iW).Yspread(2);
        y_upper(iW) = LocData(iS).Bins(iBin).Word(iW).Yspread(3);
        y_lower(iW) = LocData(iS).Bins(iBin).Word(iW).Yspread(1);
    end
    % all on one figure
    figure(hClose); hold on
    
    % as function of Closeness
    % median
    plot(DeltaWord(iS).Bins(iBin).Trials.IndexDifference.*invertCloseness,y,'o','Markersize',M,'MarkerFaceColor',Mcolor,'MarkerEdgeColor',MEdgeColor);
        
end
    
figure(hClose); 
line([-1 1],[PosLimits.ChoiceY(1) PosLimits.ChoiceY(1)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');
line([-1 1],[PosLimits.ChoiceY(2) PosLimits.ChoiceY(2)],'Color',ClrChoice,'Linewidth',widths.plot,'Linestyle','--');
xlabel('Closeness to sleep epochs')
ylabel('Maze location')

FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_LocationvsCloseness_' type],'-dsvg');    


%% proportion by Closeness
divs = [-0.5 0.5]; % division of Closeness into terciles
CIalpha = 0.01;
figsize = [2 2];
maxIQR = 1;


% 3 x 3: each column: pre-choice, choice, arm end for one binsize
% first column: example binsize; 2nd & 3rd columns, larger binsizes
iBin = find(binsizes == 3); % 3 ms, same as for the scatter,
ixRetain = alliqrs{iBin} > 0 & alliqrs{iBin} < maxIQR;

Limits = [0.3,0.4];  % pre-choice point
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain) .* invertCloseness,Limits,divs,CIalpha,figsize,Maze.Pre,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_PreChoice_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

Limits = [0.4,0.6];  % choice points
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain) .* invertCloseness,Limits,divs,CIalpha,figsize,Maze.Choice,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_Choice_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

Limits = [0.8,1];  % arm end
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain) .* invertCloseness,Limits,divs,CIalpha,figsize,Maze.ArmEnd,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_ArmEnd_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

% 10 ms bins
iBin = find(binsizes == 10);
ixRetain = alliqrs{iBin} > 0 & alliqrs{iBin} < maxIQR;
Limits = [0.3,0.4];  % pre-choice point
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain) .* invertCloseness,Limits,divs,CIalpha,figsize,Maze.Pre,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_PreChoice_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

Limits = [0.4,0.6];  % choice points
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain) .* invertCloseness,Limits,divs,CIalpha,figsize,Maze.Choice,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_Choice_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

Limits = [0.8,1];  % arm end
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain).* invertCloseness,Limits,divs,CIalpha,figsize,Maze.ArmEnd,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_ArmEnd_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

% 50 ms bins
iBin = find(binsizes == 50);
ixRetain = alliqrs{iBin} > 0 & alliqrs{iBin} < maxIQR;

Limits = [0.3,0.4];  % pre-choice point
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain).* invertCloseness,Limits,divs,CIalpha,figsize,Maze.Pre,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_PreChoice_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

Limits = [0.4,0.6];  % choice points
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain).* invertCloseness,Limits,divs,CIalpha,figsize,Maze.Choice,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_Choice_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    

Limits = [0.8,1];  % arm end
h = DiffClosenessOnMaze(allmeds{iBin}(ixRetain),allCloseness{iBin}(ixRetain).* invertCloseness,Limits,divs,CIalpha,figsize,Maze.ArmEnd,widths.plot);
FormatFig_For_Export(h,fontsize,fontname,widths.axis);
%print([exportpath 'Fig8_ArmEnd_' type '_binsize_' num2str(binsizes(iBin))],'-dsvg');    
