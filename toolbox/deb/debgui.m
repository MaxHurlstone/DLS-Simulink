function debgui

    fig = uifigure("Position",[500,500,240,250]);
    fig.Name = "DEB App";

    g1 = uigridlayout(fig);

    resEf = uieditfield(g1,"numeric", "ValueDisplayFormat","%.2f","Value",5000,"Placeholder","Enter value");
    resEf.Layout.Row = 1;
    resEf.Layout.Column = [1,2];
    fminEf = uieditfield(g1,"numeric", "ValueDisplayFormat","%.2f Hz","Value",0.1,"Placeholder","Enter value");
    fminEf.Layout.Row = 2;
    fminEf.Layout.Column = [1,2];
    tsEf = uieditfield(g1,"numeric", "ValueDisplayFormat","%.3f s","Value",0.001,"Placeholder","Enter value");
    tsEf.Layout.Row = 3;
    tsEf.Layout.Column = [1,2];
    oEf = uieditfield(g1,"numeric", "ValueDisplayFormat","%.0f","Value",1,"Placeholder","Enter value");
    oEf.Layout.Row = 4;
    oEf.Layout.Column = [1,2];

    loadsysBtn = uibutton(g1);
    loadsysBtn.ButtonPushedFcn = @loadSystemButtonPushed;
    loadsysBtn.Layout.Row = 5;
    loadsysBtn.Layout.Column = [1,2];
    loadsysBtn.Text = "Load system";

    loaddataBtn = uibutton(g1);
    loaddataBtn.ButtonPushedFcn = @loadDisturbanceButtonPushed;
    loaddataBtn.Layout.Row = 6;
    loaddataBtn.Layout.Column = [1,2];
    loaddataBtn.Text = "Load disturbance data";

    runBtn = uibutton(g1);
    runBtn.ButtonPushedFcn = @runButtonPushed;
    runBtn.Layout.Row = 7;
    runBtn.Layout.Column = [1,2];
    runBtn.Text = "Run DEB";
    runBtn.BackgroundColor = [0.1 0.8 0.1];

    % Store data in figure
    system = ss;
    datapaths = {};
    fields = {resEf,fminEf,esEf,oEf};

    fig.UserData = struct("system",system,"datapaths",datapaths,"datafields",fields);

end

function loadSystemButtonPushed(src,event)
    fig = ancestor(src,"figure","toplevel");
    data = fig.UserData;

    [file,location] = uigetfile('.mat');
    TransF    = load(fullfile(location,file));
    system   = TransF.LinearAnalysisToolProject.Results.Data.Value;

    data.system = system;
end

function loadDisturbanceButtonPushed(src,event)
    fig = ancestor(src,"figure","toplevel");
    data = fig.UserData;

    [file,location] = uigetfile('.csv','MultiSelect','on');
    
    data.datapaths = fullfile(location,file);

end

function runButtonPushed(src,event)

    

    rundeb();
end
