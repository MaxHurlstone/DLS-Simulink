classdef SloperApp < matlab.apps.AppBase

    properties (Access = public)
        AppConfigFilename string = "SloperApp.xml"
        UIFigure                   matlab.ui.Figure
        MainGrid                   matlab.ui.container.GridLayout
        TabGroup                   matlab.ui.container.TabGroup

        ImportTab                  matlab.ui.container.Tab
        ImportGrid                 matlab.ui.container.GridLayout
        FileButton                 matlab.ui.control.Button
        FilePathField              matlab.ui.control.EditField
        DatasetNameLabel           matlab.ui.control.Label
        DatasetNameField           matlab.ui.control.EditField
        DataTypeDropdown           matlab.ui.control.DropDown
        DirectionDropdown          matlab.ui.control.DropDown
        AddDatasetButton           matlab.ui.control.Button
        DatasetListBox             matlab.ui.control.ListBox
        RemoveDatasetButton        matlab.ui.control.Button
        ExportDirField             matlab.ui.control.EditField
        BrowseExportDirButton      matlab.ui.control.Button
        DverField                  matlab.ui.control.EditField
        BlnameField                matlab.ui.control.EditField
        OptnameField               matlab.ui.control.EditField
        ScenameField               matlab.ui.control.EditField
        ExportDatasetDropdown      matlab.ui.control.DropDown
        ExportStatusLabel          matlab.ui.control.Label
        ImportExportButton         matlab.ui.control.Button

        AnalysisTab                matlab.ui.container.Tab
        AnalysisGrid               matlab.ui.container.GridLayout
        ParamPanel                 matlab.ui.container.GridLayout
        DatasetDropdown            matlab.ui.control.DropDown
        NxxField                   matlab.ui.control.Spinner
        NyyField                   matlab.ui.control.Spinner
        NpField                    matlab.ui.control.Spinner
        FIDCheckBox                matlab.ui.control.CheckBox
        OrderField                 matlab.ui.control.Spinner
        SymCheckBox                matlab.ui.control.CheckBox
        RunButton                  matlab.ui.control.Button
        ExportDataButton           matlab.ui.control.Button
        AnalysisStatusLabel        matlab.ui.control.Label
        plotStack                  matlab.ui.container.GridLayout
        TopPlotGroup               matlab.ui.container.GridLayout
        ContourPlotSag             matlab.graphics.axis.Axes
        ContourPlotLon             matlab.graphics.axis.Axes
        BottomPlotGroup            matlab.ui.container.GridLayout
        LinePlotAx1                matlab.graphics.axis.Axes
        LinePlotAx2                matlab.graphics.axis.Axes
        LinePlotAx3                matlab.graphics.axis.Axes
        LinePlotAx4                matlab.graphics.axis.Axes
        UnitMM                     matlab.ui.control.Button
        UnitUM                     matlab.ui.control.Button
        UnitNM                     matlab.ui.control.Button
        StatsLabelSagRMS           matlab.ui.control.Label
        StatsLabelSagSTD           matlab.ui.control.Label
        StatsLabelLonRMS           matlab.ui.control.Label
        StatsLabelLonSTD           matlab.ui.control.Label

        ComparisonTab              matlab.ui.container.Tab
        ComparisonGrid             matlab.ui.container.GridLayout
        CompLeftGrid               matlab.ui.container.GridLayout
        CompUnitGrid               matlab.ui.container.GridLayout
        CompTree                   matlab.ui.container.CheckBoxTree
        CompareButton              matlab.ui.control.Button
        CompPlotGrid               matlab.ui.container.GridLayout
        CompDeformationAx          matlab.graphics.axis.Axes
        CompSlopeAx                matlab.graphics.axis.Axes
        CompUnitMM                 matlab.ui.control.Button
        CompUnitUM                 matlab.ui.control.Button
        CompUnitNM                 matlab.ui.control.Button
        UnitGrid                   matlab.ui.container.GridLayout
        StatsGrid                  matlab.ui.container.GridLayout
    end

    properties (Access = private)
        Datasets         cell = {}
        SelectedIndex    double = 0
        ExportDir        string = ""
        CurrentUnit      string = "mm"
    end

    properties (Access = private)
        DefaultNxx    double = 100
        DefaultNyy    double = 20
        DefaultFID    logical = false
        DefaultOrder  double = 3
        DefaultSym    logical = false
        DefaultNp     double = 10
    end

    methods (Access = public)
        function app = SloperApp
            createComponents(app)
            registerApp(app, app.UIFigure)
            startup(app)
            if nargout == 0
                clear app
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('HandleVisibility', 'callback');

            app.MainGrid = uigridlayout(app.UIFigure, [1, 1]);
            app.MainGrid.RowHeight = {'1x'};
            app.MainGrid.ColumnWidth = {'1x'};
            app.MainGrid.Padding = [0, 0, 0, 0];
            app.MainGrid.RowSpacing = 0;
            app.MainGrid.ColumnSpacing = 0;

            app.TabGroup = uitabgroup(app.MainGrid);

            % ============ Tab 1: Import Data ============
            app.ImportTab = uitab(app.TabGroup, 'Title', 'Import Data');
            app.ImportGrid = uigridlayout(app.ImportTab, [17, 2]);
            app.ImportGrid.RowHeight = {'fit','fit','fit','fit',80,80,'fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit'};
            app.ImportGrid.ColumnWidth = {'fit', 250};
            app.ImportGrid.Padding = [10, 10, 10, 10];
            app.ImportGrid.RowSpacing = 5;
            app.ImportGrid.ColumnSpacing = 5;

            app.FileButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.FileButtonPushed);
            app.FileButton.Text = 'Browse File...';
            app.FileButton.Tooltip = 'Select ANSYS .txt file';
            app.FileButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.FileButton.FontColor = [0.996, 0.835, 0.008];
            app.FileButton.Layout.Row = 1;
            app.FileButton.Layout.Column = 1;

            app.FilePathField = uieditfield(app.ImportGrid);
            app.FilePathField.Editable = false;
            app.FilePathField.Layout.Row = 1;
            app.FilePathField.Layout.Column = 2;

            app.DatasetNameLabel = uilabel(app.ImportGrid);
            app.DatasetNameLabel.Text = 'Dataset Name:';
            app.DatasetNameLabel.FontWeight = 'bold';
            app.DatasetNameLabel.Layout.Row = 2;
            app.DatasetNameLabel.Layout.Column = 1;

            app.DatasetNameField = uieditfield(app.ImportGrid);
            app.DatasetNameField.Layout.Row = 2;
            app.DatasetNameField.Layout.Column = 2;

            app.DataTypeDropdown = uidropdown(app.ImportGrid);
            app.DataTypeDropdown.Items = {'2D', '1D'};
            app.DataTypeDropdown.Value = '2D';
            app.DataTypeDropdown.Tooltip = 'Select data type (2D surface or 1D profile)';
            app.DataTypeDropdown.ValueChangedFcn = @app.DataTypeDropdownChanged;
            app.DataTypeDropdown.Layout.Row = 3;
            app.DataTypeDropdown.Layout.Column = 1;

            app.DirectionDropdown = uidropdown(app.ImportGrid);
            app.DirectionDropdown.Items = {'Sagittal', 'Longitudinal'};
            app.DirectionDropdown.Value = 'Sagittal';
            app.DirectionDropdown.Enable = false;
            app.DirectionDropdown.Tooltip = 'Select profile direction for 1D data';
            app.DirectionDropdown.Layout.Row = 3;
            app.DirectionDropdown.Layout.Column = 2;

            app.AddDatasetButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.AddDatasetButtonPushed);
            app.AddDatasetButton.Text = 'Add Dataset';
            app.AddDatasetButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.AddDatasetButton.FontColor = [0.996, 0.835, 0.008];
            app.AddDatasetButton.FontWeight = 'bold';
            app.AddDatasetButton.Layout.Row = 4;
            app.AddDatasetButton.Layout.Column = [1, 2];

            app.DatasetListBox = uilistbox(app.ImportGrid);
            app.DatasetListBox.Items = {''};
            app.DatasetListBox.ValueChangedFcn = @app.DatasetListBoxChanged;
            app.DatasetListBox.Layout.Row = [5, 6];
            app.DatasetListBox.Layout.Column = [1, 2];

            app.RemoveDatasetButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.RemoveDatasetButtonPushed);
            app.RemoveDatasetButton.Text = 'Remove Dataset';
            app.RemoveDatasetButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.RemoveDatasetButton.FontColor = [0.996, 0.835, 0.008];
            app.RemoveDatasetButton.FontWeight = 'bold';
            app.RemoveDatasetButton.Layout.Row = 7;
            app.RemoveDatasetButton.Layout.Column = [1, 2];

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'Export Directory:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 8;
            lbl.Layout.Column = 1;

            app.ExportDirField = uieditfield(app.ImportGrid);
            app.ExportDirField.Editable = false;
            app.ExportDirField.Layout.Row = 8;
            app.ExportDirField.Layout.Column = 2;

            app.BrowseExportDirButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.BrowseExportDirButtonPushed);
            app.BrowseExportDirButton.Text = 'Browse...';
            app.BrowseExportDirButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.BrowseExportDirButton.FontColor = [0.996, 0.835, 0.008];
            app.BrowseExportDirButton.Layout.Row = 9;
            app.BrowseExportDirButton.Layout.Column = [1, 2];

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'dver:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 10;
            lbl.Layout.Column = 1;

            app.DverField = uieditfield(app.ImportGrid);
            app.DverField.Value = 'TEST';
            app.DverField.Layout.Row = 10;
            app.DverField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'blname:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 11;
            lbl.Layout.Column = 1;

            app.BlnameField = uieditfield(app.ImportGrid);
            app.BlnameField.Value = 'X';
            app.BlnameField.Layout.Row = 11;
            app.BlnameField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'optname:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 12;
            lbl.Layout.Column = 1;

            app.OptnameField = uieditfield(app.ImportGrid);
            app.OptnameField.Value = 'X';
            app.OptnameField.Layout.Row = 12;
            app.OptnameField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'scename:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 13;
            lbl.Layout.Column = 1;

            app.ScenameField = uieditfield(app.ImportGrid);
            app.ScenameField.Value = 'X';
            app.ScenameField.Layout.Row = 13;
            app.ScenameField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'Dataset to Export:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 14;
            lbl.Layout.Column = 1;

            app.ExportDatasetDropdown = uidropdown(app.ImportGrid);
            app.ExportDatasetDropdown.Items = {''};
            app.ExportDatasetDropdown.ValueChangedFcn = @app.ExportDatasetDropdownChanged;
            app.ExportDatasetDropdown.Layout.Row = 14;
            app.ExportDatasetDropdown.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'Note: Data must be in mm units.';
            lbl.FontColor = [0.7, 0.7, 0.1];
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 15;
            lbl.Layout.Column = [1, 2];

            app.ImportExportButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.ExportButtonPushed);
            app.ImportExportButton.Text = 'Export Data';
            app.ImportExportButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.ImportExportButton.FontColor = [0.996, 0.835, 0.008];
            app.ImportExportButton.FontWeight = 'bold';
            app.ImportExportButton.Layout.Row = 16;
            app.ImportExportButton.Layout.Column = [1, 2];

            app.ExportStatusLabel = uilabel(app.ImportGrid);
            app.ExportStatusLabel.Text = 'Ready';
            app.ExportStatusLabel.FontWeight = 'bold';
            app.ExportStatusLabel.FontColor = [0.5, 0.5, 0.5];
            app.ExportStatusLabel.Layout.Row = 17;
            app.ExportStatusLabel.Layout.Column = [1, 2];

            % ============ Tab 2: Analysis ============
            app.AnalysisTab = uitab(app.TabGroup, 'Title', 'Analysis');
            app.AnalysisGrid = uigridlayout(app.AnalysisTab, [1, 2]);
            app.AnalysisGrid.ColumnWidth = {220, '1x'};
            app.AnalysisGrid.Padding = [5, 5, 5, 5];
            app.AnalysisGrid.ColumnSpacing = 5;

            app.ParamPanel = uigridlayout(app.AnalysisGrid, [15, 2]);
            app.ParamPanel.RowHeight = {'fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit'};
            app.ParamPanel.ColumnWidth = {'fit','1x'};
            app.ParamPanel.Padding = [5, 5, 5, 5];
            app.ParamPanel.RowSpacing = 5;
            app.ParamPanel.ColumnSpacing = 5;
            app.ParamPanel.Layout.Row = 1;
            app.ParamPanel.Layout.Column = 1;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Dataset:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            app.DatasetDropdown = uidropdown(app.ParamPanel);
            app.DatasetDropdown.Items = {''};
            app.DatasetDropdown.ValueChangedFcn = @app.DatasetDropdownChanged;
            app.DatasetDropdown.Layout.Row = 1;
            app.DatasetDropdown.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Nxx:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 2;
            lbl.Layout.Column = 1;

            app.NxxField = uispinner(app.ParamPanel);
            app.NxxField.Step = 1;
            app.NxxField.Limits = [1, Inf];
            app.NxxField.ValueChangedFcn = @app.ParamChanged;
            app.NxxField.Layout.Row = 2;
            app.NxxField.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Nyy:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 3;
            lbl.Layout.Column = 1;

            app.NyyField = uispinner(app.ParamPanel);
            app.NyyField.Step = 1;
            app.NyyField.Limits = [1, Inf];
            app.NyyField.ValueChangedFcn = @app.ParamChanged;
            app.NyyField.Layout.Row = 3;
            app.NyyField.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Np:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 4;
            lbl.Layout.Column = 1;

            app.NpField = uispinner(app.ParamPanel);
            app.NpField.Step = 1;
            app.NpField.Limits = [1, Inf];
            app.NpField.ValueChangedFcn = @app.ParamChanged;
            app.NpField.Layout.Row = 4;
            app.NpField.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Order:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 5;
            lbl.Layout.Column = 1;

            app.OrderField = uispinner(app.ParamPanel);
            app.OrderField.Step = 1;
            app.OrderField.Limits = [1, Inf];
            app.OrderField.Enable = false;
            app.OrderField.ValueChangedFcn = @app.ParamChanged;
            app.OrderField.Layout.Row = 5;
            app.OrderField.Layout.Column = 2;

            app.FIDCheckBox = uicheckbox(app.ParamPanel);
            app.FIDCheckBox.Text = 'FID (Polynomial Fit)';
            app.FIDCheckBox.ValueChangedFcn = @app.FIDChanged;
            app.FIDCheckBox.Layout.Row = 6;
            app.FIDCheckBox.Layout.Column = 1;

            app.SymCheckBox = uicheckbox(app.ParamPanel);
            app.SymCheckBox.Text = 'Sym (Mirror Grid)';
            app.SymCheckBox.ValueChangedFcn = @app.ParamChanged;
            app.SymCheckBox.Layout.Row = 7;
            app.SymCheckBox.Layout.Column = 1;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Deformation units:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 8;
            lbl.Layout.Column = [1, 2];

            app.UnitGrid = uigridlayout(app.ParamPanel, [1, 3]);
            app.UnitGrid.RowHeight = {'fit'};
            app.UnitGrid.ColumnWidth = {'fit', 'fit', 'fit'};
            app.UnitGrid.Padding = [0, 0, 0, 0];
            app.UnitGrid.Layout.Row = 9;
            app.UnitGrid.Layout.Column = [1, 2];

            app.UnitMM = uibutton(app.UnitGrid, 'ButtonPushed', @app.UnitChanged);
            app.UnitMM.Text = 'mm';
            app.UnitMM.BackgroundColor = [0.125, 0.161, 0.275];
            app.UnitMM.FontColor = [0.996, 0.835, 0.008];
            app.UnitMM.FontWeight = 'bold';
            app.UnitMM.Layout.Row = 1;
            app.UnitMM.Layout.Column = 1;

            app.UnitUM = uibutton(app.UnitGrid, 'ButtonPushed', @app.UnitChanged);
            app.UnitUM.Text = [char(181) 'm'];
            app.UnitUM.FontWeight = 'bold';
            app.UnitUM.Layout.Row = 1;
            app.UnitUM.Layout.Column = 2;

            app.UnitNM = uibutton(app.UnitGrid, 'ButtonPushed', @app.UnitChanged);
            app.UnitNM.Text = 'nm';
            app.UnitNM.FontWeight = 'bold';
            app.UnitNM.Layout.Row = 1;
            app.UnitNM.Layout.Column = 3;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Stats [urad]:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 10;
            lbl.Layout.Column = [1, 2];

            lbl = uilabel(app.ParamPanel);
            lbl.Text = '       Sag       Lon';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 11;
            lbl.Layout.Column = [1, 2];

            app.StatsGrid = uigridlayout(app.ParamPanel, [2, 3]);
            app.StatsGrid.RowHeight = {'fit', 'fit'};
            app.StatsGrid.ColumnWidth = {'fit', 'fit', 'fit'};
            app.StatsGrid.Padding = [0, 0, 0, 0];
            app.StatsGrid.RowSpacing = 2;
            app.StatsGrid.ColumnSpacing = 5;
            app.StatsGrid.Layout.Row = [12, 13];
            app.StatsGrid.Layout.Column = [1, 2];

            lbl = uilabel(app.StatsGrid);
            lbl.Text = 'RMS:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            app.StatsLabelSagRMS = uilabel(app.StatsGrid);
            app.StatsLabelSagRMS.Text = '--';
            app.StatsLabelSagRMS.Layout.Row = 1;
            app.StatsLabelSagRMS.Layout.Column = 2;

            app.StatsLabelLonRMS = uilabel(app.StatsGrid);
            app.StatsLabelLonRMS.Text = '--';
            app.StatsLabelLonRMS.Layout.Row = 1;
            app.StatsLabelLonRMS.Layout.Column = 3;

            lbl = uilabel(app.StatsGrid);
            lbl.Text = 'STD:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 2;
            lbl.Layout.Column = 1;

            app.StatsLabelSagSTD = uilabel(app.StatsGrid);
            app.StatsLabelSagSTD.Text = '--';
            app.StatsLabelSagSTD.Layout.Row = 2;
            app.StatsLabelSagSTD.Layout.Column = 2;

            app.StatsLabelLonSTD = uilabel(app.StatsGrid);
            app.StatsLabelLonSTD.Text = '--';
            app.StatsLabelLonSTD.Layout.Row = 2;
            app.StatsLabelLonSTD.Layout.Column = 3;

            app.RunButton = uibutton(app.ParamPanel, 'ButtonPushed', @app.RunButtonPushed);
            app.RunButton.Text = 'Run Analysis';
            app.RunButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.RunButton.FontColor = [0.996, 0.835, 0.008];
            app.RunButton.FontWeight = 'bold';
            app.RunButton.Layout.Row = 14;
            app.RunButton.Layout.Column = 1;

            app.ExportDataButton = uibutton(app.ParamPanel, 'ButtonPushed', @app.ExportButtonPushed);
            app.ExportDataButton.Text = 'Export Data';
            app.ExportDataButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.ExportDataButton.FontColor = [0.996, 0.835, 0.008];
            app.ExportDataButton.FontWeight = 'bold';
            app.ExportDataButton.Layout.Row = 14;
            app.ExportDataButton.Layout.Column = 2;

            app.AnalysisStatusLabel = uilabel(app.ParamPanel);
            app.AnalysisStatusLabel.Text = 'Ready';
            app.AnalysisStatusLabel.FontWeight = 'bold';
            app.AnalysisStatusLabel.FontColor = [0.5, 0.5, 0.5];
            app.AnalysisStatusLabel.Layout.Row = 15;
            app.AnalysisStatusLabel.Layout.Column = [1, 2];

            % Plot stack
            app.plotStack = uigridlayout(app.AnalysisGrid, [2, 1]);
            app.plotStack.RowHeight = {'1x','1x'};
            app.plotStack.Padding = [10, 10, 30, 10];
            app.plotStack.RowSpacing = 3;
            app.plotStack.Layout.Row = 1;
            app.plotStack.Layout.Column = 2;

            app.TopPlotGroup = uigridlayout(app.plotStack, [2, 1]);
            app.TopPlotGroup.RowHeight = {'1x','1x'};
            app.TopPlotGroup.ColumnWidth = {'1x'};
            app.TopPlotGroup.Padding = [2, 2, 40, 2];
            app.TopPlotGroup.RowSpacing = 2;
            app.TopPlotGroup.ColumnSpacing = 2;
            app.TopPlotGroup.Layout.Row = 1;
            app.TopPlotGroup.Layout.Column = 1;

            app.ContourPlotSag = uiaxes(app.TopPlotGroup);
            app.ContourPlotSag.Title.String = 'Sagittal Slope [urad]';
            app.ContourPlotSag.Layout.Row = 1;
            app.ContourPlotSag.Layout.Column = 1;

            app.ContourPlotLon = uiaxes(app.TopPlotGroup);
            app.ContourPlotLon.Title.String = 'Longitudinal Slope [urad]';
            app.ContourPlotLon.Layout.Row = 2;
            app.ContourPlotLon.Layout.Column = 1;

            app.BottomPlotGroup = uigridlayout(app.plotStack, [2, 2]);
            app.BottomPlotGroup.RowHeight = {'1x','1x'};
            app.BottomPlotGroup.ColumnWidth = {'1x','1x'};
            app.BottomPlotGroup.Padding = [2, 2, 2, 2];
            app.BottomPlotGroup.RowSpacing = 2;
            app.BottomPlotGroup.ColumnSpacing = 2;
            app.BottomPlotGroup.Layout.Row = 2;
            app.BottomPlotGroup.Layout.Column = 1;

            app.LinePlotAx1 = axes(app.BottomPlotGroup);
            app.LinePlotAx1.Layout.Row = 1;
            app.LinePlotAx1.Layout.Column = 1;

            app.LinePlotAx2 = axes(app.BottomPlotGroup);
            app.LinePlotAx2.Layout.Row = 1;
            app.LinePlotAx2.Layout.Column = 2;

            app.LinePlotAx3 = axes(app.BottomPlotGroup);
            app.LinePlotAx3.Layout.Row = 2;
            app.LinePlotAx3.Layout.Column = 1;

            app.LinePlotAx4 = axes(app.BottomPlotGroup);
            app.LinePlotAx4.Layout.Row = 2;
            app.LinePlotAx4.Layout.Column = 2;

% ============ Tab 3: Comparison (1D only) ============
            app.ComparisonTab = uitab(app.TabGroup, 'Title', 'Comparison');
            app.ComparisonGrid = uigridlayout(app.ComparisonTab, [1, 2]);
            app.ComparisonGrid.RowHeight = {'1x'};
            app.ComparisonGrid.ColumnWidth = {220, '1x'};
            app.ComparisonGrid.Padding = [5, 5, 5, 5];
            app.ComparisonGrid.ColumnSpacing = 5;

            % Left column nested grid (controls + tree)
            app.CompLeftGrid = uigridlayout(app.ComparisonGrid, [6, 1]);
            app.CompLeftGrid.RowHeight = {'fit', 'fit', 'fit', 'fit', 200, '1x'};
            app.CompLeftGrid.Padding = [0, 0, 0, 0];
            app.CompLeftGrid.RowSpacing = 3;
            app.CompLeftGrid.Layout.Row = 1;
            app.CompLeftGrid.Layout.Column = 1;

            % Top row: Compare button
            app.CompareButton = uibutton(app.CompLeftGrid, 'ButtonPushed', @app.CompareButtonPushed);
            app.CompareButton.Text = 'Compare';
            app.CompareButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.CompareButton.FontColor = [0.996, 0.835, 0.008];
            app.CompareButton.FontWeight = 'bold';
            app.CompareButton.Layout.Row = 1;
            app.CompareButton.Layout.Column = 1;

            % Deformation units label
            lbl = uilabel(app.CompLeftGrid);
            lbl.Text = 'Deformation units:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 2;
            lbl.Layout.Column = 1;

            % Unit buttons in a 1x3 grid
            app.CompUnitGrid = uigridlayout(app.CompLeftGrid, [1, 3]);
            app.CompUnitGrid.RowHeight = {'fit'};
            app.CompUnitGrid.ColumnWidth = {'fit', 'fit', 'fit'};
            app.CompUnitGrid.Padding = [0, 0, 0, 0];
            app.CompUnitGrid.Layout.Row = 3;
            app.CompUnitGrid.Layout.Column = 1;

            app.CompUnitMM = uibutton(app.CompUnitGrid, 'ButtonPushed', @app.CompUnitChanged);
            app.CompUnitMM.Text = 'mm';
            app.CompUnitMM.BackgroundColor = [0.125, 0.161, 0.275];
            app.CompUnitMM.FontColor = [0.996, 0.835, 0.008];
            app.CompUnitMM.FontWeight = 'bold';
            app.CompUnitMM.Layout.Row = 1;
            app.CompUnitMM.Layout.Column = 1;

            app.CompUnitUM = uibutton(app.CompUnitGrid, 'ButtonPushed', @app.CompUnitChanged);
            app.CompUnitUM.Text = [char(181) 'm'];
            app.CompUnitUM.FontWeight = 'bold';
            app.CompUnitUM.Layout.Row = 1;
            app.CompUnitUM.Layout.Column = 2;

            app.CompUnitNM = uibutton(app.CompUnitGrid, 'ButtonPushed', @app.CompUnitChanged);
            app.CompUnitNM.Text = 'nm';
            app.CompUnitNM.FontWeight = 'bold';
            app.CompUnitNM.Layout.Row = 1;
            app.CompUnitNM.Layout.Column = 3;

            % Note label
            lbl = uilabel(app.CompLeftGrid);
            lbl.Text = 'Note: Only 1D datasets shown.';
            lbl.FontWeight = 'bold';
            lbl.FontColor = [0.7, 0.7, 0.1];
            lbl.Layout.Row = 4;
            lbl.Layout.Column = 1;

            % Checkbox tree (200px fixed height) with categories
            app.CompTree = uitree(app.CompLeftGrid, 'checkbox');
            app.CompTree.Layout.Row = 5;
            app.CompTree.Layout.Column = 1;

            % Comparison plots in a 2x1 sub-grid in column 2
            app.CompPlotGrid = uigridlayout(app.ComparisonGrid, [2, 1]);
            app.CompPlotGrid.RowHeight = {'1x','1x'};
            app.CompPlotGrid.ColumnWidth = {'1x'};
            app.CompPlotGrid.Padding = [2, 2, 2, 2];
            app.CompPlotGrid.RowSpacing = 3;
            app.CompPlotGrid.Layout.Row = 1;
            app.CompPlotGrid.Layout.Column = 2;

            app.CompDeformationAx = uiaxes(app.CompPlotGrid);
            app.CompDeformationAx.Title.String = 'Deformation Comparison';
            app.CompDeformationAx.Layout.Row = 1;
            app.CompDeformationAx.Layout.Column = 1;

            app.CompSlopeAx = uiaxes(app.CompPlotGrid);
            app.CompSlopeAx.Title.String = 'Slope Comparison [urad]';
            app.CompSlopeAx.Layout.Row = 2;
            app.CompSlopeAx.Layout.Column = 1;
        end
    end

    methods (Access = private)
        function startup(app)
            app.NxxField.Value = app.DefaultNxx;
            app.NyyField.Value = app.DefaultNyy;
            app.NpField.Value = app.DefaultNp;
            app.OrderField.Value = app.DefaultOrder;
            app.OrderField.Enable = false;
            app.FIDCheckBox.Value = app.DefaultFID;
            app.SymCheckBox.Value = app.DefaultSym;
            app.DataTypeDropdown.Value = '2D';
            app.DirectionDropdown.Value = 'Sagittal';
            app.DirectionDropdown.Enable = false;
            app.DatasetDropdown.Items = {''};
            app.DatasetListBox.Items = {''};
            app.ExportDatasetDropdown.Items = {''};
            if ~isempty(app.CompTree.Children)
                delete(app.CompTree.Children);
            end
            app.ExportStatusLabel.Text = 'Ready';
            app.AnalysisStatusLabel.Text = 'Ready';
            app.CurrentUnit = 'mm';
            app.setActiveUnitButton(app.UnitMM, false);
            app.setActiveUnitButton(app.CompUnitMM, true);
        end

        function unitScale = getUnitScale(app)
            if app.CurrentUnit == "mm"
                unitScale = 1;
            elseif app.CurrentUnit == [char(181) 'm']
                unitScale = 1000;
            else
                unitScale = 1e6;
            end
        end

        function unitLabel = getUnitLabel(app)
            if app.CurrentUnit == "mm"
                unitLabel = 'mm';
            elseif app.CurrentUnit == [char(181) 'm']
                unitLabel = [char(181) 'm'];
            else
                unitLabel = 'nm';
            end
        end

        function refreshDatasetDropdowns(app)
            names = {};
            for i = 1:length(app.Datasets)
                names{end+1} = app.Datasets{i}.name;
            end
            if isempty(names)
                names = {''};
            end
            app.DatasetDropdown.Items = names;
            app.DatasetListBox.Items = names;
            app.ExportDatasetDropdown.Items = names;
            delete(app.CompTree.Children);
            parentSag = []; parentLon = [];
            for i = 1:length(app.Datasets)
                if app.Datasets{i}.is2D
                    continue
                end
                if strcmp(app.Datasets{i}.direction, 'Longitudinal')
                    if isempty(parentLon)
                        parentLon = uitreenode(app.CompTree, 'Text', 'Longitudinal', 'NodeData', 0);
                    end
                    uitreenode(parentLon, 'Text', app.Datasets{i}.name, 'NodeData', i);
                else
                    if isempty(parentSag)
                        parentSag = uitreenode(app.CompTree, 'Text', 'Sagittal', 'NodeData', 0);
                    end
                    uitreenode(parentSag, 'Text', app.Datasets{i}.name, 'NodeData', i);
                end
            end
            if app.SelectedIndex > 0 && app.SelectedIndex <= length(app.Datasets)
                app.DatasetDropdown.Value = app.Datasets{app.SelectedIndex}.name;
                app.DatasetListBox.Value = app.Datasets{app.SelectedIndex}.name;
            end
        end

        function updateStats(app, ds, S_sag, S_lon)
            if ds.is2D
                rms_sag = sqrt(mean(S_sag(:).^2));
                std_sag = std(S_sag(:));
                rms_lon = sqrt(mean(S_lon(:).^2));
                std_lon = std(S_lon(:));
                app.StatsLabelSagRMS.Text = sprintf('%.3f', rms_sag);
                app.StatsLabelSagSTD.Text = sprintf('%.3f', std_sag);
                app.StatsLabelLonRMS.Text = sprintf('%.3f', rms_lon);
                app.StatsLabelLonSTD.Text = sprintf('%.3f', std_lon);
            elseif strcmp(ds.direction, 'Sagittal')
                rms_sag = sqrt(mean(S_sag(:).^2));
                std_sag = std(S_sag(:));
                app.StatsLabelSagRMS.Text = sprintf('%.3f', rms_sag);
                app.StatsLabelSagSTD.Text = sprintf('%.3f', std_sag);
                app.StatsLabelLonRMS.Text = 'N/A';
                app.StatsLabelLonSTD.Text = 'N/A';
            else
                rms_lon = sqrt(mean(S_lon(:).^2));
                std_lon = std(S_lon(:));
                app.StatsLabelSagRMS.Text = 'N/A';
                app.StatsLabelSagSTD.Text = 'N/A';
                app.StatsLabelLonRMS.Text = sprintf('%.3f', rms_lon);
                app.StatsLabelLonSTD.Text = sprintf('%.3f', std_lon);
            end
        end

        function updateAnalysis(app)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                return
            end

            ds = app.Datasets{app.SelectedIndex};
            try
                data0 = ds.data0;
                if ~ds.is2D && strcmp(ds.direction, 'Longitudinal')
                    data0 = data0(:, [1, 3, 2, 4, 5, 6, 7]);
                end

                [X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w] = ...
                    sloper(data0, app.NxxField.Value, app.NyyField.Value, ...
                    app.FIDCheckBox.Value, int16(app.OrderField.Value), ...
                    app.SymCheckBox.Value, ds.is2D);

                ds.sloperOutputs = {X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w};
                app.Datasets{app.SelectedIndex} = ds;

                app.updatePlots(ds, X, Y, W, S_sag, S_lon);
                app.updateStats(ds, S_sag, S_lon);
                app.AnalysisStatusLabel.Text = 'Analysis updated successfully';
                app.AnalysisStatusLabel.FontColor = [0, 0.5, 0];
            catch ME
                app.AnalysisStatusLabel.Text = ['Analysis error: ' ME.message];
                app.AnalysisStatusLabel.FontColor = [0.8, 0, 0];
            end
        end

        function updatePlots(app, ds, X, Y, W, S_sag, S_lon)
            if ds.is2D
                app.plotContour2D(X, Y, S_sag, S_lon);
                app.plotLines2D(X, Y, W, S_sag, S_lon);

                app.ContourPlotSag.Layout.Row = 1;
                app.ContourPlotSag.Layout.Column = 1;
                app.ContourPlotLon.Layout.Row = 2;
                app.ContourPlotLon.Layout.Column = 1;
                app.ContourPlotLon.Visible = 'on';

                app.LinePlotAx1.Layout.Row = 1;
                app.LinePlotAx1.Layout.Column = 1;
                app.LinePlotAx2.Layout.Row = 1;
                app.LinePlotAx2.Layout.Column = 2;
                app.LinePlotAx3.Layout.Row = 2;
                app.LinePlotAx3.Layout.Column = 1;
                app.LinePlotAx4.Layout.Row = 2;
                app.LinePlotAx4.Layout.Column = 2;
                app.LinePlotAx2.Visible = 'on';
                app.LinePlotAx3.Visible = 'on';
                app.LinePlotAx4.Visible = 'on';
            else
                app.plot1D(ds, X, Y, W, S_sag, S_lon);

                colorbar(app.ContourPlotLon, 'off');
                cla(app.ContourPlotLon);
                app.ContourPlotLon.Visible = 'off';
                app.ContourPlotSag.Layout.Row = [1, 2];
                app.ContourPlotSag.Layout.Column = 1;

                cla(app.LinePlotAx2);
                app.LinePlotAx2.Visible = 'off';
                cla(app.LinePlotAx3);
                app.LinePlotAx3.Visible = 'off';
                cla(app.LinePlotAx4);
                app.LinePlotAx4.Visible = 'off';
                app.LinePlotAx1.Layout.Row = [1, 2];
                app.LinePlotAx1.Layout.Column = [1, 2];
            end
        end

        function plotContour2D(app, X, Y, S_sag, S_lon)
            cla(app.ContourPlotSag);
            cla(app.ContourPlotLon);

            contourf(app.ContourPlotSag, X, Y, S_sag);
            app.ContourPlotSag.FontSize = 11;
            xlabel(app.ContourPlotSag, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.ContourPlotSag, 'Lon. (y) [mm]', 'FontSize', 11);
            colormap(app.ContourPlotSag, 'bone');
            cb1 = colorbar(app.ContourPlotSag);
            ylabel(cb1, 'Slope [urad]', 'FontSize', 11, 'Rotation', 270);

            contourf(app.ContourPlotLon, X, Y, S_lon);
            app.ContourPlotLon.FontSize = 11;
            xlabel(app.ContourPlotLon, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.ContourPlotLon, 'Lon. (y) [mm]', 'FontSize', 11);
            colormap(app.ContourPlotLon, 'bone');
            cb2 = colorbar(app.ContourPlotLon);
            ylabel(cb2, 'Slope [urad]', 'FontSize', 11, 'Rotation', 270);
        end

        function plotLines2D(app, X, Y, W, S_sag, S_lon)
            Np = app.NpField.Value;
            if Np < 1
                Np = 1;
            end
            Np = min(Np, min(size(S_lon, 1), size(S_sag, 2)));
            s = app.getUnitScale();
            ul = app.getUnitLabel();

            cla(app.LinePlotAx1);
            cla(app.LinePlotAx2);
            cla(app.LinePlotAx3);
            cla(app.LinePlotAx4);

            for i = 1:Np
                idx = i * floor(size(S_lon, 1) / Np);
                idy = i * floor(size(S_sag, 2) / Np);

                plot(app.LinePlotAx1, X(:, idy), W(:, idy) * s);
                hold(app.LinePlotAx1, 'on');

                plot(app.LinePlotAx2, Y(idx, :), W(idx, :) * s);
                hold(app.LinePlotAx2, 'on');

                plot(app.LinePlotAx3, X(:, idy), S_sag(:, idy));
                hold(app.LinePlotAx3, 'on');

                plot(app.LinePlotAx4, Y(idx, :), S_lon(idx, :));
                hold(app.LinePlotAx4, 'on');
            end

            xlabel(app.LinePlotAx1, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx1, ['Normal Disp. [' ul ']'], 'FontSize', 11);
            grid(app.LinePlotAx1, 'on');

            xlabel(app.LinePlotAx2, 'Lon. (y) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx2, ['Normal Disp. [' ul ']'], 'FontSize', 11);
            grid(app.LinePlotAx2, 'on');

            xlabel(app.LinePlotAx3, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx3, 'Sag. (x) Slope [urad]', 'FontSize', 11);
            grid(app.LinePlotAx3, 'on');

            xlabel(app.LinePlotAx4, 'Lon. (y) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx4, 'Tan. (y) Slope [urad]', 'FontSize', 11);
            grid(app.LinePlotAx4, 'on');
        end

        function plot1D(app, ds, X, Y, W, S_sag, S_lon)
            cla(app.ContourPlotSag);
            cla(app.LinePlotAx1);
            colorbar(app.ContourPlotSag, 'off');
            colorbar(app.LinePlotAx1, 'off');

            s = app.getUnitScale();
            ul = app.getUnitLabel();

            if strcmp(ds.direction, 'Sagittal')
                posLabel = 'Sag. (x) [mm]';
                deformTitle = 'Sagittal Deformation';
                slopeTitle = 'Sagittal Slope [urad]';
            else
                posLabel = 'Lon. (y) [mm]';
                deformTitle = 'Longitudinal Deformation';
                slopeTitle = 'Longitudinal Slope [urad]';
            end

            pos = X(:,1);

            plot(app.ContourPlotSag, pos, W(:,1) * s, 'k-', 'LineWidth', 1.5);
            xlabel(app.ContourPlotSag, posLabel, 'FontSize', 11);
            ylabel(app.ContourPlotSag, ['Normal Disp. [' ul ']'], 'FontSize', 11);
            title(app.ContourPlotSag, deformTitle, 'FontSize', 11);
            grid(app.ContourPlotSag, 'on');

            plot(app.LinePlotAx1, pos, S_sag(:,1), 'k-', 'LineWidth', 1.5);
            xlabel(app.LinePlotAx1, posLabel, 'FontSize', 11);
            ylabel(app.LinePlotAx1, 'Slope [urad]', 'FontSize', 11);
            title(app.LinePlotAx1, slopeTitle, 'FontSize', 11);
            grid(app.LinePlotAx1, 'on');
        end

        function exportAxesGrid(app, axesList, nRows, nCols, fn)
            f = figure('Visible', 'off', 'Color', 'w');
            for i = 1:numel(axesList)
                src = axesList{i};
                ax = subplot(nRows, nCols, i);
                copyobj(allchild(src), ax);
                ax.FontSize = src.FontSize;
                ax.XLabel.String = src.XLabel.String;
                ax.YLabel.String = src.YLabel.String;
                ax.Title.String = src.Title.String;
                ax.XLim = src.XLim;
                ax.YLim = src.YLim;
                ax.XGrid = src.XGrid;
                ax.YGrid = src.YGrid;
                ax.Box = src.Box;
                cmap = src.Colormap;
                if ~isempty(cmap)
                    colormap(ax, cmap);
                end
                cb_src = [];
                if isprop(src, 'Colorbars') && ~isempty(src.Colorbars)
                    cb_src = src.Colorbars(1);
                end
                if ~isempty(cb_src)
                    cb = colorbar(ax);
                    cb.Label.String = cb_src.Label.String;
                    cb.Label.FontSize = cb_src.Label.FontSize;
                    cb.Label.Rotation = cb_src.Label.Rotation;
                end
            end
            exportgraphics(f, fn, 'Resolution', 150);
            delete(f);
        end

        function setActiveUnitButton(app, activeBtn, isComp)
            if isComp
                others = {app.CompUnitMM, app.CompUnitUM, app.CompUnitNM};
            else
                others = {app.UnitMM, app.UnitUM, app.UnitNM};
            end
            for i = 1:length(others)
                btn = others{i};
                if btn == activeBtn
                    btn.BackgroundColor = [0.125, 0.161, 0.275];
                    btn.FontColor = [0.996, 0.835, 0.008];
                else
                    btn.BackgroundColor = [0.8, 0.8, 0.8];
                    btn.FontColor = [0, 0, 0];
                end
            end
        end

        function UnitChanged(app, src, event)
            app.CurrentUnit = src.Text;
            app.setActiveUnitButton(src, false);
            if app.SelectedIndex > 0 && app.SelectedIndex <= length(app.Datasets)
                ds = app.Datasets{app.SelectedIndex};
                outputs = ds.sloperOutputs;
                if ~isempty(outputs) && numel(outputs) >= 12
                    app.updatePlots(ds, outputs{1}, outputs{2}, outputs{5}, outputs{6}, outputs{7});
                end
            end
        end

        function CompUnitChanged(app, src, event)
            app.CurrentUnit = src.Text;
            app.setActiveUnitButton(src, true);
            idxList = app.getCheckedDatasetIndices();
            if numel(idxList) >= 2
                app.doComparison(idxList);
            end
        end

        function idxList = getCheckedDatasetIndices(app)
            checked = app.CompTree.CheckedNodes;
            idxList = [];
            for k = 1:length(checked)
                di = checked(k).NodeData;
                if isempty(di) || ~isnumeric(di) || di < 1
                    continue
                end
                idxList(end+1) = di;
            end
            idxList = unique(idxList);
        end

        function CompareButtonPushed(app, src, event)
            idxList = app.getCheckedDatasetIndices();
            if numel(idxList) < 2
                app.CompDeformationAx.Title.String = 'Check 2+ datasets, then press Compare';
                cla(app.CompDeformationAx);
                cla(app.CompSlopeAx);
                return
            end
            if numel(idxList) > 7
                app.CompDeformationAx.Title.String = 'Maximum 7 datasets can be compared';
                cla(app.CompDeformationAx);
                cla(app.CompSlopeAx);
                return
            end

            dirs = {};
            for k = 1:numel(idxList)
                ds = app.Datasets{idxList(k)};
                if ds.is2D
                    app.AnalysisStatusLabel.Text = 'Comparison only supports 1D datasets';
                    app.AnalysisStatusLabel.FontColor = [0.8, 0, 0];
                    cla(app.CompDeformationAx);
                    cla(app.CompSlopeAx);
                    return
                end
                dirs{end+1} = ds.direction;
                app.runAnalysisByIndex(idxList(k));
            end

            refDir = dirs{1};
            for i = 2:length(dirs)
                if ~strcmp(dirs{i}, refDir)
                    app.AnalysisStatusLabel.Text = 'Compare sagittal-to-sagittal or longitudinal-to-longitudinal only';
                    app.AnalysisStatusLabel.FontColor = [0.8, 0, 0];
                    cla(app.CompDeformationAx);
                    cla(app.CompSlopeAx);
                    return
                end
            end

            app.AnalysisStatusLabel.Text = '';
            app.doComparison(idxList);
        end

        function doComparison(app, idxList)
            cla(app.CompDeformationAx);
            cla(app.CompSlopeAx);
            s = app.getUnitScale();
            ul = app.getUnitLabel();
            matColors = [0, 0.4470, 0.7410; 0.8500, 0.3250, 0.0980; ...
                         0.9290, 0.6940, 0.1250; 0.4940, 0.1840, 0.5560; ...
                         0.4660, 0.6740, 0.1880; 0.3010, 0.7450, 0.9330; ...
                         0.6350, 0.0780, 0.1840];
            hold(app.CompDeformationAx, 'on');
            hold(app.CompSlopeAx, 'on');

            n = min(numel(idxList), 7);
            for j = 1:n
                ds = app.Datasets{idxList(j)};
                outputs = ds.sloperOutputs;
                if isempty(outputs) || numel(outputs) < 12
                    continue
                end
                Xo = outputs{1}; Wo = outputs{5}; S_sag_o = outputs{7};
                c = matColors(j, :);

                if strcmp(ds.direction, 'Sagittal') || ds.is2D
                    plot(app.CompDeformationAx, Xo(:,1), Wo(:,1) * s, 'Color', c, 'LineWidth', 1.5, 'DisplayName', ds.name);
                    plot(app.CompSlopeAx, Xo(:,1), S_sag_o(:,1), 'Color', c, 'LineWidth', 1.5, 'DisplayName', ds.name);
                else
                    plot(app.CompDeformationAx, Xo(:,1), Wo(:,1) * s, 'Color', c, 'LineWidth', 1.5, 'DisplayName', ds.name);
                    plot(app.CompSlopeAx, Xo(:,1), S_sag_o(:,1), 'Color', c, 'LineWidth', 1.5, 'DisplayName', ds.name);
                end
            end

            xlabel(app.CompDeformationAx, 'Position [mm]', 'FontSize', 11);
            ylabel(app.CompDeformationAx, ['Normal Disp. [' ul ']'], 'FontSize', 11);
            legend(app.CompDeformationAx, 'Location', 'best');
            grid(app.CompDeformationAx, 'on');

            xlabel(app.CompSlopeAx, 'Position [mm]', 'FontSize', 11);
            ylabel(app.CompSlopeAx, 'Slope [urad]', 'FontSize', 11);
            legend(app.CompSlopeAx, 'Location', 'best');
            grid(app.CompSlopeAx, 'on');
        end

        function runAnalysisByIndex(app, idx)
            ds = app.Datasets{idx};
            if ~isempty(ds.sloperOutputs) && numel(ds.sloperOutputs) >= 12
                return
            end
            try
                data0 = ds.data0;
                if ~ds.is2D && strcmp(ds.direction, 'Longitudinal')
                    data0 = data0(:, [1, 3, 2, 4, 5, 6, 7]);
                end
                [X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w] = ...
                    sloper(data0, app.NxxField.Value, app.NyyField.Value, ...
                    app.FIDCheckBox.Value, int16(app.OrderField.Value), ...
                    app.SymCheckBox.Value, ds.is2D);
                ds.sloperOutputs = {X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w};
                app.Datasets{idx} = ds;
            catch
            end
        end
    end

    methods (Access = private)

        function FileButtonPushed(app, src, event)
            [f, p] = uigetfile('*.txt', 'Select ANSYS Data File');
            if isequal(f, 0)
                return
            end
            app.FilePathField.Value = fullfile(p, f);
        end

        function DataTypeDropdownChanged(app, src, event)
            is1D = strcmp(app.DataTypeDropdown.Value, '1D');
            app.DirectionDropdown.Enable = is1D;
        end

        function ExportDatasetDropdownChanged(app, src, event)
            if isempty(app.ExportDatasetDropdown.Value) || strcmp(app.ExportDatasetDropdown.Value, '')
                return
            end
        end

        function AddDatasetButtonPushed(app, src, event)
            name = app.DatasetNameField.Value;
            fpath = app.FilePathField.Value;

            if isempty(name)
                app.ExportStatusLabel.Text = 'Please enter a dataset name';
                return
            end
            if isempty(fpath)
                app.ExportStatusLabel.Text = 'Please select a file';
                return
            end
            if ~isfile(fpath)
                app.ExportStatusLabel.Text = 'File does not exist';
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, name)
                    app.ExportStatusLabel.Text = 'Dataset name already exists';
                    return
                end
            end

            try
                data0 = readmatrix(fpath, 'FileType', 'text', 'Delimiter', '\t', 'NumHeaderLines', 1);
                data0 = unique(data0, 'rows');

                is2D = strcmp(app.DataTypeDropdown.Value, '2D');
                direction = app.DirectionDropdown.Value;

                ds = struct('name', name, 'filepath', fpath, 'data0', data0, ...
                    'is2D', is2D, 'direction', direction, 'sloperOutputs', {{}});
                app.Datasets{end+1} = ds;
                app.SelectedIndex = length(app.Datasets);
                app.refreshDatasetDropdowns();

                app.DatasetNameField.Value = '';
                app.FilePathField.Value = '';
                app.ExportStatusLabel.Text = ['Dataset "' name '" added successfully'];
            catch ME
                app.ExportStatusLabel.Text = ['Import error: ' ME.message];
            end
        end

        function RemoveDatasetButtonPushed(app, src, event)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                app.ExportStatusLabel.Text = 'No dataset selected';
                return
            end

            removedName = app.Datasets{app.SelectedIndex}.name;
            app.Datasets(app.SelectedIndex) = [];
            if app.SelectedIndex > length(app.Datasets)
                app.SelectedIndex = length(app.Datasets);
            end
            if isempty(app.Datasets)
                app.SelectedIndex = 0;
                cla(app.ContourPlotSag);
                cla(app.ContourPlotLon);
                cla(app.LinePlotAx1);
                cla(app.LinePlotAx2);
                cla(app.LinePlotAx3);
                cla(app.LinePlotAx4);
            end
            app.refreshDatasetDropdowns();
            app.ExportStatusLabel.Text = ['Removed "' removedName '"'];
        end

        function DatasetListBoxChanged(app, src, event)
            val = app.DatasetListBox.Value;
            if isempty(val)
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, val)
                    app.SelectedIndex = i;
                    app.refreshDatasetDropdowns();
                    app.updateAnalysis();
                    break
                end
            end
        end

        function DatasetDropdownChanged(app, src, event)
            val = app.DatasetDropdown.Value;
            if isempty(val)
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, val)
                    app.SelectedIndex = i;
                    ds = app.Datasets{app.SelectedIndex};
                    app.SymCheckBox.Enable = ds.is2D;
                    app.updateAnalysis();
                    break
                end
            end
        end

        function ParamChanged(app, src, event)
            app.updateAnalysis();
        end

        function FIDChanged(app, src, event)
            app.OrderField.Enable = app.FIDCheckBox.Value;
            app.updateAnalysis();
        end

        function RunButtonPushed(app, src, event)
            app.updateAnalysis();
        end

        function BrowseExportDirButtonPushed(app, src, event)
            d = uigetdir('', 'Select Export Directory');
            if isequal(d, 0)
                return
            end
            app.ExportDir = string(d);
            app.ExportDirField.Value = app.ExportDir;
        end

        function ExportButtonPushed(app, src, event)
            exportName = app.ExportDatasetDropdown.Value;
            if isempty(exportName) || strcmp(exportName, '')
                app.ExportStatusLabel.Text = 'No dataset selected for export';
                return
            end
            exportIdx = 0;
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, exportName)
                    exportIdx = i;
                    break
                end
            end
            if exportIdx == 0
                app.ExportStatusLabel.Text = 'No dataset selected for export';
                return
            end
            expdir = app.ExportDirField.Value;
            if isempty(expdir)
                app.ExportStatusLabel.Text = 'Please select export directory';
                return
            end

            dver = app.DverField.Value;
            blname = app.BlnameField.Value;
            optname = app.OptnameField.Value;
            scename = app.ScenameField.Value;

            if isempty(dver) || isempty(blname) || isempty(optname) || isempty(scename)
                app.ExportStatusLabel.Text = 'Please fill in all export fields';
                return
            end

            ds = app.Datasets{exportIdx};
            outputs = ds.sloperOutputs;
            if isempty(outputs) || numel(outputs) < 12
                app.ExportStatusLabel.Text = 'Run analysis before exporting';
                return
            end
            X  = outputs{1};   Y  = outputs{2};   U = outputs{3}; V = outputs{4};
            W  = outputs{5};   S_lon = outputs{6}; S_sag = outputs{7};
            x  = outputs{8};   y  = outputs{9};   u = outputs{10}; v = outputs{11}; w = outputs{12};

            dateStr = string(datetime('now', 'TimeZone', 'local', 'Format', 'dMMMyy'));
            if ds.is2D
                dimLabel = '2D';
            elseif strcmp(ds.direction, 'Sagittal')
                dimLabel = '1D-sag';
            else
                dimLabel = '1D-lon';
            end
            expname = strjoin(["FEA", dver, blname, optname, scename, dimLabel, dateStr], '-');

            prefix = strjoin(["FEA", dver, blname, optname, scename], '-');
            oldFiles = dir(fullfile(expdir, prefix + '-*'));
            for k = 1:length(oldFiles)
                if ~oldFiles(k).isdir
                    delete(fullfile(oldFiles(k).folder, oldFiles(k).name));
                end
            end

            try
                sloper_export(expdir, expname, x, y, X, Y, u, v, w, U, V, W);

                drawnow;
                pause(0.05);
                fn = fullfile(expdir, expname);
                if ds.is2D
                    exportgraphics(app.ContourPlotSag, fn + '-SagittalSlope.png', 'Resolution', 150);
                    exportgraphics(app.ContourPlotLon, fn + '-LongitudinalSlope.png', 'Resolution', 150);
                    app.exportAxesGrid({app.LinePlotAx1, app.LinePlotAx2, app.LinePlotAx3, app.LinePlotAx4}, 2, 2, fn + '-LinePlots.png');
                else
                    exportgraphics(app.ContourPlotSag, fn + '-Deformation.png', 'Resolution', 150);
                    exportgraphics(app.LinePlotAx1, fn + '-Slope.png', 'Resolution', 150);
                end

                app.AnalysisStatusLabel.Text = ['Exported: ' expname];
                app.AnalysisStatusLabel.FontColor = [0, 0.5, 0];
            catch ME
                app.AnalysisStatusLabel.Text = ['Export error: ' ME.message];
                app.AnalysisStatusLabel.FontColor = [0.8, 0, 0];
            end
        end
    end

end