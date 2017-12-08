function plotFigure(datasetName,allModel,results)
    recall=[];
    pre=[];
    for modelIdx=1:length(allModel)
        modelName=allModel{modelIdx};
        if strcmp(modelName,results(modelIdx).modelName)
            if ~isempty(results(modelIdx).Performance)
                recall=[recall,results(modelIdx).Performance.TPR'];
                pre=[pre,results(modelIdx).Performance.Pre'];
            else
                recall=[recall,[0.01:0.01:1]'];
                pre=[pre,[1:-0.01:0.01]'];
            end
        else
            error('Model names do not match!');
        end
    end
    figure1 = figure;

    colors={[1 0 0],[0.749019622802734 0.749019622802734 0],[0 0.498039215803146 0],...
            [0.749019622802734 0 0.749019622802734],[0.600000023841858 0.200000002980232 0],[0.87058824300766 0.490196079015732 0],...
            [0 1 0],[0.701960802078247 0.780392169952393 1],[0.231372549019608 0.443137254901961 0.337254901960784],[0 0.749019622802734 0.749019622802734],...
            [1 1 0],[0 0 0],[0 0 1],[1 0.600000023841858 0.7843137383461],[1 0 1],...
            [0 0.498039215803146 0]};

    LineStyle={'-','-.','-','-','--','-','-',':','-.','-','-',':','-','-.'};

    % Create axes
    axes1 = axes('Parent',figure1,...
        'Position',[.13 .17 .80 .74],...
        'LineWidth',2,...
        'FontSize',12);
    %% Uncomment the following line to preserve the X-limits of the axes
    xlim(axes1,[0 1]);
    %% Uncomment the following line to preserve the Y-limits of the axes
    % ylim(axes1,[0.59 0.73]);
    box(axes1,'on');
    hold(axes1,'all');


    % Create multiple lines using matrix input to plot
    %plot1 = plot(recall,pre,'LineWidth',2,'Parent',axes1);
    for i=1:length(allModel)
        plot(recall(:,i)',pre(:,i),'LineWidth',2,'Parent',axes1,'LineStyle',LineStyle{i},'Color',colors{i},'DisplayName',allModel{i});
        %set(plot1(i),'LineStyle',LineStyle{i},'Color',colors{i},'DisplayName',allModel{i});
    end
    legend('show');
    % Create xlabel
    xlabel('Recall','FontSize',14);

    % Create ylabel
    ylabel('Precision','FontSize',14);

    % Create textbox
    annotation(figure1,'textbox',...
        [0.485456889264583 0.178571428571429 0.102550295857988 0.0685714285714286],...
        'String',{datasetName},...
        'FontWeight','bold',...
        'FontSize',14,...
        'FitBoxToText','off',...
        'LineStyle','none');
    saveas(figure1,[datasetName '\' datasetName '.fig']);
    close all
    
    %{
    %show line samples

    figure1 = figure;

    lineNum=min(length(colors),length(LineStyle));
    x=1:10;
    for i=1:lineNum
        y(:,i)=(lineNum+1-i)*ones(10,1);
    end

    % Create axes
    axes1 = axes('Parent',figure1,...
        'Position',[.13 .17 .80 .74],...
        'LineWidth',2,...
        'FontSize',12);
    %% Uncomment the following line to preserve the X-limits of the axes
    xlim(axes1,[1 10]);
    %% Uncomment the following line to preserve the Y-limits of the axes
    % ylim(axes1,[0.59 0.73]);
    box(axes1,'on');
    hold(axes1,'all');


    % Create multiple lines using matrix input to plot
    plot1 = plot(x,y,'LineWidth',2,'Parent',axes1);
    for i=1:length(lineNum)
        set(plot1(i),'LineStyle',LineStyle{i},'Color',colors{i},'DisplayName',num2str(i));
    end
    %}
