function writeCsvFile(filename, cols_numeric, remainingColsCell)

numberOfAdditionalColumns = size(remainingColsCell,2);

fid = fopen(filename,'w');
for m=1:size(cols_numeric,1)
    fprintf(fid,'%f',cols_numeric(m,1));
    for n=2:size(cols_numeric,2)
        fprintf(fid,' %f',cols_numeric(m,n));
    end
    for n=1:numberOfAdditionalColumns
        fprintf(fid,' %s',remainingColsCell{m,n});
    end
    fprintf(fid,'\n');
end
fclose(fid);

end