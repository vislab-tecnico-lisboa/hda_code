%% Set 6 masks, 6 horizontal bars, in an 128x64 image
function masks6horizontalbars = Set_6_masks_6_horizontal_bars_in_an_128x64_image()

emptymask = false(128,64);

rectangle1 = emptymask;
rectangle1(1:22) = true;

rectangle2 = emptymask;
rectangle2(22:43) = true;

rectangle3 = emptymask;
rectangle3(43:64) = true;

rectangle4 = emptymask;
rectangle4(64:85) = true;

rectangle5 = emptymask;
rectangle5(85:106) = true;

rectangle6 = emptymask;
rectangle6(106:128) = true;

masks6horizontalbars = {rectangle1, rectangle2, rectangle3, rectangle4, rectangle5, rectangle6};
