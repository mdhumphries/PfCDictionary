% script to build Figure 6: what changes between Sleep epochs - rates,
% covariation, spike times?
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

% which data for examples
type = 'Learn';
N = 35;
iBin = 4; % example binsize: 5 ms
iShuffle = 1; % example shuffle
iSession = 7; % example session
iJit = 3;  % 10ms jitter (for 5 ms binsize)

strDlabel = {'Data','Shuffle'};
strJlabel = {'Data','Jitter'};

shuflearn.marker = colours.shuf.line;
shuflearn.edge = colours.learning.line;
shuflearn.error = colours.shuf.line;

shufstable.marker = colours.shuf.line;
shufstable.edge = colours.stable.line;
shufstable.error = colours.shuf.line;

smallstrp = [10 15 4.5 3.5];


%% panel: scatter of D(Pre|Post) vs D(Pre*|Post*) [with CIs] for Learning - 5 ms

load([filepath 'DeltaSleep_Shuffled_N' num2str(N) '_Learn'])

Nsessions = numel(DeltaSleep);
Nshuffles = numel(DeltaSleep(1).Shuffle);

% collate D(data), mean[D(permute)], and CI[D(permute)] over the sessions,
% for one shuffle
Ddata = zeros(Nsessions,1); MDperm = zeros(Nsessions,1); CIperm = zeros(2,Nsessions);
for iS = 1:Nsessions
    Ddata(iS) = DeltaSleep(iS).Shuffle(iShuffle).Bins(iBin).D_Pre_Post;
    MDperm(iS) = DeltaSleep(iS).Shuffle(iShuffle).Bins(iBin).Perm.M_Pre_Post;
    ci99 = DeltaSleep(iS).Shuffle(iShuffle).Bins(iBin).Perm.CI_Pre_Post(2);
    CIperm(:,iS) = [MDperm(iS)-ci99; MDperm(iS)+ci99]';
end

plotScatter(Ddata,MDperm,CIperm,figsize,shuflearn,widths,fontsize,fontname,'Data: D(Pre_S|Post_S)','Null model: D(Pre^*_S|Post^*_S)',1,M)
%print([exportpath 'Fig6_ShuffleLearn_SleepChangeDiff_Null_Model'],'-dsvg');     


%% panel: scatter of D(Pre|Post) vs D(Pre*|Post*) [with CIs] for Stable -  5 ms

load([filepath 'DeltaSleep_Shuffled_N' num2str(N) '_Stable85'])

Nsessions = numel(DeltaSleep);
Nshuffles = numel(DeltaSleep(1).Shuffle);

% collate D(data), mean[D(permute)], and CI[D(permute)] over the sessions,
% for one shuffle
Ddata = zeros(Nsessions,1); MDperm = zeros(Nsessions,1); CIperm = zeros(2,Nsessions);
for iS = 1:Nsessions
    Ddata(iS) = DeltaSleep(iS).Shuffle(iShuffle).Bins(iBin).D_Pre_Post;
    MDperm(iS) = DeltaSleep(iS).Shuffle(iShuffle).Bins(iBin).Perm.M_Pre_Post;
    ci99 = DeltaSleep(iS).Shuffle(iShuffle).Bins(iBin).Perm.CI_Pre_Post(2);
    CIperm(:,iS) = [MDperm(iS)-ci99; MDperm(iS)+ci99]';
end

plotScatter(Ddata,MDperm,CIperm,figsize,shufstable,widths,fontsize,fontname,'Data: D(Pre_S|Post_S)','Null model: D(Pre^*_S|Post^*_S)',1,M)
%print([exportpath 'Fig6_ShuffleStable_SleepChangeDiff_Null_Model'],'-dsvg');     



%% panel: summary over binsizes
lW = 0.08;  % spacing of strip plots around the binsize tick mark

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load([filepath 'DeltaSleep_Shuffled_N' num2str(N) '_Learn'])
LearnDelta = DeltaSleep; NLearn = numel(LearnDelta);
load([filepath 'DeltaSleep_Shuffled_N' num2str(N) '_Stable85'])
StableDelta = DeltaSleep; NStable = numel(StableDelta);


for iB = 1:numel(binsizes)

    for iSh = 1:Nshuffles
        ShufDiff(iB,iSh).Learn = zeros(NLearn,1);
        for iS = 1:NLearn
            ShufDiff(iB,iSh).Learn(iS) = LearnDelta(iS).Shuffle(iSh).Bins(iB).D_Pre_Post - LearnDelta(iS).Shuffle(iSh).Bins(iB).Perm.M_Pre_Post;    
        end

        ShufDiff(iB,iSh).Stable = zeros(NStable,1);
        for iS = 1:NStable
            ShufDiff(iB,iSh).Stable(iS) = StableDelta(iS).Shuffle(iSh).Bins(iB).D_Pre_Post - StableDelta(iS).Shuffle(iSh).Bins(iB).Perm.M_Pre_Post;    
        end

    end
end

% take mean over shuffles
MpermDiff.Learn = zeros(NLearn,numel(binsizes));
MpermDiff.Stable = zeros(NStable,numel(binsizes));
for iB = 1:numel(binsizes)
    allShuf = [ShufDiff(iB,:).Learn];
    MpermDiff.Learn(:,iB) = mean(allShuf,2); 
    allShuf = [ShufDiff(iB,:).Stable];
    MpermDiff.Stable(:,iB) = mean(allShuf,2); 
end

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 7 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iB = 1:numel(binsizes)
    hold on
    plot(zeros(NStable,1)+binsizes(iB) + binsizes(iB)*lW,MpermDiff.Stable(:,iB),'o',...
            'MarkerFaceColor',shufstable.marker,'MarkerEdgeColor',shufstable.edge,'Markersize',M);
    plot(zeros(NLearn,1)+binsizes(iB) - binsizes(iB)*lW,MpermDiff.Learn(:,iB),'o',...
            'MarkerFaceColor',shuflearn.marker,'MarkerEdgeColor',shuflearn.edge,'Markersize',M);
    
end
set(gca,'XScale','log','XTick',xtick,'XTickLabel',strXlabel,'XLim',[xmin xmax],'XMinorTick','off');
set(gca,'YLim',[-0.1 0.5])
xlabel('Bin size (ms)'); 
ylabel('Difference: D(data_S) - D(null_S)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_ShuffleData_SleepChangeDiff_Null_Model'],'-dsvg');     


%% compare Data and Shuffled, as distance from null model...: strip plot

load([filepath 'DeltaSleep_Data_N' num2str(N) '_Learn'])
LearnDelta = DeltaSleep; NLearn = numel(LearnDelta);
load([filepath 'DeltaSleep_Data_N' num2str(N) '_Stable85'])
StableDelta = DeltaSleep; NStable = numel(StableDelta);
load([filepath 'DataWords_And_Counts_N' num2str(N) '_Learn'],'binsizes')


for iB = 1:numel(binsizes)
    Diff(iB).Learn = zeros(NLearn,1);
    for iS = 1:NLearn
        Diff(iB).Learn(iS) = LearnDelta(iS).Bins(iB).D_Pre_Post - LearnDelta(iS).Bins(iB).Perm.M_Pre_Post;    
    end
    
    Diff(iB).Stable = zeros(NStable,1);
    for iS = 1:NStable
        Diff(iB).Stable(iS) = StableDelta(iS).Bins(iB).D_Pre_Post - StableDelta(iS).Bins(iB).Perm.M_Pre_Post;            
    end
end

% strip plot of Data and Shuffled (Learn)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[Diff(iBin).Learn MpermDiff.Learn(:,iBin)],colours.learning.line,...
    'MarkerFaceColor',[colours.learning.marker; shuflearn.marker],'MarkerEdgeColor',[colours.learning.edge; colours.learning.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance from null model')
set(gca,'YLim',[0 0.3])
set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_5ms_Sleep_Depart_Null_Model_DatavsShuf'],'-dsvg');     

% strip plot of Data and Shuffled (Stable)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[Diff(iBin).Stable MpermDiff.Stable(:,iBin)],colours.stable.line,...
    'MarkerFaceColor',[colours.stable.marker; shuflearn.marker],'MarkerEdgeColor',[colours.stable.edge; colours.stable.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance from null model')
set(gca,'YLim',[0 0.3])
set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_5ms_Stable_Sleep_Depart_Null_Model_DatavsShuf'],'-dsvg');     


%% summarise difference-vs-null-model over binsizesa
lW = 0.1;

Ddatashuf.Learn = zeros(NLearn,numel(binsizes));
for iB = 1:numel(binsizes)
    Ddatashuf.Learn(:,iB) = Diff(iB).Learn - MpermDiff.Learn(:,iB);
    Ddatashuf.Stable(:,iB) = Diff(iB).Stable - MpermDiff.Stable(:,iB);
    Pdatashuf.Learn(:,iB) = Ddatashuf.Learn(:,iB) ./ Diff(iB).Learn;
    Pdatashuf.Stable(:,iB) = Ddatashuf.Stable(:,iB) ./ Diff(iB).Stable;
   
end


figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 7 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iB = 1:numel(binsizes)
    plot(zeros(NStable,1)+binsizes(iB) + binsizes(iB)*lW,Ddatashuf.Stable(:,iB),'o',...
            'MarkerFaceColor',colours.stable.marker,'MarkerEdgeColor',colours.stable.edge,'Markersize',M);
    plot(zeros(NLearn,1)+binsizes(iB) - binsizes(iB)*lW,Ddatashuf.Learn(:,iB),'o',...
            'MarkerFaceColor',colours.learning.marker,'MarkerEdgeColor',colours.learning.edge,'Markersize',M);
    
end

set(gca,'XScale','log','XTick',xtick,'XTickLabel',strXlabel,'XLim',[xmin xmax],'XMinorTick','off');
set(gca,'YLim',[-0.1 0.1])
xlabel('Bin size (ms)'); 
ylabel('Difference (Data - Shuffle)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_Sleep_DatavsShuf'],'-dsvg'); 

% as proportion of Data departure
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 7 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iB = 1:numel(binsizes)
    plot(zeros(NStable,1)+binsizes(iB) + binsizes(iB)*lW,Pdatashuf.Stable(:,iB),'o',...
            'MarkerFaceColor',colours.stable.marker,'MarkerEdgeColor',colours.stable.edge,'Markersize',M);
    plot(zeros(NLearn,1)+binsizes(iB) - binsizes(iB)*lW,Pdatashuf.Learn(:,iB),'o',...
            'MarkerFaceColor',colours.learning.marker,'MarkerEdgeColor',colours.learning.edge,'Markersize',M);
    
end

set(gca,'XScale','log','XTick',xtick,'XTickLabel',strXlabel,'XLim',[xmin xmax],'XMinorTick','off');
% set(gca,'YLim',[-0.1 0.1])
xlabel('Bin size (ms)'); 
ylabel('Proportional difference (%)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_Sleep_PropDatavsShuf'],'-dsvg'); 

%% co-active neuron panels....

% Difference between data and null model
load([filepath 'DeltaSleep_K2_Data_N' num2str(N) '_Learn'])
LearnDelta = DeltaSleep; NLearn = numel(LearnDelta);
load([filepath 'DeltaSleep_K2_Data_N' num2str(N) '_Stable85'])
StableDelta = DeltaSleep; NStable = numel(StableDelta);
load([filepath 'DataWords_And_Counts_N' num2str(N) '_Learn'],'binsizes')
Nsessions = numel(DeltaSleep);


for iB = 1:numel(binsizes)
    Diff(iB).Learn = zeros(NLearn,1);
    for iS = 1:NLearn
        Diff(iB).Learn(iS) = LearnDelta(iS).Bins(iB).D_Pre_Post - LearnDelta(iS).Bins(iB).Perm.M_Pre_Post;    
    end
    
    Diff(iB).Stable = zeros(NStable,1);
    for iS = 1:NStable
        Diff(iB).Stable(iS) = StableDelta(iS).Bins(iB).D_Pre_Post - StableDelta(iS).Bins(iB).Perm.M_Pre_Post;            
    end
end

% Difference between shuffle and null model
load([filepath 'DeltaSleep_K2_Shuffled_N' num2str(N) '_Learn'])
LearnDelta = DeltaSleep; NLearn = numel(LearnDelta);
load([filepath 'DeltaSleep_K2_Shuffled_N' num2str(N) '_Stable85'])
StableDelta = DeltaSleep; NStable = numel(StableDelta);
Nshuffles = numel(DeltaSleep(1).Shuffle);


for iB = 1:numel(binsizes)

    for iSh = 1:Nshuffles
        ShufDiff(iB,iSh).Learn = zeros(NLearn,1);
        for iS = 1:NLearn
            ShufDiff(iB,iSh).Learn(iS) = LearnDelta(iS).Shuffle(iSh).Bins(iB).D_Pre_Post - LearnDelta(iS).Shuffle(iSh).Bins(iB).Perm.M_Pre_Post;    
        end

        ShufDiff(iB,iSh).Stable = zeros(NStable,1);
        for iS = 1:NStable
            ShufDiff(iB,iSh).Stable(iS) = StableDelta(iS).Shuffle(iSh).Bins(iB).D_Pre_Post - StableDelta(iS).Shuffle(iSh).Bins(iB).Perm.M_Pre_Post;    
        end

    end
end

% take mean over shuffles
MpermDiff.Learn = zeros(NLearn,numel(binsizes));
MpermDiff.Stable = zeros(NStable,numel(binsizes));
for iB = 1:numel(binsizes)
    allShuf = [ShufDiff(iB,:).Learn];
    MpermDiff.Learn(:,iB) = mean(allShuf,2); 
    allShuf = [ShufDiff(iB,:).Stable];
    MpermDiff.Stable(:,iB) = mean(allShuf,2); 
end


% Comparison between the Data and Shuffle departures from null model
lW = 0.1;

Ddatashuf.Learn = zeros(NLearn,numel(binsizes));
for iB = 1:numel(binsizes)
    Ddatashuf.Learn(:,iB) = Diff(iB).Learn - MpermDiff.Learn(:,iB);
    Ddatashuf.Stable(:,iB) = Diff(iB).Stable - MpermDiff.Stable(:,iB);
    Pdatashuf.Learn(:,iB) = Ddatashuf.Learn(:,iB) ./ Diff(iB).Learn;
    Pdatashuf.Stable(:,iB) = Ddatashuf.Stable(:,iB) ./ Diff(iB).Stable;
   
end

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 7 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iB = 1:numel(binsizes)
    plot(zeros(NStable,1)+binsizes(iB) + binsizes(iB)*lW,Ddatashuf.Stable(:,iB),'o',...
            'MarkerFaceColor',colours.stable.marker,'MarkerEdgeColor',colours.stable.edge,'Markersize',M);

    plot(zeros(NLearn,1)+binsizes(iB) - binsizes(iB)*lW,Ddatashuf.Learn(:,iB),'o',...
            'MarkerFaceColor',colours.learning.marker,'MarkerEdgeColor',colours.learning.edge,'Markersize',M);
    
end

set(gca,'XScale','log','XTick',xtick,'XTickLabel',strXlabel,'XLim',[xmin xmax],'XMinorTick','off');
set(gca,'YLim',[-0.1 0.1])
xlabel('Bin size (ms)'); 
ylabel('Difference (Data - Shuffle)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_K2_Sleep_DatavsShuf'],'-dsvg'); 

% as proportion of Data departure
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 7 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iB = 1:numel(binsizes)
    plot(zeros(NStable,1)+binsizes(iB) + binsizes(iB)*lW,Pdatashuf.Stable(:,iB),'o',...
            'MarkerFaceColor',colours.stable.marker,'MarkerEdgeColor',colours.stable.edge,'Markersize',M);
    plot(zeros(NLearn,1)+binsizes(iB) - binsizes(iB)*lW,Pdatashuf.Learn(:,iB),'o',...
            'MarkerFaceColor',colours.learning.marker,'MarkerEdgeColor',colours.learning.edge,'Markersize',M);
    
end

set(gca,'XScale','log','XTick',xtick,'XTickLabel',strXlabel,'XLim',[xmin xmax],'XMinorTick','off');
set(gca,'YLim',[-2 2])
xlabel('Bin size (ms)'); 
ylabel('Proportional difference (%)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_K2_Sleep_PropDatavsShuf'],'-dsvg'); 

%% Changes to ISIs
load([localpath 'ExciteChangeSleep_Data_N' num2str(N) '_' type],'ISIs');

yoff = 0.3;
ygap = 0.01;
preshade = [3 3 1.2];
postshade = [1.2 2 1.2];
f = [1 2 3 4];
ixExample = 1;

Nneurons = size(ISIs(ixExample).spreadPre,1);
ixSrt = flipud(ISIs(ixExample).ixSrtAbsMedDiff);
% horizontal bar distributions
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 15 4.5]); 
for iN=1:Nneurons
    v = [iN-ygap, ISIs(ixExample).spreadPre(ixSrt(iN),1); iN-ygap, ISIs(ixExample).spreadPre(ixSrt(iN),5); ...
                iN-yoff, ISIs(ixExample).spreadPre(ixSrt(iN),5); iN-yoff, ISIs(ixExample).spreadPre(ixSrt(iN),1)];
    patch('Faces',f,'Vertices',v,'FaceColor',colours.pre.marker.*preshade,'EdgeColor','none')
    v = [iN-ygap, ISIs(ixExample).spreadPre(ixSrt(iN),2); iN-ygap, ISIs(ixExample).spreadPre(ixSrt(iN),4); ...
                iN-yoff, ISIs(ixExample).spreadPre(ixSrt(iN),4); iN-yoff, ISIs(ixExample).spreadPre(ixSrt(iN),2)];
    patch('Faces',f,'Vertices',v,'FaceColor',colours.pre.marker,'EdgeColor','none')
    line([iN-ygap iN-yoff],[ISIs(ixExample).spreadPre(ixSrt(iN),3),ISIs(ixExample).spreadPre(ixSrt(iN),3)],'Color',[1 1 1],'Linewidth',2)

    v = [iN+ygap, ISIs(ixExample).spreadPost(ixSrt(iN),1); iN+ygap, ISIs(ixExample).spreadPost(ixSrt(iN),5); ...
                iN+yoff, ISIs(ixExample).spreadPost(ixSrt(iN),5); iN+yoff, ISIs(ixExample).spreadPost(ixSrt(iN),1)];
    patch('Faces',f,'Vertices',v,'FaceColor',colours.post.marker.*postshade,'EdgeColor','none')
    v = [iN+ygap, ISIs(ixExample).spreadPost(ixSrt(iN),2); iN+ygap, ISIs(ixExample).spreadPost(ixSrt(iN),4); ...
                iN+yoff, ISIs(ixExample).spreadPost(ixSrt(iN),4); iN+yoff, ISIs(ixExample).spreadPost(ixSrt(iN),2)];
    patch('Faces',f,'Vertices',v,'FaceColor',colours.post.marker,'EdgeColor','none')
    line([iN+ygap iN+yoff],[ISIs(ixExample).spreadPost(ixSrt(iN),3),ISIs(ixExample).spreadPost(ixSrt(iN),3)],'Color',[1 1 1],'Linewidth',2)

end
axis tight
set(gca,'Yscale','log')
xlabel('Neuron')
ylabel('ISIs (ms)')
%set(gca,'YLim',[0 0.3])
set(gca,'YTick',[10^1 10^2 10^3 10^4],'YTickLabel',[10 100 1000 10000],'YMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_ExampleExciteChange'],'-dsvg');     

% set(gca,'YLim',[0 1000])


%% JITTER PANELS... (not used) 

% summarise jittered data

load([filepath 'Jittered_TrialsSpike_Data_N' num2str(N) '_' type],'jittersize')
load([filepath 'DeltaSleep_Jittered_N' num2str(N) '_Learn_binsize_5'])
LearnDelta = DeltaSleep; NLearn = numel(LearnDelta);
load([filepath 'DeltaSleep_Jittered_N' num2str(N) '_Stable85_binsize_5'])
StableDelta = DeltaSleep; NStable = numel(StableDelta);

Njitters = numel(StableDelta(1).Jitter(1).Shuffle);

for iJ = 1:numel(jittersize)

    for iSh = 1:Njitters
        JitDiff(iJ,iSh).Learn = zeros(NLearn,1);
        for iS = 1:NLearn
            JitDiff(iJ,iSh).Learn(iS) = LearnDelta(iS).Jitter(iJ).Shuffle(iSh).D_Pre_Post - LearnDelta(iS).Jitter(iJ).Shuffle(iSh).Perm.M_Pre_Post;    
        end

        JitDiff(iJ,iSh).Stable = zeros(NStable,1);
        for iS = 1:NStable
           JitDiff(iJ,iSh).Stable(iS) = StableDelta(iS).Jitter(iJ).Shuffle(iSh).D_Pre_Post - StableDelta(iS).Jitter(iJ).Shuffle(iSh).Perm.M_Pre_Post;    
        end

    end
end

% take mean over shuffles
MjitDiff.Learn = zeros(NLearn,numel(jittersize));
MjitDiff.Stable = zeros(NStable,numel(jittersize));
for iJ = 1:numel(jittersize)
    allShuf = [JitDiff(iJ,:).Learn];
    MjitDiff.Learn(:,iJ) = mean(allShuf,2); 
    allShuf = [JitDiff(iJ,:).Stable];
    MjitDiff.Stable(:,iJ) = mean(allShuf,2); 
end

% linked scatter for jitter = 10 ms
% strip plot of Data and Shuffled (Learn)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[Diff(iBin).Learn MjitDiff.Learn(:,iJit)],colours.learning.line,...
    'MarkerFaceColor',[colours.learning.marker; shuflearn.marker],'MarkerEdgeColor',[colours.learning.edge; colours.learning.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance from null model')
set(gca,'YLim',[0 0.4])
set(gca,'XTick',xtick,'XTickLabel',strJlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_5ms_Sleep_Depart_Null_Model_DatavsJitter10ms'],'-dsvg');     

%% Jitter: joint scatter for difference from null model
DdataJit.Learn = zeros(NLearn,numel(binsizes));
for iJ = 1:numel(jittersize)
    DdataJit.Learn(:,iJ) = Diff(iJ).Learn - MjitDiff.Learn(:,iJ);
    DdataJit.Stable(:,iJ) = Diff(iJ).Stable - MjitDiff.Stable(:,iJ);
    PdataJit.Learn(:,iJ) = DdataJit.Learn(:,iJ) ./ Diff(iJ).Learn;
    PdataJit.Stable(:,iJ) = DdataJit.Stable(:,iJ) ./ Diff(iJ).Stable;
   
end

lW = 0.1;

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 5 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iJ = 1:numel(jittersize)
    plot(zeros(NStable,1)+jittersize(iJ) + jittersize(iJ)*lW,DdataJit.Stable(:,iJ),'o',...
            'MarkerFaceColor',colours.stable.marker,'MarkerEdgeColor',colours.stable.edge,'Markersize',M);
    plot(zeros(NLearn,1)+jittersize(iJ) - jittersize(iJ)*lW,DdataJit.Learn(:,iJ),'o',...
            'MarkerFaceColor',colours.learning.marker,'MarkerEdgeColor',colours.learning.edge,'Markersize',M);
    
end

set(gca,'XScale','log','XLim',[1 100],'XMinorTick','off','XTick',jittersize);
set(gca,'YLim',[-0.1 0.1])
xlabel('Jitter (ms)'); 
ylabel('Difference (Data - Jitter)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_Sleep_DatavsJit5msword'],'-dsvg'); 

% plot as proportion of Data difference
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 5 4]);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); hold on
for iJ = 1:numel(jittersize)
    plot(zeros(NStable,1)+jittersize(iJ) + jittersize(iJ)*lW,PdataJit.Stable(:,iJ),'o',...
            'MarkerFaceColor',colours.stable.marker,'MarkerEdgeColor',colours.stable.edge,'Markersize',M);
    plot(zeros(NLearn,1)+jittersize(iJ) - jittersize(iJ)*lW,PdataJit.Learn(:,iJ),'o',...
            'MarkerFaceColor',colours.learning.marker,'MarkerEdgeColor',colours.learning.edge,'Markersize',M);
    
end

set(gca,'XScale','log','XLim',[1 100],'XMinorTick','off','XTick',jittersize);
% set(gca,'YLim',[-0.1 0.1])
xlabel('Jitter (ms)'); ylabel('Proportional difference (%)'); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig6_Sleep_PropDatavsJit5msword'],'-dsvg'); 






