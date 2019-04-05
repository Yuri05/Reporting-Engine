function ConfigurationPlan = getConfigurationPlan(jsonFile)
%GETCONFIGURATIONPLAN Support function:
% Read a .json ConfigurationPlan and output the .json structure and create
% the folder structure for the report
%
%   getConfigurationPlan(jsonFile)
%       jsonFile (string) name .json file where the information of the
%       configuration plan is stored
%

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org

%--------------------------------------------------
% Read .json file and output its structure

try
    jsonFileContent = fileread(jsonFile);
    ConfigurationPlan = jsondecode(jsonFileContent);
    writeToReportLog('INFO',[jsonFile ' was extracted successfully'],'true');
catch exception
    writeToReportLog('ERROR', [jsonFile ' could not be extracted:' exception.message], 'true', exception);
end

% Check if every important parts are within the .json content
mandatoryFields = {'SimulationMappings', 'ObservedDataSets', 'Plots', 'Inputs', 'Sections'};

for i=1:length(mandatoryFields)
    if ~isfield(ConfigurationPlan, mandatoryFields)
        writeToReportLog('ERROR',[mandatoryFields(i) ' is missing from ' jsonFile],'false');
    end
end
