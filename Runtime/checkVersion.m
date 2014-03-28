function checkVersion(ChainVersion)
global VersionHasErrors;
VersionHasErrors = false;
oldChainVersion = 0;
if exist(['Runtime' filesep 'Version.mat'], 'file')
    load(['Runtime' filesep 'Version.mat']);
end
if oldChainVersion < ChainVersion
    try
        if exist('Temp', 'dir')
            rmdir('Temp', 's');
        end
    catch exp
        VersionHasErrors = true;
        h = warndlg('New Version! Unable to remove Temp-Folder! Please close Matlab and delete Temp-Folder manually!');
        waitfor(h);
        return;
    end
    oldChainVersion = ChainVersion;
    save(['Runtime' filesep 'Version.mat'], 'oldChainVersion');
end

end