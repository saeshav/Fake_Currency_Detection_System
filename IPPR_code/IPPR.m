    classdef IPPR_ASSIGNMENT < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        FakeCurrencyDetectionPanel  matlab.ui.container.Panel
        Panel                       matlab.ui.container.Panel
        DetectButton                matlab.ui.control.Button
        UploadImageFileButton       matlab.ui.control.Button
        UIAxes                      matlab.ui.control.UIAxes
        image1
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadImageFileButton
     function UploadImageFileButtonPushed(app, event)
    [filename, pathname] = uigetfile({'*.jpg'}, 'Open File');
    if isequal(filename, 0)
        % User clicked Cancel
        return;
    end

    % Read the image and store it in the app property
    fullpathname = fullfile(pathname, filename);
    app.image1 = imread(fullpathname);

    % Display the image in UIAxes
    imshow(app.image1, 'Parent', app.UIAxes);
end


        % Button down function: UIAxes
        function UIAxesButtonDown(app, event)
                
        end

        % Button pushed function: DetectButton
function DetectButtonPushed(app, event)
    % Check if an image is loaded
    if isempty(app.image1)
        % Display an error message or provide UI feedback
        disp('Please upload an image first.');
        return;
    end
    
    % Display the size of app.image1
    disp(['Size of app.image1: ' num2str(size(app.image1))]);

    % Call your fake currency detection function

    
    
    
    
    fakeCurrencyDetected = detectFakeCurrency(app.image1);

    % Display the result in the UI
    if fakeCurrencyDetected
        % Provide UI feedback (e.g., change text color or display a message)
        app.DetectButton.Text = 'Fake Currency Detected';
        app.DetectButton.BackgroundColor = [1 0 0]; % Red background
    else
        % Provide UI feedback (e.g., change text color or display a message)
        app.DetectButton.Text = 'No Fake Currency Detected';
        app.DetectButton.BackgroundColor = [0 1 0]; % Green background
    end
end


    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
       function createComponents(app)
    addpath(pwd);

    % Create UIFigure and hide until all components are created
    app.UIFigure = uifigure('Visible', 'off');
    app.UIFigure.Position = [100 100 640 480];
    app.UIFigure.Name = 'MATLAB App';

    % Create FakeCurrencyDetectionPanel
    app.FakeCurrencyDetectionPanel = uipanel(app.UIFigure);
    app.FakeCurrencyDetectionPanel.ForegroundColor = [0.149 0.149 0.149];
    app.FakeCurrencyDetectionPanel.TitlePosition = 'centertop';
    app.FakeCurrencyDetectionPanel.Title = 'Fake Currency Detection';
    app.FakeCurrencyDetectionPanel.BackgroundColor = [0.9294 0.6941 0.1255];
    app.FakeCurrencyDetectionPanel.FontSize = 36;
    app.FakeCurrencyDetectionPanel.Position = [1 1 640 480];

    % Create UIAxes
    app.UIAxes = uiaxes(app.FakeCurrencyDetectionPanel);
    app.UIAxes.Position = [159 198 300 185];

            % Create Panel
            app.Panel = uipanel(app.FakeCurrencyDetectionPanel);
            app.Panel.BackgroundColor = [1 1 0];
            app.Panel.Position = [0 1 640 140];

            % Create UploadImageFileButton
            app.UploadImageFileButton = uibutton(app.Panel, 'push');
            app.UploadImageFileButton.ButtonPushedFcn = createCallbackFcn(app, @UploadImageFileButtonPushed, true);
            app.UploadImageFileButton.BackgroundColor = [0 1 0];
            app.UploadImageFileButton.Position = [148 69 145 23];
            app.UploadImageFileButton.Text = 'Upload Image File';

            % Create DetectButton
            app.DetectButton = uibutton(app.Panel, 'push');
            app.DetectButton.ButtonPushedFcn = createCallbackFcn(app, @DetectButtonPushed, true);
            app.DetectButton.BackgroundColor = [0 1 1];
            app.DetectButton.Position = [349 69 159 23];
            app.DetectButton.Text = 'Detect';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = IPPR_ASSIGNMENT

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end 