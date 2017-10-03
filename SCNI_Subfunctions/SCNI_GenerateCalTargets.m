function c = SCNI_GenerateCalTargets(c)

%====================== SCNI_GenerateCalTargets.m =========================
% Generate screen coordinates for eye-tracker calibration targets.


c.TotalTrials       = c.TrialsPerRun*c.StimPerTrial;                            % Total number of trials per run
c.NoLocations       = 9;                                                        % Total number of possible fixation locations
c.RepsPerLoc        = ceil(c.TotalTrials/c.NoLocations);
c.LocationOrder     = randperm(c.NoLocations, c.NoLocations);  
for r = 1:c.RepsPerLoc
    c.LocationOrder	= [c.LocationOrder, randperm(c.NoLocations, c.NoLocations)];                    % Generate pseudo-random order of locations
end
c.FixmarkerRect     = [0, 0, c.Fix_MarkerSize*c.Display.PixPerDeg];                                 % Size of fixation marker (pixels)
c.GazeSourceRect    = [0, 0, c.Fix_WinRadius*2*c.Display.PixPerDeg];
c.FixLocDirections  = [0,0; 1,1; 1,0; 1,-1; 0,-1; -1,-1; -1,0; -1,1; 0,1];                          % Specify XY locations for 9-point grid
c.FixLocations      = c.FixLocDirections*c.FixEccentricity.*repmat(c.Display.PixPerDeg,[c.NoLocations,1]);	% Scale grid to specified eccentricity (pixels)
c.FixLocations      = c.FixLocations + repmat(c.Display.Rect([3,4])/2, [c.NoLocations,1]);          % Add half a display width and height offsets to center locations
c.FixLocationsDeg   = c.FixLocDirections*c.FixEccentricity;                                         
if IsLinux == 1                                                                                     % If using dual displays on Linux...
    if c.Display.UseSBS3D == 0                                                          
        c.MonkFixLocations = c.FixLocations + repmat(c.Display.Rect([3,1]), [c.NoLocations,1]);     % Add an additional display width offset for subject's screen  
    elseif c.Display.UseSBS3D == 1
        c.MonkFixLocations{1} = c.FixLocations.*[0.5,1] + repmat(c.Display.Rect([3,1]), [c.NoLocations,1]);
        c.MonkFixLocations{2} = c.FixLocations.*[0.5,1] + repmat(c.Display.Rect([3,1])*1.5, [c.NoLocations,1]);	% Add an additional display width + half offset for subject's screen  
    end
else
    c.MonkFixLocations = c.FixLocations;
end
for n = 1:size(c.FixLocations,1)                                                                    % For each fixation coordinate...
    c.FixRects{n}(1,:) = CenterRectOnPoint(c.FixmarkerRect, c.FixLocations(n,1), c.FixLocations(n,2));  % Generate PTB rect argument
    c.GazeRect{n}(1,:) = CenterRectOnPoint(c.GazeSourceRect, c.FixLocations(n,1), c.FixLocations(n,2));	%
    if c.Display.UseSBS3D == 1  
    	c.MonkeyFixRect{n}(1,:)  = CenterRectOnPoint(c.FixmarkerRect./[1,1,2,1], c.MonkFixLocations{1}(n,1), c.MonkFixLocations{1}(n,2)); 	% Center a horizontally squashed fixation rectangle in a half screen rectangle
        c.MonkeyFixRect{n}(2,:)  = CenterRectOnPoint(c.FixmarkerRect./[1,1,2,1], c.MonkFixLocations{2}(n,1), c.MonkFixLocations{2}(n,2)); 
    else
        c.MonkeyFixRect{n}       = CenterRectOnPoint(c.FixmarkerRect, c.MonkFixLocations(n,1), c.MonkFixLocations(n,2)); 
    end
end