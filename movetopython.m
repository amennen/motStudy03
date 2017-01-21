% purpose: get things ready for Python analysis:
%check if current data has good classification using first 4 vs. all TR's
%need: locpatterns data for each subject
%subject numbers
%what to name them
%final path
folder= '/jukebox/norman/amennen/PythonMot3';
subjectVec = [3 4 5 6];
for s = 1:length(subjectVec)
    subjectNum = subjectVec(s);
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    loc_dir = ['/Data1/code/' projectName '/' 'data' '/' num2str(subjectNum) '/Localizer/'];

    fname = findNewestFile(loc_dir, fullfile(loc_dir, ['locpatterns' '*.mat']));
    newname = ['pat' num2str(s) '.mat'];
    unix(['scp ' fname ' amennen@apps.pni.princeton.edu:' folder '/' newname])
end
