function Train_RNN()

% creates and trains a RNN using Genetic algorithm.

networks=[];
for(i=1:20) % Create the population
    nn=NeuralNetwork();
    nn.setInput(2);
    nn.addNewLayer(4);
    nn.addNewLayer(5);
    nn.addNewLayer(4);
    nn.setOutput(3);
    networks=[networks,nn];
end
threshold=7; % Threshold of fitness sharing
coef=0;
score=0;

saved_poses=[];
saved_sensations=[];
saved_actions=[];
saved_states=[];
past_scores=[];

for(j=1:200) % Iterates 200 generations
    j
    orientation_arr=[];
    scores=[];
    for(orient=1:20)% Create 20 random unique orientatis
        orientation_arr=[orientation_arr,rand() * 2 * pi/10+2*pi/20*(orient-1)];
    end
       
    for(i=1:length(networks))
        nn=networks(i);
        trial_scores=[];
        
     for(trials=1:20)
            %run simulation with the generated orientations
            [ poses, sensations, actions, states ] = train_assignmentSimulation(@nn.predict,orientation_arr(trials));
            sensations(isnan(sensations))=0;

            [row1,row2]=find(poses(:,2)<=1 &poses(:,2)>=-1 & poses(:,1)>=9 & poses(:,1)<=11);
            
            if isempty(row1)||isempty(row2)
                trial_scores=[trial_scores,mean(sensations)]; % Could not arrived to the light
            elseif(any(row1==row2) ||any((poses(:,1))<=-5) || any((poses(:,2))<=-5))
                trial_scores=[trial_scores,-10]; % passed the light or went opposite way
            elseif(any(sensations>=1)) % reached the light or got too close
                last=find(sensations>=1);
                stay_penalty=0;
                if length(last)>100 % staying too much in the light, apply discouragement 
                    stay_penalty=(length(last)-100)/25;
                end
                % check if it is returning
                last=last(end);
                accourance=length(find(sensations>=1));
                y_coord=poses(:,2);
                y_coords=y_coord(last:end);
                x_coord=poses(:,1);
                x_coords=x_coord(last:end);
                [c_x_v,c_x_i]=min(abs(x_coords));
                c_y_v=y_coords(c_x_i);
                return_val=1;
                return_score=1000-10*(abs(c_x_v)+abs(c_y_v));
                if(abs(c_x_v)<=1 && abs(c_y_v)<=1)
                    return_val=10; % agent returned to the starting position
                  
                 end
                
                trial_scores=[trial_scores,mean(sensations)+0.06*accourance*return_val+return_score-stay_penalty];
                
            else
                trial_scores=[trial_scores,mean(sensations)];
            end
            
            if(score<trial_scores(trials)) % save the best simulation for later observation
                score=trial_scores(trials);
                saved_poses=poses;
                saved_sensations=sensations;
                saved_actions=actions;
                saved_states=states;
            end
        end
        
        scores=[scores,mean(trial_scores)];
        
    end
    
    %fitness sharing
    share_matrix=[];
        for c=1:length(networks)
            difference=0;
            for e=1:length(networks)
                
                for per_mat=1:length(networks(1).layerMatrix)

                     if(difference<threshold) % calculate difference between individuals
                         sub_difference=sum(sum(abs(networks(c).layerMatrix{per_mat}-networks(e).layerMatrix{per_mat})));
                     else
                        sub_difference=0;
                    end
                    
                    difference=difference-1*threshold+sub_difference*threshold*0.1*scores(e);
                end
            end
            
           
            share_matrix=[share_matrix,difference];
        end
    %
   
    share_matrix=share_matrix*coef;
    combined_scores=scores+share_matrix;
    
    [c_v,index]=max(combined_scores);
    v=(scores(index));
    v
    c_v
    past_scores=[past_scores,v];
    
    [c_v,index]=max(scores);
    scores=combined_scores;
    
    next_gen=networks(index);
    fittest=next_gen(1).layerMatrix;
    save 'return_whole_population.mat' networks % save new generation
    
    % roulette wheel selection
    wheel=cumsum(scores);
    wheel=wheel*1000;
    [maximum,index]=max(wheel);
    [minumum,index]=min(wheel);
    for(k=2:length(networks))
        
        random2=rand()*(maximum-minumum)+minumum;
        paren2=1;
        for(w=2:length(wheel))
            
           
            if(wheel(w-1)>=random2 && wheel(w)<random2)
                paren2=w;
            end
        end
        
        child=networks(k).crossOver(networks(paren2));
        child.mutate();
        next_gen=[next_gen,child];
        
    end
    networks=next_gen;
    
    %adjust coefficient of fitness sharing
    if(length(past_scores)>2 & issorted(past_scores((end-2):end),'ascend'))
        coef=coef+0.0001;
    elseif(length(past_scores)>2& issorted(past_scores((end-2):end),'descend'))
        coef=coef-0.0001;
    else
        coef=0;
  
    end
    %
    
end
visualiseAssignment(saved_poses, saved_sensations, saved_actions, saved_states);
fittest=next_gen(1).layerMatrix;
save 'fit_nn.mat' fittest

end
