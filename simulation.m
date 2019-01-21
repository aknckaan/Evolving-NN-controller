
function simulation()

% loads and runs the simmulation with the given RNN
% just for reaching the light
b=load ('whole_population2.mat');
nn=b.networks(1);
[poses, sensations, actions, states ] =  assignmentSimulation(@nn.predict);
 visualiseAssignment(poses, sensations, actions, states);
 
 b=load ('return_particle2.mat'); % load trained RNN with Particle Filter
 cd=b.networks(1);
cd.reset();
[poses, sensations, actions, states ] =  assignmentSimulation(@cd.start);
visualiseAssignment(poses, sensations, actions, states);
end
