%Output File Editor
fileID = fopen('hw3_output_formatted.txt', 'w');

fprintf(fileID, '%s\r\n', '    X^0.8       X^0.49       X^0.23');
fprintf(fileID, '%s\r\n', '--------------------------------------');
for i = 0:255
    k = dec2bin(i,8);                %Number of interation
    x = bin2dec(k)./128;
    f = x^0.8;                      %f(x)=x^0.8
    g = x^0.49;                      %f(x)=x^0.8
    h = x^0.23;                      %f(x)=x^0.8
    xoutf = bin(ufi(f,12,11));        %Convert to binary [12 11]
    fprintf(fileID, '%s ', xoutf); %Print to the text file and write to new line
    xoutg = bin(ufi(g,12,11));        %Convert to binary [12 11]
    fprintf(fileID, '%s ', xoutg); %Print to the text file and write to new line
    xouth = bin(ufi(h,12,11));        %Convert to binary [12 11]
    fprintf(fileID, '%s\r\n', xouth); %Print to the text file and write to new line
end

fclose(fileID);
