function visualiseAssignment(poses, sensations, actions, states)
    shapes = draw(poses, sensations, actions, states);
    
    for i = 1:length(poses)
        try 
            animate(i, shapes, poses, sensations, actions, states);
            drawnow;
        catch 
            break;
        end
    end
end

function shapes = draw(poses, sensations, actions, states)
    ax2 = subplot(5, 1, 5);
    plot(sensations);
    tracker = animatedline();

    subplot(5, 1, [1:4]);
    axis([-15, 15, -15, 15]);
    axis equal;    
    
    rectangle('Position', [ 9, -1, 2, 2 ] , 'Curvature', [1, 1], 'FaceColor', 'y', 'EdgeColor', 'none'); % light halo
    rectangle('Position', [ 9.9, -0.05, 0.1, 0.1 ] , 'Curvature', [1, 1], 'FaceColor', 'y'); % light   
    rectangle('Position', [ -1, -1, 2, 2 ] , 'Curvature', [1, 1], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none'); % light halo

    trail = animatedline('Color', 'r');    
    x = poses(1, 1); y = poses(1, 2); theta = poses(1, 3);    
    
    body = rectangle('Position', [ x-0.5, y-0.5, 1, 1 ] , 'Curvature', [1, 1], 'FaceColor', 'w');
    sPos = [ x, y ] + 0.5 * [ cos(theta), sin(theta) ];
    sensor = rectangle('Position', [sPos(1)-0.05, sPos(2)-0.05, 0.1, 0.1], 'Curvature', [1, 1]);
    
    shapes = { trail, body, sensor, tracker };
end

function ok = animate(i, shapes, poses, sensations, actions, states) 
    [ trail, body, sensor, tracker ] = shapes{:};
    
    x = poses(i, 1); y = poses(i, 2); theta = poses(i, 3);
    
    addpoints(trail, x, y);
    
    body.Position(1:2) = [ x, y ] - 0.5;    

    sPos = [ x, y ] + 0.5 * [ cos(theta), sin(theta) ];
    sensor.Position(1:2) = sPos - 0.05;
    
    clearpoints(tracker);
    ax = subplot(5, 1, 5);
    yLim = get(ax, 'YLim');
    addpoints(tracker, i, yLim(1));
    addpoints(tracker, i, yLim(2));
    
    ok = true;
end