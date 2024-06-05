function fakeCurrencyDetected = detectFakeCurrency(img)
    % Set the threshold area for flower detection
    thresholdArea = 100; % Adjust as needed

    % Feature 1: Flower Detection
    isFlowerDetected = detectFlower(img, thresholdArea);

    % Feature 2: Facial Feature Detection
    isFaceDetected = detectFacialFeatures(img);

    % Feature 3: Text Detection
    isTextDetected = detectText(img);

    % Combine the results using a logical OR operation
    overallDetection = ~(isFlowerDetected && isFaceDetected && isTextDetected);

    if overallDetection
        disp('Fake Currency Detected');
        fakeCurrencyDetected = true;

    else
        disp('Real Currency Detected');
        fakeCurrencyDetected = false;
    end
    
end

function isFlowerDetected = detectFlower(img, thresholdArea)
    % Convert the image to Lab color space
    labImg = rgb2lab(img);
    
    % Enhance contrast of the 'L' channel
    LChannel = labImg(:, :, 1);
    LChannel = imadjust(LChannel);
    
    % Extract the 'a' and 'b' channels to perform color-based segmentation
    aChannel = labImg(:, :, 2);
    bChannel = labImg(:, :, 3);
    
    % Define color thresholds for hibiscus detection (adjust as needed)
    aThreshold = [20, 80];
    bThreshold = [5, 60];  % Adjusted threshold for b channel
    
    % Create binary masks based on color thresholds
    aMask = (aChannel >= aThreshold(1)) & (aChannel <= aThreshold(2));
    bMask = (bChannel >= bThreshold(1)) & (bChannel <= bThreshold(2));
    
    % Combine the masks
    colorMask = aMask & bMask;
    
    % Apply morphological operations to clean up the mask (adjust as needed)
    colorMask = imclose(colorMask, strel('disk', 5));
    colorMask = imfill(colorMask, 'holes');
    
    % Convert the color mask to grayscale
    grayMask = rgb2gray(double(cat(3, colorMask, colorMask, colorMask)));
    
    % Apply additional preprocessing to enhance the mask
    se = strel('disk', 3);
    processedMask = imopen(grayMask, se);
    
    % Apply adaptive thresholding to the processed grayscale mask
    bwMask = imbinarize(processedMask, 'adaptive', 'Sensitivity', 0.5);
    
    % Find contours in the binary mask
    contourMask = bwperim(bwMask);
    
    % Use regionprops to find connected components in the binary mask
    props = regionprops(bwMask, 'BoundingBox', 'Area', 'Centroid', 'Eccentricity');
    
    % Keep only the largest region
    if ~isempty(props)
        [~, idx] = max([props.Area]);
        largestRegion = props(idx);

        % Display the original image with a grid
        figure;
        subplot(1, 3, 1);
        imshow(img);
        hold on;

        % Convert the color mask to grayscale for the detected hibiscus region
        grayRoiMask = rgb2gray(double(cat(3, colorMask, colorMask, colorMask)));

        % Apply adaptive thresholding to the grayscale mask of the detected hibiscus region
        bwRoiMask = imbinarize(grayRoiMask, 'adaptive', 'Sensitivity', 0.5);

        subplot(1, 3, 2);
        if isempty(largestRegion) || largestRegion.Eccentricity >= 0.8
            % No hibiscus detected or the detected region is not circular
            isFlowerDetected = false;
            disp('Hibiscus not detected.');
        else
            % Display binary mask of the detected hibiscus region
            imshow(bwRoiMask);
            title('Binary Mask of Detected Hibiscus Region');

            % Highlight the largest region with a bounding box, add annotations, and show the grid
            bb = largestRegion.BoundingBox;
            centroid = largestRegion.Centroid;
            rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);
            text(bb(1), bb(2), ['X: ' num2str(round(bb(1))) ', Y: ' num2str(round(bb(2)))], ...
                'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');

            % Extract and detect the hibiscus region
            roi = imcrop(img, bb);

            % Check if the region is circular
            isCircular = largestRegion.Eccentricity < 0.8;

            % Return the result
            isFlowerDetected = largestRegion.Area > thresholdArea && isCircular;

            % Display a message in the command window
            if isFlowerDetected
                disp('Hibiscus detected.');
                
                % Display the extracted hibiscus image without the binary mask
                subplot(1, 3, 3);
                imshow(roi);
                title('Extracted Hibiscus Image');
            else
                disp('Hibiscus not detected.');
            end
        end
    else
        % No regions found
        disp('Hibiscus not detected.');
        isFlowerDetected = false;
    end
end


function isFaceDetected = detectFacialFeatures(img)
    % Convert the image to grayscale
    grayImg = rgb2gray(img);

    % Enhance contrast using histogram equalization
    enhancedImg = histeq(grayImg);

    % Apply Gaussian filtering to reduce noise
    filteredImg = imgaussfilt(enhancedImg, 2);

    % Create a face detector object
    faceDetector = vision.CascadeObjectDetector();

    % Detect faces in the enhanced grayscale image
    bbox = step(faceDetector, filteredImg);

    % If faces are detected, consider it as a face
    isFaceDetected = ~isempty(bbox);

        % Extract and display each face in separate figures
        for i = 1:size(bbox, 1)
            % Extract the ith face without the skin color filter
            face = imcrop(filteredImg, bbox(i, :));

            % Additional steps for facial feature detection (example: eyes)
            eyeDetector = vision.CascadeObjectDetector('EyePairBig');
            eyeBBox = step(eyeDetector, face);

            % Display bounding boxes around detected eyes
            if ~isempty(eyeBBox)
                disp('Eyes detected.');

                hold on;
                for j = 1:size(eyeBBox, 1)
                    rectangle('Position', eyeBBox(j, :), 'EdgeColor', 'g', 'LineWidth', 1);
                end
                hold off;

                % Extract and enhance each detected eye
                for k = 1:size(eyeBBox, 1)
                    eye = imcrop(face, eyeBBox(k, :));

                    % Enhance contrast of the eye region
                    enhancedEye = adapthisteq(eye);

                    % Apply sharpening to the enhanced eye
                    sharpenedEye = imsharpen(enhancedEye);

                    % Display the sharpened eye in a separate figure
                    figure;
                    imshow(sharpenedEye);
                    title(['Sharpened Eye ', num2str(k)]);
                end
            else
                disp('No eyes detected.');
            end
        end
    end


    function isTextDetected = detectText(img)
    % Convert the image to grayscale
    grayImg = rgb2gray(img);
    
    % Use OCR to detect text
    ocrResults = ocr(grayImg);
    
    % Specify the target words
    targetWords = {'Bank','Negara', 'Malaysia'};
    
    % Initialize the flag indicating text detection
    isTextDetected = false;
    
    % Loop through each recognized word and check if it matches the target words
    for i = 1:numel(ocrResults.Words)
        currentWord = ocrResults.Words{i};
        
        % Check if the current word is one of the target words
        if any(strcmpi(currentWord, targetWords))
            isTextDetected = true;
        end
    end
    
    % Loop through each recognized word and highlight with a bounding box
    for i = 1:numel(ocrResults.Words)
        currentWord = ocrResults.Words{i};
        if any(strcmpi(currentWord, targetWords))
            % Get the bounding box of the current word
            bb = ocrResults.WordBoundingBoxes(i, :);
    
            % Highlight the current word with a bounding box
            rectangle('Position', bb, 'EdgeColor', 'g', 'LineWidth', 2);
    
            % Extract and display the word region
            extractedWord = imcrop(img, bb);
    
            % Display the extracted word in a new figure
            figure;
            imshow(extractedWord);
            title(['Extracted Word: ' currentWord]);
        end
    end
    
    % Display a message in the command window if no text is detected
    if ~isTextDetected
        disp('No text detected.');
    end
end

function isTextDetected = detectTextAndEyes(img)
    % Call the detectText function
    isTextDetected = detectText(img);

    % If text is detected, display a message in the command window
    if isTextDetected
        disp('Text detected.');
    else
        disp('No text detected.');
    end

    % Use vision.CascadeObjectDetector to detect eyes
    eyeDetector = vision.CascadeObjectDetector('EyePairBig');
    
    % Detect eyes in the image
    eyesBboxes = step(eyeDetector, img);
    
    % If eyes are detected, display a message in the command window
    if ~isempty(eyesBboxes)
        disp('Eyes detected.');
        
        % Loop through each pair of detected eyes and draw bounding boxes
        for i = 1:size(eyesBboxes, 1)
            bbox = eyesBboxes(i, :);
            
            % Draw bounding box around each pair of eyes
            rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2);
        end
    else
        disp('No eyes detected.');
    end
end

   

