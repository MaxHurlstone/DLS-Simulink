classdef sloperapp_test < matlab.uitest.TestCase
    % Programmatic UI validation of the SloperApp 2D-only refactor.
    % Uses real ANSYS example data: <repo>/dev/k18-lwr-final.txt

    methods (Test)
        function testFullWorkflow(testCase)
            repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            appDir = fullfile(repoRoot, 'toolbox', 'dlsimulink', 'apps', 'SPP');
            addpath(appDir);
            addpath(fullfile(appDir, 'utils'));

            dataFile = fullfile(repoRoot, 'dev', 'k18-lwr-final.txt');
            testCase.verifyTrue(isfile(dataFile), 'FAIL: example data file missing');

            app = SloperApp;
            app.UIFigure.Position = [100, 100, 900, 1300];
            testCase.addTeardown(@() delete(app.UIFigure));

            tmpdir = fullfile(tempdir, 'sloperapp_test');
            if ~exist(tmpdir, 'dir'); mkdir(tmpdir); end
            testCase.addTeardown(@() rmdir(tmpdir, 's'));

            % --- Real-data files: as-is + scaled-w variant ---
            fileA = fullfile(tmpdir, 'k18A.txt');
            fileB = fullfile(tmpdir, 'k18B.txt');
            copyfile(dataFile, fileA);
            M = readmatrix(fileA, 'FileType', 'text', 'Delimiter', '\t', 'NumHeaderLines', 1);
            M = unique(M, 'rows');
            Mb = M; Mb(:, 7) = 1.5 * M(:, 7);
            writeDataFile(fileB, Mb);

            % --- Add dataset ds1 (Import tab is initially selected) ---
            app.DatasetNameField.Value = 'ds1';
            app.FilePathField.Value = fileA;
            testCase.press(app.AddDatasetButton);
            testCase.verifyEqual(numel(app.CompTree.Children), 2, 'FAIL: expected 2 parent nodes');
            pTexts = {app.CompTree.Children(1).Text, app.CompTree.Children(2).Text};
            testCase.verifyTrue(any(contains(pTexts, 'Sagittal centreline')) && any(contains(pTexts, 'Longitudinal centreline')), ...
                'FAIL: parent node labels wrong');
            testCase.verifyEqual(numel(app.CompTree.Children(1).Children), 1, 'FAIL: expected 1 sag child');
            testCase.verifyEqual(numel(app.CompTree.Children(2).Children), 1, 'FAIL: expected 1 lon child');
            testCase.verifyTrue(contains(app.ExportStatusLabel.Text, 'added successfully'), ...
                ['FAIL: add status msg [' app.ExportStatusLabel.Text ']']);

            % --- Add dataset ds2 ---
            app.DatasetNameField.Value = 'ds2';
            app.FilePathField.Value = fileB;
            testCase.press(app.AddDatasetButton);
            testCase.verifyEqual(numel(app.CompTree.Children(1).Children), 2, 'FAIL: ds2 not in sag tree');
            testCase.verifyEqual(numel(app.CompTree.Children(2).Children), 2, 'FAIL: ds2 not in lon tree');

            % --- Import rejection: 1D profile (constant y) ---
            file1d = fullfile(tmpdir, 'prof1d.txt');
            yconst = ones(size(M, 1), 1) * 0.5;
            M1d = [M(:, 1), M(:, 2), yconst, M(:, 4), M(:, 5), M(:, 6), M(:, 7)];
            writeDataFile(file1d, M1d);
            app.DatasetNameField.Value = 'prof1d';
            app.FilePathField.Value = file1d;
            testCase.press(app.AddDatasetButton);
            testCase.verifyEqual(numel(app.CompTree.Children(1).Children), 2, 'FAIL: 1D profile was accepted');
            testCase.verifyTrue(contains(app.ExportStatusLabel.Text, '1D profile'), ...
                ['FAIL: status msg [' app.ExportStatusLabel.Text ']']);

            % --- Add 6 more datasets (8 total) for the max-7 case ---
            for k = 3:8
                app.DatasetNameField.Value = ['ds' num2str(k)];
                app.FilePathField.Value = fileA;
                testCase.press(app.AddDatasetButton);
            end
            testCase.verifyEqual(numel(app.CompTree.Children(1).Children), 8, 'FAIL: datasets not 8');

            % --- Analysis tab: select ds1, run ---
            testCase.choose(app.TabGroup, 'Analysis');
            testCase.choose(app.DatasetDropdown, 'ds1');
            testCase.press(app.RunButton);
            testCase.verifyNotEqual(app.StatsLabelSagRMS.Text, '--', 'FAIL: sag RMS not populated');
            testCase.verifyNotEqual(app.StatsLabelLonRMS.Text, '--', 'FAIL: lon RMS not populated');
            testCase.verifyNotEqual(app.StatsLabelSagSTD.Text, '--', 'FAIL: sag STD not populated');
            testCase.verifyNotEqual(app.StatsLabelLonSTD.Text, '--', 'FAIL: lon STD not populated');
            testCase.verifyTrue(~isempty(findobj(app.ContourPlotSag, 'Type', 'Contour')), 'FAIL: sag contour empty');
            testCase.verifyTrue(~isempty(findobj(app.ContourPlotLon, 'Type', 'Contour')), 'FAIL: lon contour empty');
            testCase.verifyTrue(~isempty(findobj(app.LinePlotAx1, 'Type', 'Line')), 'FAIL: line plot 1 empty');
            testCase.verifyTrue(~isempty(findobj(app.LinePlotAx4, 'Type', 'Line')), 'FAIL: line plot 4 empty');

            % --- Comparison tab: 2 datasets under Sagittal ---
            testCase.choose(app.TabGroup, 'Comparison');
            parents = app.CompTree.Children;
            sagParent = []; lonParent = [];
            for k = 1:2
                if contains(parents(k).Text, 'Sagittal'); sagParent = parents(k); end
                if contains(parents(k).Text, 'Longitudinal'); lonParent = parents(k); end
            end
            testCase.verifyTrue(~isempty(sagParent) && ~isempty(lonParent), 'FAIL: parent lookup failed');
            app.CompTree.CheckedNodes = [sagParent.Children(1), sagParent.Children(2)];
            testCase.press(app.CompareButton);
            testCase.verifyEqual(numel(findobj(app.CompDeformationAx, 'Type', 'Line')), 2, 'FAIL: sag comparison deformation lines');
            testCase.verifyEqual(numel(findobj(app.CompSlopeAx, 'Type', 'Line')), 2, 'FAIL: sag comparison slope lines');
            testCase.verifyEqual(app.CompDeformationAx.XLabel.String, 'Sag. (x) [mm]', 'FAIL: sag xlabel wrong');

            % Unit change mm -> um rescales deformation, not slope
            yDataMM = findobj(app.CompDeformationAx, 'Type', 'Line');
            yDataMM = yDataMM(1).YData;
            slopeDataMM = findobj(app.CompSlopeAx, 'Type', 'Line');
            slopeDataMM = slopeDataMM(1).YData;
            testCase.press(app.CompUnitUM);
            yDataUM = findobj(app.CompDeformationAx, 'Type', 'Line');
            yDataUM = yDataUM(1).YData;
            slopeDataUM = findobj(app.CompSlopeAx, 'Type', 'Line');
            slopeDataUM = slopeDataUM(1).YData;
            testCase.verifyTrue(max(abs(yDataUM - 1000 * yDataMM)) < 1e-9, 'FAIL: deformation not rescaled x1000');
            testCase.verifyTrue(max(abs(slopeDataUM - slopeDataMM)) < 1e-9, 'FAIL: slope should not rescale');
            testCase.press(app.CompUnitMM);

            % Mixed direction rejected
            app.CompTree.CheckedNodes = [sagParent.Children(1), lonParent.Children(1)];
            testCase.press(app.CompareButton);
            testCase.verifyTrue(contains(app.AnalysisStatusLabel.Text, 'sagittal-to-sagittal'), ...
                ['FAIL: mixed-direction msg [' app.AnalysisStatusLabel.Text ']']);
            testCase.verifyTrue(isempty(findobj(app.CompDeformationAx, 'Type', 'Line')), 'FAIL: axes not cleared on mixed direction');
            app.CompTree.CheckedNodes = [];

            % Longitudinal comparison works
            app.CompTree.CheckedNodes = [lonParent.Children(1), lonParent.Children(2)];
            testCase.press(app.CompareButton);
            testCase.verifyEqual(numel(findobj(app.CompSlopeAx, 'Type', 'Line')), 2, 'FAIL: lon comparison failed');
            testCase.verifyEqual(app.CompDeformationAx.XLabel.String, 'Lon. (y) [mm]', 'FAIL: lon xlabel wrong');
            app.CompTree.CheckedNodes = [];

            % Max-7 check (8 checked under Sagittal)
            parents = app.CompTree.Children;
            sagParent = [];
            for k = 1:2
                if contains(parents(k).Text, 'Sagittal'); sagParent = parents(k); end
            end
            app.CompTree.CheckedNodes = [sagParent.Children(1:8)];
            testCase.press(app.CompareButton);
            testCase.verifyTrue(contains(app.CompDeformationAx.Title.String, 'Maximum 7'), ...
                ['FAIL: max-7 msg [' app.CompDeformationAx.Title.String ']']);

            % --- Export from Import tab: -2D- filenames, 2 contour + 1 montage PNG ---
            testCase.choose(app.TabGroup, 'Import Data');
            expdir = fullfile(tmpdir, 'export');
            if ~exist(expdir, 'dir'); mkdir(expdir); end
            app.ExportDatasetDropdown.Value = 'ds1';
            app.ExportDirField.Value = expdir;
            app.DverField.Value = 'ZZZZ';
            app.BlnameField.Value = 'ZZZZ';
            app.OptnameField.Value = 'ZZZZ';
            app.ScenameField.Value = 'ZZZZ';
            testCase.press(app.ImportExportButton);
            d = dir(fullfile(expdir, 'FEA-ZZZZ-ZZZZ-ZZZZ-ZZZZ-*'));
            names = {d.name};
            testCase.verifyTrue(any(contains(names, '-2D-')), ['FAIL: no -2D- in export filenames, got: ' strjoin(names, ', ')]);
            testCase.verifyTrue(any(contains(names, '-SagittalSlope.png')), 'FAIL: sag PNG missing');
            testCase.verifyTrue(any(contains(names, '-LongitudinalSlope.png')), 'FAIL: lon PNG missing');
            testCase.verifyTrue(any(contains(names, '-LinePlots.png')), 'FAIL: line montage PNG missing');
            testCase.verifyEqual(numel(d), 9, ['FAIL: expected 9 export files, got ' num2str(numel(d))]);
        end
    end
end

function writeDataFile(fn, m)
fid = fopen(fn, 'w');
fprintf(fid, 'Node Number\tX Location (mm)\tY Location (mm)\tZ Location (mm)\tVector Deformation ()\n');
fprintf(fid, '%d\t%.6f\t%.6f\t%.6f\t%.6e\t%.6e\t%.6e\n', m');
fclose(fid);
end