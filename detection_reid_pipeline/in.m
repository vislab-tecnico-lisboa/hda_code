function in(H,byteflag)
% function in(H)
%
% displays size, min, max, type, bytes, std, mean and med of H

if ~exist('byteflag','var')
    byteflag = 0;
end

display(['size     ' int2str(size(H))])

s=whos('H');
display(['type     ' s.class]),
display(['bytes    ' bytesreadable(s.bytes)]),

if byteflag
    return
end

try
    %     display(['min-max  ' num2str(min(H(:))) '-' num2str(max(H(:)))])
    display(['min-max  [' num2str(min(H(:))) '  ' num2str(max(H(:))) ']'])
catch me
    display(['min-max  ' me.message])
end

try
    display(['std      ' num2str(std(H(:)))])
catch me
    display(['std      ' me.message])
end
try
    display(['mean     ' num2str(mean(H(:)))])
catch me
    display(['mean     ' me.message])
end
try
    display(['med      ' num2str(median(H(:)))])
catch me
    display(['med      ' me.message])
end

try
    ind= H == 0;
    display(['sparcity ' num2str(sum(ind(:))/length(ind(:))*100) '%'])
catch me
    display(['sparcity ' me.message])
end

end



function string = bytesreadable(bytes)
% function string = bytesreadable(bytes)
%
% Turns an integer number (supposedly a byte size number) into a string
% with the byte size number in a human readable fashion
%

if bytes < 1024
    string = [int2str(bytes) ' B'];
elseif bytes < 1024*1024
    Kbytes = bytes/1024;
    string = [int2str(Kbytes) ' KB'];
elseif bytes < 1024*1024*1024
    Mbytes = bytes/1024/1024;
    string = [int2str(Mbytes) ' MB'];
elseif bytes < 1024*1024*1024*1024
    Gbytes = bytes/1024/1024/1024;
    string = [int2str(Gbytes) ' GB'];
else % bytes < 1024*1024*1024*1024*1024
    Tbytes = bytes/1024/1024/1024/1024;
    string = [int2str(Tbytes) ' TB'];
end
end