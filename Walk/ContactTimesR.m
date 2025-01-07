function [ContactR] = ContactTimesR(data)


position_cells = data.segmented.new_seg.Segmented.Rseg.Pos_seg(:, 60);
velocity_cells = data.segmented.new_seg.Segmented.Rseg.V_seg(:, 12);
position_concat = vertcat(position_cells{:});
velocity_concat = vertcat(velocity_cells{:});


num_strides = numel(position_cells);
ContactR = table('Size', [num_strides, 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, 'VariableNames', {'HSIdx', 'TOIdx', 'TotalHSIdx', 'TotalTOIdx'});


%process each stride and find heel strike and toe off
stride_start_indices = zeros(num_strides, 1);
for i = 1:num_strides
    position_stride = position_cells{i};
    velocity_stride = velocity_cells{i};
    num_points = numel(position_stride);
    
    %Black XLINE (stride start)
    stride_start_indices(i) = sum(cellfun(@numel, position_cells(1:i-1))) + 1;
    
    %Red XLINE (Toe OFF)
    [min_pos, min_pos_idx] = min(position_stride);
    
    %Blue XLINE (Heel Strike)
    zero_crossings = find(velocity_stride(1:end-1) < 0 & velocity_stride(2:end)>= 0, 1);
    
    % If no zero-crossing is found, assign default value
    if isempty(zero_crossings)
        zero_crossings = 1; % Default value for blue xline
        min_pos_idx = 1;    % Default value for red xline (for consistency)
    end
    
    
    ContactR.HSIdx(i) = zero_crossings;
    ContactR.TOIdx(i) = min_pos_idx;
end

ContactR.TotalHSIdx = ContactR.HSIdx + stride_start_indices - 1;
ContactR.TotalTOIdx = ContactR.TOIdx + stride_start_indices - 1;

% Normalize position signal to the scale of velocity signal
position_min = min(position_concat);
position_max = max(position_concat);
velocity_min = min(velocity_concat);
velocity_max = max(velocity_concat);

% Scale position to match velocity's range
position_scaled = ((position_concat - position_min) / (position_max - position_min)) * ...
    (velocity_max - velocity_min) + velocity_min;

% Apply offset to position
position_scaled = position_scaled - 3; % Offset by -5

global_y_min = min([position_scaled; velocity_concat]) - 1; % Include some padding
global_y_max = max([position_scaled; velocity_concat]) + 1;



% Create figure with scroll bar

screen_size = get(0, 'Screensize'); % Get the full screen size
fig_width = screen_size(3) * 0.80;  % 80% of screen width
fig_height = screen_size(4) * 0.80; % 80% of screen height
fig_x = screen_size(3) * 0.1;      % Centered horizontally
fig_y = screen_size(4) * 0.1;      % Centered vertically


fig = figure('Position', [fig_x, fig_y, fig_width, fig_height], ...
    'Name', 'Scrollable Signal with XLines', 'NumberTitle', 'off', ...
    'WindowButtonUpFcn', @finalizeDragging);

% Plot concatenated signals
ax = axes('Parent', fig);
hold(ax, 'on');
position_plot = plot(ax, 1:numel(position_scaled), position_scaled, 'r', 'LineWidth', 2); % Position in red
velocity_plot = plot(ax, 1:numel(velocity_concat), velocity_concat, 'b', 'LineWidth', 2); % Velocity in blue
title(ax, 'Blue signal is foot vertical velocity - Red signal is toe vertical position')
% Adjust alpha (transparency)
position_plot.Color(4) = 0.3; % Set transparency to 30%
velocity_plot.Color(4) = 0.3; % Set transparency to 30%
% Set constant y-axis limits to include offset
ylim(ax, [global_y_min, global_y_max]);

% Set initial x-axis limits
xlim(ax, [1, 500]); % Initial x-axis range
yline(ax, 0, 'LineStyle', '--')
% Add xlines for each stride
stride_xlines = gobjects(num_strides, 3); % Preallocate for black, red, and blue xlines

for i = 1:num_strides
    % Black xline: Start of each stride (no drag functionality)
    stride_xlines(i, 1) = xline(ax, stride_start_indices(i), 'k-', ...
        'Label', sprintf('Stride %d', i), 'LineWidth', 1, ...
        'LabelOrientation', 'aligned', 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'center');

    % Red xline: Minimum position (toe-off) (with drag functionality)
    stride_xlines(i, 2) = xline(ax, ContactR.TotalTOIdx(i), 'r-', 'LineWidth', 1.5, 'LineStyle', ':', ...
        'Label', sprintf('Toe off %d', i), 'LabelOrientation', 'aligned', ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'center', ...
        'ButtonDownFcn', @startDragging); % Allow dragging

    % Blue xline: Zero-crossing of velocity (heel strike) (with drag functionality)
    stride_xlines(i, 3) = xline(ax, ContactR.TotalHSIdx(i), 'b-', 'LineWidth', 1.5, 'LineStyle', ':', ...
        'Label', sprintf('Heel Strike %d', i), 'LabelOrientation', 'aligned', ...
        'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'center', ...
        'ButtonDownFcn', @startDragging); % Allow dragging
end

% Add scroll bar
max_slider_value= max(numel(position_scaled)-500, 1);
small_step= min(500/numel(position_scaled), 1);
large_step= min(0.1, 1);
scroll_bar = uicontrol('Style', 'slider', ...
    'Parent', fig, ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.02, 0.8, 0.03], ...
    'Min', 1, ...
    'Max', max_slider_value, ...
    'Value', 1, ...
    'SliderStep', [small_step large_step]);
addlistener(scroll_bar, 'ContinuousValueChange', @(src, event) updateXlim(src, ax));

fig.UserData = struct(...
    'stride_xlines', stride_xlines, ...
    'ax', ax, ...
    'dragging', false, ...
    'current_xline', [], ...
    'num_strides', num_strides, ...
    'ContactR', ContactR, ...
    'stride_start_indices', stride_start_indices);

% Update stride-relative indices
for i = 1:num_strides
    ContactR.HSIdx(i) = ContactR.TotalHSIdx(i) - stride_start_indices(i) + 1;
    ContactR.TOIdx(i) = ContactR.TotalTOIdx(i) - stride_start_indices(i) + 1;
end


function updateXlim(scroll_bar, ax)
    start_point = round(get(scroll_bar, 'Value'));
    set(ax, 'XLim', [start_point, start_point + 500]);
end

% Dragging functionality
function startDragging(src, ~)
    fig = ancestor(src, 'figure'); % Get the parent figure
    fig.UserData.dragging = true;
    fig.UserData.current_xline = src; % Store the xline being dragged
    set(fig, 'WindowButtonMotionFcn', @dragXline);
end

function dragXline(~, ~)
    fig = gcf; % Get the current figure
    if fig.UserData.dragging
        ax = fig.UserData.ax; % Get the axes
        pt = get(ax, 'CurrentPoint'); % Get current mouse position
        set(fig.UserData.current_xline, 'Value', pt(1, 1)); % Update xline position
    end
end

function finalizeDragging(~, ~)
    fig = gcf; % Get the current figure
    fig.UserData.dragging = false;
    set(fig, 'WindowButtonMotionFcn', ''); % Disable motion callback
    
    % Retrieve necessary data from fig.UserData
    current_xline = fig.UserData.current_xline;
    stride_xlines = fig.UserData.stride_xlines;
    num_strides = fig.UserData.num_strides;
    stride_start_indices = fig.UserData.stride_start_indices;
    ContactR = fig.UserData.ContactR;
    
    % Ensure there's a dragged xline
    if isempty(current_xline)
        return; % No xline was dragged
    end
    
    % Get updated xline value (index in the concatenated signal)
    updated_index = round(current_xline.Value); % Round to nearest integer
    
    % Update ContactR table
    for i = 1:num_strides
        if current_xline == stride_xlines(i, 2) % Red xline (Toe-Off)
            ContactR.TotalTOIdx(i) = updated_index; % Update global index
            ContactR.TOIdx(i) = updated_index - stride_start_indices(i) + 1; % Update stride-relative index
        elseif current_xline == stride_xlines(i, 3) % Blue xline (Heel Strike)
            ContactR.TotalHSIdx(i) = updated_index; % Update global index
            ContactR.HSIdx(i) = updated_index - stride_start_indices(i) + 1; % Update stride-relative index
        end
    end
    
    % Update the ContactR table in fig.UserData
    fig.UserData.ContactR = ContactR;
    
    % Update the ContactR table in the workspace
    assignin('base', 'ContactR', ContactR); % Assign updated ContactR to base workspace
    
    % Clear current xline after updating
    fig.UserData.current_xline = [];
end
    waitfor(fig);

end