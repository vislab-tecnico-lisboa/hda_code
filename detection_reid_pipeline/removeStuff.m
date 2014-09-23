
testCamera  = [17 18 19 40 50 53 54 56 57 58 59 60];
for set = 1:size(testCamera,2)
        
   %%% WARNING REMOVE ME REMOVE ME !!! ???     
   %system(['rm /home/matteo/PhD/MyCode/ReId/HdaRoot/TestData/AcfInria/cam' int2str(testCamera(set)) '/Crops/*.png']);
   system(['rm -rf /home/matteo/PhD/MyCode/ReId/HdaRoot/TestData/AcfInria/cam' int2str(testCamera(set)) '/Crops']);
   system(['rm -rf /home/matteo/PhD/MyCode/ReId/HdaRoot/TestData/AcfInria/cam' int2str(testCamera(set)) '/FilteredCrops']);
   system(['rm -rf /home/matteo/PhD/MyCode/ReId/HdaRoot/TestData/AcfInria/cam' int2str(testCamera(set)) '/ReIdsRandom']);
   system(['rm -rf /home/matteo/PhD/MyCode/ReId/HdaRoot/TestData/AcfInria/cam' int2str(testCamera(set)) '/ReIdsAndGtsRandom']);
   
end