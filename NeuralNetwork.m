
classdef NeuralNetwork < handle
    
    properties(Access=public)
        
        layerMatrix{};
        threshold{};
        inputNmbr=0;
        outputNmbr=0;
        numberOfLayers=0;
        percentageOfMutations=10;
        mutationCoef=1;
        recurring_values{};
        recurring_weights{};
        layer_counts=[];
        recurring=1;
    end
    methods(Access=public)
        
        function obj=NeuralNetwork()
           
        end
        
        function setInput(obj,input)
            
            obj.inputNmbr=input; 
            
        end
         function setOutput(obj,output)
            
            obj.outputNmbr=output;
            obj.addNewLayer(output);
         end
        
         function setThreshold(obj,newThresholds,loc)
             
         end
         
         function product=crossOver(obj,parent)
             
             for i=1:length(obj.recurring_values)
                    
                     cur_layer=obj.recurring_values{i};
                     obj.recurring_values{i}=zeros(size(obj.recurring_values{i}));
                     parent.recurring_values{i}=zeros(size(parent.recurring_values{i}));
             end

            networkInfo=[parent.inputNmbr,parent.outputNmbr,obj.layer_counts(1:end-1)];%-----------------------
            product=NeuralNetwork;
            
            product.setInput(networkInfo(1));
            
            for(i=3:length(networkInfo))
                 product.addNewLayer(networkInfo(i));
            end
            
            product.setOutput(networkInfo(2));
            
             layer=round(rand(1)*(length(obj.layerMatrix)-1))+1;
%             [m,n]=size(obj.layerMatrix{layer});
%             rowS=round(rand(1)*(m-2)+1);
%             rowE=round(((rand(1)*(m-rowS-1))+rowS+1));
%             columnS=round(rand(1)*(n-2)+1);
%             columnE=round(((rand(1)*(n-columnS-1))+columnS+1));
%             aPart=obj.getPart(rowS,rowE,columnS,columnE,layer);
%             
            AllMatrix=parent.layerMatrix;
            
            %AllMatrix(rowS:rowE,columnS:columnE)=aPart;
            if(round(rand(1))==1)
            product.layerMatrix={AllMatrix{1:layer},obj.layerMatrix{layer+1:end}};
            product.recurring_weights={parent.recurring_weights{1:layer},obj.recurring_weights{layer+1:end}};
            else
            product.layerMatrix={obj.layerMatrix{1:layer},parent.layerMatrix{layer+1:end}};
            product.recurring_weights={obj.recurring_weights{1:layer},parent.recurring_weights{layer+1:end}};
            end
             
         end
         
         function aPart=getPart(obj,rowS,rowE,columnS,columnE,layer)
             aPart=obj.layerMatrix{layer};
             
             aPart=aPart(rowS:rowE,columnS:columnE);
         end
         
        function addNewLayer(obj,numberOfNodes)
            obj.layer_counts=[obj.layer_counts,numberOfNodes];
            obj.numberOfLayers=obj.numberOfLayers+1;
            
            obj.recurring_values{obj.numberOfLayers}=zeros(1,numberOfNodes);
            obj.recurring_weights{obj.numberOfLayers}=rand(numberOfNodes,1)-0.5;
            
            if(obj.numberOfLayers==1)
                l1=rand(obj.inputNmbr,numberOfNodes);
               obj.layerMatrix={l1};
               obj.threshold={ones(1,numberOfNodes)/2};
               
            else
                temp=obj.layerMatrix{obj.numberOfLayers-1};
                [m,n]=size(temp);
                l1=rand(n,numberOfNodes)-0.5;
                obj.layerMatrix{obj.numberOfLayers}=l1;
                obj.threshold{obj.numberOfLayers}= rand(1,numberOfNodes)/2;
       
            end
            
            
        end
        
        function mutate(obj)
            totalGenes=0;
            
            for i=1:length(obj.layerMatrix)
            curMatrix=obj.layerMatrix{i};
            [m,n]=size(curMatrix);
            totalGenes=totalGenes+(m*n);
            end
            
            %numberOfMutations=round((totalGenes*obj.percentageOfMutations)/100);
            numberOfMutations=2;
            
            if(numberOfMutations==0)
                numberOfMutations=1;
            end
            
            for(i=1:numberOfMutations)
                randomLayer=round(rand(1)*(length(obj.layerMatrix)-1))+1;
                curLayer=obj.layerMatrix{randomLayer};
                randomIter= round(rand(1)*numberOfMutations-1)+1;
                for(j=1:randomIter)
                     [m,n]=size(curLayer);
                     randomCol=round(rand(1)*(n-1))+1;
                     randomRow=round(rand(1)*(m-1))+1;
                     curLayer(randomRow,randomCol)=curLayer(randomRow,randomCol)+rand(1)*(obj.mutationCoef)-(obj.mutationCoef/2);
                     numberOfMutations=numberOfMutations-1;
                end
                obj.layerMatrix{randomLayer}=curLayer;
                
            end
            
             for(i=1:numberOfMutations)
                randomLayer=round(rand(1)*(length(obj.recurring_weights)-1))+1;
                curLayer=obj.recurring_weights{randomLayer};
                randomIter= round(rand(1)*numberOfMutations-1)+1;
                for(j=1:randomIter)
                     [m,n]=size(curLayer);
                     randomCol=round(rand(1)*(n-1))+1;
                     randomRow=round(rand(1)*(m-1))+1;
                     curLayer(randomRow,randomCol)=curLayer(randomRow,randomCol)+rand(1)*(obj.mutationCoef)-(obj.mutationCoef/2);
                     numberOfMutations=numberOfMutations-1;
                end
                obj.recurring_weights{randomLayer}=curLayer;
                
            end
            
        end
        
        function replaceLayer(obj,newWeights,layerNumber)
            
            obj.layerMatrix{layerNumber}=newWeights;
        end   
        
        function res=predict(obj,inputVector,vals)
            
            if isempty(vals)
                vals=0.0;
            end
           curValues=[inputVector,vals];
           for i=1:obj.numberOfLayers
               
               curLayer=obj.layerMatrix{i};
               
               
               if(obj.recurring==0)
                   curValues=curValues*curLayer;
               else
                   curValues=curValues*curLayer+obj.recurring_values{i}*obj.recurring_weights{i};
               end
               
              
               curValues=tanh(curValues);
              
               curValues(isnan(curValues))=0;
               if(obj.recurring==1)
               obj.recurring_values{i}=curValues;
               end
               
           end
           res=curValues;
           
           
        end
        
       
    end
end