clear
clc

foldernumber = 1:14;
for i = [3 4 9 10]
    foldernumber(foldernumber==i)=[];
end
foldernumber = cellstr(num2str((foldernumber).', '%02d'));
for i = 1:length(foldernumber)
    mkdir(strcat("tDCS",foldernumber(i)))
end