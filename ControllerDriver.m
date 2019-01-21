classdef ControllerDriver <handle
     % RNN combined with particle filter
   
    properties(Access=public)
        
        light_driver;
        return_driver;
        current_status;
        right_movements;
        left_movements;
        previous_states;
        previous_light_sensor;
        return_movements;
        track_count;
        pf;
        location;
        pf_size=2000; % particle number
        
    end
    methods(Access=public)
        
        function obj=ControllerDriver()
            b=load ('whole_population2.mat'); %Uses already trained RNN to arrive to the light
            obj.light_driver=b.networks(1);
            obj.current_status=[];
            obj.right_movements=[];
            obj.left_movements=[];
            obj.previous_states=[];
            obj.previous_light_sensor=[];
            obj.current_status=0;
            obj.track_count=0;
            obj.return_driver=NeuralNetwork();
            obj.return_driver.setInput(5); % RNN to return
            obj.return_driver.addNewLayer(7);
            obj.return_driver.addNewLayer(9);
            obj.return_driver.addNewLayer(5);
            obj.return_driver.setOutput(3);
            obj.pf=ParticleFilter(obj.pf_size);
            obj.location=[0,0,0];
        end
        
        function setLocation(obj,x,y,angle) % used for train purpouse only. Gets the real location and angle
                return;
                x_dist=abs(10-x);
                y_dist=abs(y);
                long_edge=sqrt(x_dist^2+y_dist^2);
                
                light_angle= asin(y_dist/long_edge);
                
                if (angle>pi)
                    alpha=angle-pi;
                    angle=2*alpha-angle;
                end
                angle=angle+light_angle;
                obj.location=[obj.location;x,y,angle];
        end
        
        function reset(obj) % reset the object
            obj.current_status=[];
            obj.right_movements=[];
            obj.left_movements=[];
            obj.previous_states=[];
            obj.previous_light_sensor=[];
            obj.current_status=0;
            obj.track_count=0;
            obj.pf=ParticleFilter(obj.pf_size);
            obj.location=[0,0,0];
        end
        
        function res=start(obj,light_sensor,vals) % start the controller
            
            if(obj.current_status==0) % not reached the light
                obj.track_count=obj.track_count+1;
            end
            
            if(light_sensor>=1.5 & obj.current_status==0) % reached the light   
                obj.current_status=1;
                
            end
            
            
            if(obj.current_status==1) % if the agent reached the light
                
              
                cur_loc=obj.location(end,:); 
                inputVector=[light_sensor,cur_loc];
                res=obj.return_driver.predict(inputVector,vals); % RNN prediction
                coords=obj.pf.predict(light_sensor,res(1:2)); % Particle filter prediction and update
                x=coords(1);
                y=coords(2);
                angle=coords(3);
                 x_dist=abs(10-x);
                y_dist=abs(y);
                long_edge=sqrt(x_dist^2+y_dist^2);
                
                light_angle= asin(y_dist/long_edge);
                
                if (angle>pi)
                    alpha=angle-pi;
                    angle=2*alpha-angle;
                end
                angle=angle+light_angle;
                
                obj.location=[obj.location;x,y,angle]; % update location approximation and angle
                return;
            else
                res=obj.light_driver.predict(light_sensor,vals); % RNN prediction
                coords=obj.pf.predict(light_sensor,res(1:2)); % Particle Filter Prediction and update
                x=coords(1);
                y=coords(2);
                angle=coords(3);
                 x_dist=abs(10-x);
                y_dist=abs(y);
                long_edge=sqrt(x_dist^2+y_dist^2);
                
                light_angle= asin(y_dist/long_edge);
                
                if (angle>pi)
                    alpha=angle-pi;
                    angle=2*alpha-angle;
                end
                angle=angle+light_angle;
                obj.location=[obj.location;x,y,angle]; % Save current approximation
               
                return;
            end
            
        end
    end
end
