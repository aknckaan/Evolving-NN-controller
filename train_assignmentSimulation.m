function [ poses, sensations, actions, states ] = train_assignmentSimulation(controlFunction,orientation, varargin)
     if ~isa(controlFunction, 'function_handle')
         error('Error. First argument to assignmentSimulation must be a control function.');
     end
    
    % read function inputs
    settings = struct();
    
    if nargin == 3
        settings = varargin(1);
    end

	% default settings
	mySettings = struct( ...
		'sensorNoise', 0.01, ...
		'motorNoise', 0.5, ...
		'dt', 0.1, ...
		'duration', 400, ...
		'agentRadius', 0.5, ...
		'lightHeight', 0.1, ...
		'luminosity', 1, ...
		'lightPos', [ 10, 0 ] ...
	);

	% overwrite default settings with input parameters
	f = fieldnames(settings);
		
	for i = 1:length(f)
		mySettings.(f{i}) = settings.(f{i});
	end		
	
	% read settings into variables
	r = mySettings.('agentRadius');
	sigmaM = mySettings.('motorNoise');
	sigmaA = mySettings.('sensorNoise');
	h = mySettings.('lightHeight');
	lPos = mySettings.('lightPos');
	K = mySettings.('luminosity');
	dt = mySettings.('dt');
    duration = mySettings.('duration');

    % initialise result storage
	n = ceil(duration / dt);
	poses = zeros(n, 3);
	sensations = zeros(n, 1);
	actions = zeros(n, 2);
	states = cell(n, 1);
	i = 1;
    
	% initialise agent
    poses(1,:) = [ 0, 0, orientation];
	internalState = [ ]; % agent's internal state is empty	

	% simulate system
	for t = 0:dt:duration
		% read pose into variables
		xy = poses(i, 1:2); theta = poses(i, 3);
		
		% begin calculating sensor reading		
		sensorPosition = xy + r * [ cos(theta), sin(theta) ];
		
		d_s2 = sum( (lPos - sensorPosition).^2 ); % squared distance from light to sensor 
		d_a2 = sum( (lPos - xy).^2 ); % squared distance from light to agent's centre
		visible = (d_s2 - d_a2 < r^2) & (r^2 < d_s2);
		
		sensorReading = visible * K / (d_s2 + h^2) + normrnd(0, sigmaA * dt^0.5);
		% end calculating sensor reading
		
		% get motor command from controller and update the internal control state
        %results = controlFunction.start(sensorReading, internalState);
		results = controlFunction(sensorReading, internalState);
        internalState =results(3:end);
		motorCommand=[results(1:2)];
		motorValues = tanh(motorCommand) + normrnd(0, sigmaM * dt^0.5, 1, 2);
		
		% begin calculating pose update
		v = sum(motorValues) / 2;
		omega = -diff(motorValues) / (2 * r);
		
		pose = poses(i, :) + dt * [ v * cos(theta), v * sin(theta), omega ];
		% end calculating pose update
		
		i = i+1;
		% store new pose, sensor readings, motor commands and controller state
		poses(i, :) = pose;
		sensations(i, :) = sensorReading;
		actions(i, :) = motorCommand;
		states{i} = internalState;		
	end
end

