function BVT_HSV_Lab_MR8_LBPfeature = extractBVT_HSV_Lab_MR8_LBP(paddedImage,maskset)

BVT_HSV_Lab_MR8_LBPfeature.BVT = extractBVT(paddedImage,maskset);
BVT_HSV_Lab_MR8_LBPfeature.HSV = extractHSVfromBodyParts(paddedImage,maskset);
BVT_HSV_Lab_MR8_LBPfeature.Lab = extractLab(paddedImage,maskset);
BVT_HSV_Lab_MR8_LBPfeature.MR8 = extractMR8(paddedImage,maskset);
BVT_HSV_Lab_MR8_LBPfeature.LBP = extractLBP(paddedImage,maskset);
