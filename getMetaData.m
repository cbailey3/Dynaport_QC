function mmInfo = getMetaData(fn,xmltree,dbHandle)

if nargin == 1
    xmltree = [];
    dbHandle = [];
end

% prog = which('convert.exe');
[status,res] = dos(strcat('convert.exe' ,' "',fn,'"  -t:matlab -stream !'));
pos = strfind(res,'CONVERT');
result = res(1:pos-1);
formatStr = '%s';
temp = textscan(result,formatStr,'Delimiter','\n');
for iLine = 1:size(temp{1},1)
    line = temp{1}{iLine};
    items = explode(',',line);
    if ~isempty(items) && all(~strcmp({'comments';'filename'},items{1}))
        if strcmp(items{1},'metadata')
            if isempty(xmltree)
                subItems = explode(';',items{2});
                for iSI = 1:size(subItems,2)
                    [name,value] = strtok(subItems{iSI},'=');
                    %                 if strcmp(name,'mid')
                    %                     mid = str2num(strtrim(value(2:end)));
                    %                     break;
                    %                 end
                    if ~isempty(value)
                        if~isnan(str2double(strrep(value,'=','')))
                            customData.(name) = str2double(strrep(value,'=',''));
                        else
                            customData.(name) = strrep(value,'=','');
                        end                    
                    end
                    
                end
            else
                if nargin<3
                    dbHandle = dbconnect('mymcroberts2');
                end
                query = sprintf(['SELECT measurements.`measurement_id`, measurements.`user_id`, measurements.`project_id` ' ...
                    ', measurements.`subject_id`, measurements.`visit_id`, measurements.`protocol_id` ' ...
                    'FROM  `measurements`, `requests` WHERE  measurements.`measurement_id` = requests.measurement_id AND requests.request_id = %d'],str2double(xmltree.ATTRIBUTE.id));
                
                curs=fetch(exec(dbHandle,query));
                customData = tostruct(curs);
                if nargin<3
                    dbdisconnect(dbHandle,curs);
                end
            end            
            mmInfo.identifiers = customData;
        elseif length(items) > 1
            mmInfo.(items{1}) = items{2};
        end
        
    end
end
