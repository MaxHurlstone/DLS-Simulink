function plan = buildfile

    % Create a plan from task functions
    plan = buildplan(localfunctions);
    
    % Make the "archive" task the default task in the plan
    plan.DefaultTasks = "archive";
    
    % Make the "archive" task dependent on the "check" and "test" tasks
    plan("archive").Dependencies = "buildlibrary";
    end
    
    function buildlibraryTask(~)
    buildLibrary()
    end
    
    function archiveTask(~)
    
        prjRoot = currentProject().RootFolder;
        tbxFolder = fullfile(prjRoot, "toolbox", "dlsimulink");
        
        pkg = mpmcreate("DLSEngTools",tbxFolder);

        pkg.Summary = "Engineering analysis tools for the UK National Synchrotron.";
        pkg.DisplayName = "DLS Engineering Tools";
        pkg.Readme = "F:\Coding\DLS-Simulink\dlsimulink-local\README.md";
        
        pkg.License = "LICENSE.txt";
        pkg.Categories = ["Engineering", "Simulation"];
        pkgprov = matlab.mpm.Provider();

        pkgprov.Name = "Maxime Hurlstone";
        pkgprov.Organization = "Diamond Light Source Ltd.";
        pkgprov.Email = "max.hurlstone@diamond.ac.uk";
        pkgprov.URL = "https://www.diamond.ac.uk/Home.html";
        pkg.Providers = pkgprov;

end