classdef ParticleFilter <handle
    
    
    properties(Access=public)
        
        current_status;
        particles;
        r=0.5;
        lPos=[10,0];
        K=1;
        h=0.1;
        sigmaA=0.01;
        sigmaM=0.5;
        dt=0.1;
        particle_size;
    end
    methods(Access=public)
        
        function obj=ParticleFilter(size) % Create the object and generate particles
            obj.particle_size=size;
            obj.current_status=[0,0,0];
            obj.particles=zeros(obj.particle_size,3);
            orientation_arr=[];
            for(orient=1:obj.particle_size)
                orientation_arr=[orientation_arr,rand() * 2 * pi/obj.particle_size+2*pi/(2*obj.particle_size)*(orient-1)];
                theta=orientation_arr(orient);
                obj.particles(orient,end-1)=mod(theta,2*pi);
            end
            
        end
        
        function new_loc=predict(obj,sensation,motorCommand) % approximate current location
            weights=[];
            for i=1:obj.particle_size
                xy=obj.particles(i,1:2);
                theta=obj.particles(i,3);
                light=simulateLight(obj,xy,theta,obj.r,obj.lPos,obj.K,obj.h,obj.sigmaA,obj.dt);
                weights=[weights,calcAgent_log_likelihoodv2(obj,sensation,light,obj.sigmaA,obj.dt)];
                
            end
            
            normalised=weights/sum(weights + 1.e-300);
            x_list=obj.particles(:,1);
            y_list=obj.particles(:,2);
            angle_list=obj.particles(:,3);
            
            x_loc=sum(x_list.*transpose(normalised))/sum(normalised);
            y_loc=sum(y_list.*transpose(normalised))/sum(normalised);
            mTheta=sum(angle_list.*transpose(normalised))/sum(normalised);
            obj.current_status=[x_loc,y_loc,mTheta];
            
            if (1/sum((normalised).^2)<obj.particle_size*1/2) % threshold for resampling
                resample=resamplingv2(obj,obj.particles, normalised);
                obj.particles=resample;
            end
            
            
            obj.current_status=obj.current_status+simulateMovement(obj,motorCommand,mTheta,obj.r,obj.sigmaM,obj.dt);
            obj.current_status(3)=mod(obj.current_status(3),2*pi);

            for i=1:length(obj.particles)
                obj.particles(i,1:3)=obj.particles(i,1:3)+simulateMovement(obj,motorCommand, obj.particles(i,3),obj.r,obj.sigmaM,obj.dt);
                obj.particles(i,3)=mod(obj.particles(i,3),2*pi);
            end
            
            new_loc=obj.current_status;
            %new_loc=new_loc(1:2);
        end
        
        
        
        function L = calcAgent_log_likelihoodv2(obj,cur_data,particle_data,sigmaA,dt)

sensor_sigma=sigmaA*sqrt(dt);
z=cur_data-particle_data;
twoVar=2*sensor_sigma^2;
if twoVar == 0
    L=1;
    return;
else
    delta2 = (z)^2;
    delta2=-1*delta2 ;
    up=exp(delta2/ twoVar);
    down=sqrt(twoVar * pi);
    L=(up/down);
end


end
        function particlesState =resamplingv2(obj,particlesState, w)
            
            
            N = length(w);
            Q = cumsum(w);
            
            T = linspace(0,1-1/N,N) + rand(1)/N;
            T(N+1) = 1;
            
            i=1;
            j=1;
            
            while (i<=N),
                if (T(i)<Q(j) || j==length(Q)),
                    indx(i)=j;
                    i=i+1;
                else
                    if(j+1<=length(Q))
                        j=j+1;
                    end
                end
            end
            
            particlesState =particlesState(indx,:); % for agent
            
            
        end
        function newLoc=simulateMovement(obj,motorCommand,theta,r,sigmaM,dt)
            motorValues = tanh(motorCommand) + normrnd(0, sigmaM * dt^0.5, 1, 2);
            
            % begin calculating pose update
            v = sum(motorValues) / 2;
            omega = -diff(motorValues) / (2 * r);
            newLoc =  dt * [ v * cos(theta), v * sin(theta), omega];
            % end calculating pose update
        end
        function sensorReading=simulateLight(obj,xy,theta,r,lPos,K,h,sigmaA,dt)
            xy=xy(1:2);
            sensorPosition = xy + r * [ cos(theta), sin(theta) ];
            
            d_s2 = sum( (lPos - sensorPosition).^2 ); % squared distance from light to sensor
            d_a2 = sum( (lPos - xy).^2 ); % squared distance from light to agent's centre
            visible = (d_s2 - d_a2 < r^2) & (r^2 < d_s2);
            
            sensorReading = visible * K / (d_s2 + h^2) + normrnd(0, sigmaA * dt^0.5);
            % end calculating sensor reading
            
        end
    end
end