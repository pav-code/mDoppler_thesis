function [data, dim, found] = find_c3d_parameter( ParameterGroup, GroupName, ParameterName )
    if( isempty(ParameterGroup)==0 )
        for i=1:size(ParameterGroup,2)
            if strcmp( ParameterGroup(i).name, GroupName )
                for j=1:size( ParameterGroup(i).Parameter, 2 )
                    if strcmp( ParameterGroup(i).Parameter(j).name, ParameterName ) 
                        data = ParameterGroup(i).Parameter(j).data;
                        dim = ParameterGroup(i).Parameter(j).dim;
                        found = 1;
                        return;
                    end
                end
            end
        end
    end
    
    found = 0;
    data = [];
    dim = [];
end