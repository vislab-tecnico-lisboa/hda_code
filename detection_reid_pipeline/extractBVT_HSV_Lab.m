function BVT_HSV_Labfeature = extractBVT_HSV_Lab(paddedImage,maskset)

BVT_HSV_Labfeature.BVT = extractBVT(paddedImage,maskset);
BVT_HSV_Labfeature.HSV = extractHSVfromBodyParts(paddedImage,maskset);
BVT_HSV_Labfeature.Lab = extractLab(paddedImage,maskset);
% BVT_HSV_Lab_MR8_LBPfeature.MR8 = extractMR8(paddedImage,maskset);
% BVT_HSV_Lab_MR8_LBPfeature.LBP = extractLBP(paddedImage,maskset);
