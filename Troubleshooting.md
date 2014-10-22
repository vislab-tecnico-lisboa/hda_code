######################
### Error description:
######################
```
Error using dateformverify (line 18)
DATESTR failed converting date number to date vector.  Date
number out of range.

Error in waitbar (line 53)
    if  isempty(h) || ~ishandle(h(1)); h =
    buildwaitbar(X,message);	
```
==============	
#### Solution:
Just run the script again, seems to be some time-out issue in matlab, not sure what.

######################
### Error description:
######################
```
Error using drawnow
UIJ_AreThereWindowShowsPending - timeout waiting for window
to show up

Error in cprintf (line 199)
  drawnow;
```

==============	
#### Solution:
Just close all matlab figures and run the script again, seems to be some hang/time-out issue in matlab, not sure what.

######################
### Error description:
######################
```
??? Error using ==> dateformverify at 18
DATESTR failed converting date number to date vector.  Date number out of range.

Error in ==> datestr at 197
S = dateformverify(dtnumber, dateformstr, islocal);

Error in ==> waitbar>updatewaitbar at 158
        r_mes = datestr(sec_remain/86400,'HH:MM:SS');

Error in ==> waitbar>buildwaitbar at 125
    updatewaitbar(h,X,message);              % Updates waitbar if X~=0

Error in ==> waitbar at 53
    if  isempty(h) || ~ishandle(h(1)); h = buildwaitbar(X,message);
```
	
==============	
#### Solution:
Just run the script again, seems to be some time-out issue in matlab, not sure what.

######################
### Error description:
######################
```
??? Error using ==> copyfile
Access is denied.

Error in ==> createallDetections_plusGT_and_NoCrowds at 156
        copyfile([thisExpDetectionsDir '/allDetections_noCrowds.txt'],[thisExpDetectionsDir
        '/allD.txt'])
```

==============	
#### Solution:
Just run the script again

######################
### Error description:
######################
```
??? Index exceeds matrix dimensions.

Error in ==> crop at 84
    seqReader = seqIo( seqName, 'reader'); % Open the input image sequence

Error in ==> fullPipeLineScript at 64
crop();
```

==============	
#### Solution:
Check that the corresponding *.seq file was correctly downloaded, and/or download it again.
