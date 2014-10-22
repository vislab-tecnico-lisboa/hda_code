function rankedPersons = randomReId(HSV,trainingDataStructure)

personIds=unique([trainingDataStructure.personId]);
rankedPersons=personIds(randperm(length(personIds)));
