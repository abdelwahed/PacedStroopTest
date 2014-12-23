function [FigHandle]=StroopTest(words,colors,CONGRUENCE,prob_size,FigID)
% Produce a figure to take the Stroop test.
%
% Description
%     A figure is produced which contains words in #prob_size# rows which
%     are known color names, and are shown in a colored font. To take the
%     Stroop test, quickly identify the color of each of these words (don’t
%     read them). Say the colors out loud. Try to be as accurate as you
%     can, and finish the test as quickly as you can. This task, called the
%     Stroop Test, is much more challenging than it first appears. It’s
%     much harder to identify a color when it is different from the word
%     (#SHUFFLE#=1) than it is to identify when the two match
%     (#SHUFFLE#=0). This challenging test relies on two key cognitive
%     skills, response inhibition and selective attention. Doing the test
%     for #SHUFFLE#=1 results in considerably more time than it would take
%     for #SHUFFLE#=0.
%
% Required input arguments
%     #words# (column vector) contains the color names as strings, one
%     string per row. all of the vertically concatenated strings must have
%     the same length.
%     #colors# ([size(#words#,1) x 3]) contains the color denoted by each
%     string in #words# in rgb representation. Look for ColorSpec (Color
%     Specification) in the MATLAB documentation
%     #SHUFFLE# (binary) determined if the colors in the figure are to be
%     shuffled, so that the Stroop Test can begin. If #SHUFFLE#=0 no
%     shuffling occurs and in the figure produced the various color names
%     appear with the respective color.
%     #prob_size# (integer) is the size of the problem, i.e. the number of
%     the rows of words in the final figure.
%     #FigID# (integer) is the number of the label of the figure to be
%     produced.
%     #responseTime# is the time in second for which each figure is active,
%     Zero means a static window, overriding 
%
% Output parameters
%     #FigHandle# This returns the figure handle for the Stroop Test items
%__________________________________________________________________________
% Copyright (c) 13-May-2014
%     George Papazafeiropoulos
%     First Lieutenant, Infrastructure Engineer, Hellenic Air Force
%     Civil Engineer, M.Sc., Ph.D. candidate, NTUA
%     Email: gpapazafeiropoulos@yahoo.gr
%     Website: http://users.ntua.gr/gpapazaf/
% -------------------------------------------------------------------------
% Modified      13-Nov-2014
%       Deba Pratim Saha, M.S.Cp.E.
%       Ph.D. Student, ECE Virginia Tech.
%       Email: dpsaha@vt.edu
% -------------------------------------------------------------------------

%% Initial checks
% maximum input arguments
if nargin>5
    error('Too many input arguments.');
end
% ensure that input scalars and vectors have right sizes
assert(isequal(size(words,1),size(colors,1)),...
    'Words and colors do not have equal size.');
assert(isscalar(CONGRUENCE) && isscalar(prob_size),...
    'At least one of the SHUFFLE and prob_size parameters is not scalar.');

%% Create the UI for the test
hor=1;  ver=0.2;
% Create figure
if ishandle(FigID)
    figExist = 1;
else
    figExist = 0;
end

% isFirstTime = 1;                            % This flag is reset after the first time figure properties are set
FigHandle = figure(FigID);
fUserdata = get(FigHandle,'UserData');        % Get the UserData property of the figure

if ~figExist || fUserdata.setFigProps
    fUserdata.setFigProps = 0;              % Reset this flag after this time
    defaultUnits=get(FigHandle,'Units');
    set(FigHandle,'Units','normalized');    % Change the figure units of measurement
    width   =   0.2*prob_size;
    height  =   size(words,1)*0.05*prob_size;
    set(FigHandle,'Position',[0.5-width/2, 0.5-height/2, width, height]); %[left,bottom,width,height]
    set(FigHandle,'Units',defaultUnits);    % Change the figure units to default

    % Create buttons to choose the color
    hBtnGrp=uibuttongroup('parent',FigHandle,'visible','on','Units','normalized',...
                    'Position',[0 0 0.25 0.9],'Title','Indicate Your Choice',...
                    'SelectionChangeFcn',@colorChoice,'Tag','existingBtnGrp');

    for i=1:size(words,1)
        b(i)=uicontrol('Style','radiobutton','String',words(i,:),...
                        'Units','normalized','pos',[0.2 i*0.1+0.15 0.95 0.1],...
                        'parent',hBtnGrp,'HandleVisibility','on');
    end

    
    % create axes (handle)
    axes('position',[0 0 1 1],'FontName','Arial','FontSize',11);
    axis([0 (prob_size+1)*hor 0 (prob_size+1)*ver]);
    set(gca,'defaulttexthorizontalalignment','left');
    set(gca,'defaulttextverticalalignment','middle');
else
    hBtnGrp = findobj(FigHandle,'Tag','existingBtnGrp');               % Get the buttongroup handle
    set(get(hBtnGrp,'Children'),'Enable','On');                        % Activate the buttons;next figure will appear
end

    set(hBtnGrp,'SelectedObject',[]);           % Display No Selection on radio buttons


    %% Data plotting
    maxsize=ceil(prob_size^2 * 7/4);
    ind1=ceil(7*rand(maxsize,1));
    words=words(ind1,:);
    if CONGRUENCE
        colors=colors(ind1,:);
    else
        ind2=ceil(7*rand(maxsize,1));
        while(any(ind2==ind1))                   % Make sure ind2 is not equal to ind1
            ind2=ceil(7*rand(maxsize,1)); end
        colors=colors(ind2,:);
    end

    % Store the Color and Word in Figure Userdata
    fUserdata.('inputColor') = colors(1,:);
    fUserdata.('inputWord')  = words(1,:);
    fUserdata.('choice') = '';
    fUserdata.('timeStart') = clock;                    % Timestamp the start of new word
    set(FigHandle,'UserData',fUserdata);
    % set(FigHandle,'UserData',struct('inputColor',{colors(1,:)},'inputWord',{words(1,:)}));

    % plot
    x=hor;
    y=ver;
    for i=1:maxsize
        text(x,y,deblank(words(i,:)),'Color',colors(i,:),'FontSize',20,'FontWeight','bold','Tag','StroopString');

        stepx=length(deblank(words(i,:)));
        x=x+stepx/3+1/7;

        if x>prob_size*hor
            if y>ver*(prob_size-1)
                break;  
            end
            x=hor;
            y=y+ver;
        end
    end

    %% Callback function for radiobutton selection
    function colorChoice(source,~)
        uChoice = (get(get(source,'SelectedObject'),'String'));
        fUserdata = get(FigHandle,'UserData');                  % Get the UserData field before updating it
        fUserdata.('choice') = uChoice;
        fUserdata.('timeEnd') = clock;                          % Timestamp the end of response
        set(FigHandle,'UserData',fUserdata);
    end

end