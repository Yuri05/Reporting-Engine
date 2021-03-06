function  SectionsOut = generateOutputFolders(SectionsIn, REInputFolder, REOutputFolder)
%GENERATEOUTPUTFOLDERS Support function:
% Explore tree of sections and generate folders of sections within REOutputFolder
% linearize the section structure
%
%   generateOutputFolders(SectionsIn, REOutputFolder)
%       SectionsIn (structure or cell) sections to be created
%       REOutputFolder (string) name of folder where the sections
%

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org

%---------------------------------------------------

% Standardize all input sections into cell class
if ~iscell(SectionsIn)
    SectionsIn = num2cell(SectionsIn);
end

% Initialize output sections
SectionsOut=[];

% Loop on every section
for i = 1:length(SectionsIn)
    
    % Get Section Id
    SectionIndex=length(SectionsOut)+1;
    SectionsOut(SectionIndex).Id=SectionsIn{i}.Id;
    SectionsOut(SectionIndex).Title=SectionsIn{i}.Title;
    
    % Create folder and add its path in the structure
    Path = fullfile(REOutputFolder, sprintf('%0.3d_%s', i, removeForbiddenLetters(SectionsIn{i}.Title)));
    SectionsOut(SectionIndex).Path = Path;
    
    try
        mkdir(Path);
        % Create title markdown
        fileID = fopen(fullfile(Path, '_title.md'),'wt');
        fprintf(fileID,'%s\n',SectionsOut(SectionIndex).Title);
        fclose(fileID);
    catch exception
        writeToReportLog('ERROR', [sprintf('Error in Section Id %d: Section Title %s could not be created : \n', SectionsOut(SectionIndex).Id, SectionsOut(SectionIndex).Title), exception.message], 'true', exception);
        rethrow(exception);
    end
    
    % Copy the content of the section within the folder
    SectionsOut(SectionIndex).Content = SectionsIn{i}.Content;
    
    try
        copyfile(fullfile(REInputFolder, SectionsOut(SectionIndex).Content), fullfile(Path, '_content.md'));
    catch exception
        writeToReportLog('ERROR', [sprintf('Error in Section Id %d: %s could not be copied : \n', SectionsOut(SectionIndex).Id, fullfile(REInputFolder, SectionsOut(SectionIndex).Content)), exception.message], 'true', exception);
        rethrow(exception);
    end
    
    % Check for sub-Sections
    if isfield(SectionsIn{i}, 'Sections')
        if ~isempty(SectionsIn{i}.Sections)
            % Repeat the process from this folder
            SubSectionsOut = generateOutputFolders(SectionsIn{i}.Sections, REInputFolder, Path);
            for j=1:length(SubSectionsOut)
                SectionsOut(SectionIndex+j)=SubSectionsOut(j);
            end
        end
    end
end
