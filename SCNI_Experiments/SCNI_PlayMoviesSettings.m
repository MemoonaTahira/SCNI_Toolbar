%======================= SCNI_PlayMoviesSettings.m ========================
% This function provides a graphical user interface for setting parameters 
% related to the presentation of movie stimuli. Parameters can be saved and 
% loaded, and the updated parameters are returned in the structure 'Params'.
%
% INPUTS:
%   DefaultInputs: 	optional string containing full path of .mat
%                 	file containing previously saved parameters.
% OUTPUT:
%   Params.Movie.: Structure containing movie settings
%
%==========================================================================

function ParamsOut = SCNI_PlayMoviesSettings(ParamsFile, OpenGUI)

persistent Params Fig;

%============ Initialize GUI
GUItag      = 'SCNI_MovieSettings';            % String to use as GUI window tag
Fieldname   = 'Movie';                         % Params structure fieldname for Movie info
if ~exist('OpenGUI','var')
    OpenGUI = 1;
end
if ~exist('ParamsFile','var')
    ParamsFile = [];
elseif exist('ParamsFile','var')
    if ischar(ParamsFile) && exist(ParamsFile, 'file')
        Params      = loead(ParamsFile);
    elseif isstruct(ParamsFile)
        Params      = ParamsFile;
        ParamsFile  = Params.File;
    end
end
[Params, Success, Fig]   = SCNI_InitGUI(GUItag, Fieldname, ParamsFile, OpenGUI);

%=========== Load default parameters
if Success < 1                                          	% If the parameters could not be loaded...
    Params.Movie.Dir            = '/projects/murphya/Stimuli/Movies/MonkeyThieves1080p/';
    Params.Movie.Duration       = 300;                      % Duration of each movie file to play (seconds). Whole movie plays if empty.
    Params.Movie.PlayMultiple   = 1;                        % Play multiple different movie files consecutively?
    Params.Movie.ISI            = 0;                        % Delay between consecutive movies (seconds)
    Params.Movie.SBS            = 0;                        % Are movies in side-by-side stereoscopic 3D format?
    Params.Movie.Fullscreen     = 0;                        % Scale the movie to fill the display screen?
    Params.Movie.AudioOn        = 1;                        % Play accompanying audio with movie?
    Params.Movie.AudioVol       = 1;                        % Set proportion of volume to use
    Params.Movie.VolInc         = 0.1;                      % Volume change increments (proportion) when set by experimenter
    Params.Movie.Loop           = 0;                        % Loop playback of same movie if it reaches the end before the set playback duration?
    Params.Movie.Background     = [0,0,0];                  % Color (RGB) of background for non-fullscreen movies
    Params.Movie.Rate           = 1;                        % Rate of movie playback as proportion of original fps (range -1:1)
    Params.Movie.StartTime      = 1;                        % Movie playback starts at time (seconds)
    Params.Movie.Scale          = 0.8;                      % Proportion of original size to present movie at
    Params.Movie.Paused         = 0;
    Params.Movie.FileFormats    = {'.mp4','.mpg','.wmv','.mov','.avi'};   	% What file format are the movies?
    Params.Movie.FileFormat     = 1;
    Params.Movie.SubdirOpts     = {'Ignore','Load','Conditions'};           % How to treat subdirectories found in Params.Movie.Dir?
    Params.Movie.SubdirOpt      = 3;
    Params.Movie.FixTypes       = {'None','Dot','Square','Cross','Binocular'};
    Params.Movie.FixType        = 1;
    Params.Movie.Rotation       = 0;
    Params.Movie.Contrast       = 1;
    
    %============== Behavioural parameters
    Params.Movie.GazeRectBorder = 2;                        % Distance of gaze window border from edge of movie frame (degrees)
    Params.Movie.FixOn          = 0;                        % Present a fixtion marker during movie playback?
    Params.Movie.PreCalib       = 0;                        % Run a quick 9-point calibration routine prior to movie onset?
    Params.Movie.Reward         = 1;                        % Give reward during movie?
    Params.Movie.FixRequired    = 1;                        % Require fixation criterion to be met for reward?
    
end
Params = RefreshMovieList(Params);


%========================= OPEN GUI WINDOW ================================
Fig.Handle          = figure;                                       	% Open new figure window         
setappdata(0,GUItag,Fig.Handle);                                        % Assign tag
Fig.PanelYdim       = 130*Fig.DisplayScale;
Fig.Rect            = [0 200 500 900]*Fig.DisplayScale;              	% Specify figure window rectangle
set(Fig.Handle,     'Name','SCNI: Movie Experiment settings',...    	% Open a figure window with specified title
                    'Tag','SCNI_PlayMoviesSettings',...                 % Set figure tag
                    'Renderer','OpenGL',...                             % Use OpenGL renderer
                    'OuterPosition', Fig.Rect,...                       % position figure window
                    'NumberTitle','off',...                             % Remove figure number from title
                    'Resize', 'off',...                                 % Prevent resizing of GUI window
                    'Menu','none',...                                   % Turn off memu
                    'Toolbar','none');                                  % Turn off toolbars to save space
Fig.Background  = get(Fig.Handle, 'Color');                           	% Get default figure background color
Fig.Margin      = 20*Fig.DisplayScale;                               	% Set margin between UI panels (pixels)                                 
Fig.Fields      = fieldnames(Params);                                 	% Get parameter field names
Fig.FontSize    = 16;
Fig.TitleFontSize = 18;

%============= Prepare GUI panels
Fig.PanelNames      = {'Movie selection','Movie transforms','Presentation'};
Fig.PannelHeights   = [200, 220, 200];
BoxPos{1}           = [Fig.Margin, Fig.Rect(4)-Fig.PannelHeights(1)*Fig.DisplayScale-Fig.Margin*2, Fig.Rect(3)-Fig.Margin*2, Fig.PannelHeights(1)*Fig.DisplayScale];   
for i = 2:numel(Fig.PanelNames)
    BoxPos{i}           = [Fig.Margin, BoxPos{i-1}(2)-Fig.PannelHeights(i)*Fig.DisplayScale-Fig.Margin/2, Fig.Rect(3)-Fig.Margin*2, Fig.PannelHeights(i)*Fig.DisplayScale];
end

Fig.UImovies.Labels         = {'Movie directory', 'Movie format', 'Subdirectories', 'Conditions', 'Total movies', 'SBS 3D?'};
Fig.UImovies.Style          = {'Edit','Popup','Popup','Popup','Edit','checkbox'};
Fig.UImovies.Defaults       = {Params.Movie.Dir, Params.Movie.FileFormats, Params.Movie.SubdirOpts, Params.Movie.MovieConds, num2str(Params.Movie.TotalMovies), []};
Fig.UImovies.Values         = {isempty(Params.Movie.Dir), Params.Movie.FileFormat, Params.Movie.SubdirOpt, 1, [], Params.Movie.SBS};
Fig.UImovies.Enabled        = [0, 1, 1, 1, 1, 1];
Fig.UImovies.Ypos           = [(Fig.PannelHeights(1)-50):-20:10]*Fig.DisplayScale;
Fig.UImovies.Xwidth         = [180, 200]*Fig.DisplayScale;

Params.Movie.SizeDeg        
Params.Movie.Fullscreen     = 0;                        % Scale the movie to fill the display screen?
    Params.Movie.AudioOn        = 1;                        % Play accompanying audio with movie?
    Params.Movie.AudioVol       = 1;                        % Set proportion of volume to use
    Params.Movie.VolInc         = 0.1;                      % Volume change increments (proportion) when set by experimenter
    Params.Movie.Loop           = 0;                        % Loop playback of same movie if it reaches the end before the set playback duration?
    Params.Movie.Background     = [0,0,0];                  % Color (RGB) of background for non-fullscreen movies
    Params.Movie.Rate           = 1;                        % Rate of movie playback as proportion of original fps (range -1:1)
    Params.Movie.StartTime      = 1;                        % Movie playback starts at time (seconds)
    Params.Movie.Scale          = 0.8;            
    
Fig.UItransform.Labels      = {'Present fullscreen','Retinal subtense (deg)','Image rotation (deg)','Image contrast (%)'};
Fig.UItransform.Style       = {'checkbox','Edit','Edit','Edit'};
Fig.UItransform.Defaults    = {[], Params.Movie.SizeDeg(1), Params.Movie.Rotation, Params.Movie.Contrast};
Fig.UItransform.Values     	= {Params.Movie.Fullscreen, [], [], []};
Fig.UItransform.Enabled     = [1, ~Params.Movie.Fullscreen, 1, 1, 1,1,1,1];
Fig.UItransform.Ypos      	= [(Fig.PannelHeights(2)-50):-20:10]*Fig.DisplayScale;
Fig.UItransform.Xwidth     	= [180, 200]*Fig.DisplayScale;

Fig.UIpresent.Labels        = {'Run duration (s)', 'Duration per movie (s)', 'Inter-stim interval (s)', 'Fixation marker'};
Fig.UIpresent.Style        	= {'Edit','Edit','Edit','Edit'};
Fig.UIpresent.Defaults     	= {Params.Movie.RunDuration, Params.Movie.Duration, Params.Movie.ISI, Params.Movie.FixTypes};
Fig.UIpresent.Values        = {[],[],[],Params.Movie.FixType};
Fig.UIpresent.Enabled       = [1,1,1,1];
Fig.UIpresent.Ypos          = [(Fig.PannelHeights(3)-50):-20:10]*Fig.DisplayScale;
Fig.UIpresent.Xwidth        = [180, 200]*Fig.DisplayScale;

OfforOn         = {'Off','On'};
PanelStructs    = {Fig.UImovies, Fig.UItransform, Fig.UIpresent};

for p = 1:numel(Fig.PanelNames)
    Fig.PannelHandl(p) = uipanel( 'Title',Fig.PanelNames{p},...
                'FontSize',Fig.TitleFontSize,...
                'BackgroundColor',Fig.Background,...
                'Units','pixels',...
                'Position',BoxPos{p},...
                'Parent',Fig.Handle); 
            
    for n = 1:numel(PanelStructs{p}.Labels)
        uicontrol(  'Style', 'text',...
                    'String',PanelStructs{p}.Labels{n},...
                    'Position', [Fig.Margin, PanelStructs{p}.Ypos(n), PanelStructs{p}.Xwidth(1), 20*Fig.DisplayScale],...
                    'Parent', Fig.PannelHandl(p),...
                    'HorizontalAlignment', 'left',...
                    'FontSize', Fig.FontSize);
        Fig.UIhandle(p,n) = uicontrol(  'Style', PanelStructs{p}.Style{n},...
                    'String', PanelStructs{p}.Defaults{n},...
                    'Value', PanelStructs{p}.Values{n},...
                    'Enable', OfforOn{PanelStructs{p}.Enabled(n)+1},...
                    'Position', [Fig.Margin + PanelStructs{p}.Xwidth(1), PanelStructs{p}.Ypos(n), PanelStructs{p}.Xwidth(2), 20*Fig.DisplayScale],...
                    'Parent', Fig.PannelHandl(p),...
                    'HorizontalAlignment', 'left',...
                    'FontSize', Fig.FontSize,...
                    'Callback', {@UpdateParams, p, n});
        if p == 1 && n == 1
            uicontrol(  'Style', 'pushbutton',...
                        'string','...',...
                        'Parent', Fig.PannelHandl(p),...
                        'Position', [Fig.Margin + 20+ sum(PanelStructs{p}.Xwidth([1,2])), PanelStructs{p}.Ypos(n), 20*Fig.DisplayScale, 20*Fig.DisplayScale],...
                        'Callback', {@UpdateParams, p, n});
        end


    end
end


%% ========================== SUBFUNCTIONS ================================


    %=============== Update parameters
    function UpdateParams(hObj, Evnt, Indx1, Indx2)

        switch Indx1    %============= Panel 1 controls
            case 1
                switch Indx2
                    case 1      %===== Change movie directory
                        Params.Movie.Dir	= uigetdir(Params.Movie.Dir,'Select stimulus directory');
                        set(Fig.UIhandle(1,1),'string',Params.Movie.Dir);
                        Params = RefreshMovieList(Params);
                        
                    case 2      %===== Change image file format
                        Params.Movie.FileFormat  = get(hObj, 'value');
                        Params = RefreshMovieList(Params);
                        
                    case 3      %===== Change subdirectory use
                        Params.Movie.SubdirOpt = get(hObj, 'value');
                        Params = RefreshMovieList(Params);
                        
                    case 4
                        
                    case 5
                        
                    case 6      %===== Change 3D format
                        Params.Movie.SBS = get(hObj, 'value');
                        
                    case 7      %===== 
                        
                end
                
            case 2      %============= Panel 2 controls
                
                
                
            case 3      %============= Panel 3 controls
                
        end

    end


    %====================== Refresh the list(s) of movies =================
    function Params = RefreshMovieList(Params)
        
        switch Params.Movie.SubdirOpts{Params.Movie.SubdirOpt}
            case 'Load'
                Params.Movie.AllImFiles 	= wildcardsearch(Params.Movie.Dir, ['*',Params.Movie.FileFormats{Params.Movie.FileFormat}]);
                Params.Movie.MovieConds  = {''};
                
            case 'Ignore'
                Params.Movie.AllImFiles 	= regexpdir(Params.Movie.Dir, Params.Movie.FileFormats{Params.Movie.FileFormat},0);
                Params.Movie.MovieConds  = {''};
                
            case 'Conditions'
                SubDirs                     = dir(Params.Movie.Dir);
                Params.Movie.MovieConds  = {SubDirs([SubDirs.isdir]).name};
                Params.Movie.MovieConds(~cellfun(@isempty, strfind(Params.Movie.MovieConds, '.'))) = [];
                Params.Movie.AllImFiles 	= [];
                for cond = 1:numel(Params.Movie.MovieConds)
                    Params.Movie.ImByCond{cond} 	= regexpdir(fullfile(Params.Movie.Dir, Params.Movie.MovieConds{cond}), Params.Movie.FileFormats{Params.Movie.FileFormat},0);
                    Params.Movie.ImByCond{cond}(cellfun(@isempty, Params.Movie.ImByCond{cond})) = [];
                    Params.Movie.AllImFiles      = [Params.Movie.AllImFiles; Params.Movie.ImByCond{cond}];
                end
        end
        Params.Movie.TotalMovies     = numel(Params.Movie.AllImFiles);
        
        %========== Update GUI
        if isfield(Fig, 'UImovies')
            ButtonIndx = find(~cellfun(@isempty, strfind(Fig.UImovies.Labels, 'Conditions')));
            if ~isempty(Params.Movie.MovieConds)
                set(Fig.UIhandle(1,ButtonIndx), 'string', Params.Movie.MovieConds, 'enable', 'on');
            else
                set(Fig.UIhandle(1,ButtonIndx), 'string', {''}, 'enable', 'off');
            end
            StrIndx = find(~cellfun(@isempty, strfind(Fig.UImovies.Labels, 'Total movies')));
            set(Fig.UIhandle(1,StrIndx), 'string', num2str(Params.Movie.TotalMovies));
        end
    end





end

