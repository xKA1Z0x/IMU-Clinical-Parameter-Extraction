function [ContactL, stride_start_indices_L] = ContactTimesL(data)

% Check if the Contact table exists
if isfield(data.segmented.new_seg.Segmented.Lseg, 'Contact') && ~isempty(data.segmented.new_seg.Segmented.Lseg.Contact)
    % Use existing table
    ContactL = data.segmented.new_seg.Segmented.Lseg.Contact;

    % Compute stride_start_indices_L based on existing data
    position_cells = data.segmented.new_seg.Segmented.Lseg.Pos_seg(:, 69);
    num_strides = height(ContactL);
    stride_start_indices_L = zeros(num_strides, 1);
    for i = 1:num_strides
        stride_start_indices_L(i) = sum(cellfun(@numel, position_cells(1:i-1))) + 1;
    end
else
    % Perform calculations to create the table
    position_cells = data.segmented.new_seg.Segmented.Lseg.Pos_seg(:, 69);
    velocity_cells = data.segmented.new_seg.Segmented.Lseg.V_seg(:, 21);
    num_strides = numel(position_cells);
    stride_start_indices_L = zeros(num_strides, 1);
    ContactL = table('Size', [num_strides, 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, ...
                     'VariableNames', {'HSIdx', 'TOIdx', 'TotalHSIdx', 'TotalTOIdx'});

    for i = 1:num_strides
        position_stride = position_cells{i};
        velocity_stride = velocity_cells{i};
        stride_start_indices_L(i) = sum(cellfun(@numel, position_cells(1:i-1))) + 1;

        % Toe-off (local minima in position)
        [~, local_min_idx] = findpeaks(-position_stride);
        if ~isempty(local_min_idx)
            velocities_at_minima = velocity_stride(local_min_idx);
            [~, max_velocity_idx] = max(velocities_at_minima);
            min_pos_idx = local_min_idx(max_velocity_idx);
        else
            min_pos_idx = 1;
        end

        % Heel strike (zero-crossing of velocity)
        zero_crossings = find(velocity_stride(1:end-1) < 0 & velocity_stride(2:end) >= 0, 1);
        if isempty(zero_crossings)
            zero_crossings = 1;
        end

        ContactL.HSIdx(i) = zero_crossings;
        ContactL.TOIdx(i) = min_pos_idx;
    end
    ContactL.TotalHSIdx = ContactL.HSIdx + stride_start_indices_L - 1;
    ContactL.TotalTOIdx = ContactL.TOIdx + stride_start_indices_L - 1;
end

% Concatenate signals for visualization
position_concat = vertcat(data.segmented.new_seg.Segmented.Lseg.Pos_seg{:, 69});
velocity_concat = vertcat(data.segmented.new_seg.Segmented.Lseg.V_seg{:, 21});
position_min = min(position_concat);
position_max = max(position_concat);
velocity_min = min(velocity_concat);
velocity_max = max(velocity_concat);
position_scaled = ((position_concat - position_min) / (position_max - position_min)) * ...
                  (velocity_max - velocity_min) + velocity_min - 3;

global_y_min = min([position_scaled; velocity_concat]) - 1;
global_y_max = max([position_scaled; velocity_concat]) + 1;

screen_size = get(0, 'ScreenSize'); % Get full screen size
fig = figure('Name', 'Interactive Signal Visualization - Left', ...
             'NumberTitle', 'off', ...
             'WindowButtonUpFcn', @finalizeDragging, ...
             'Position', [screen_size(3)*0.1, screen_size(4)*0.1, screen_size(3)*0.8, screen_size(4)*0.8]); % 80% of screen


ax = axes('Parent', fig);
hold(ax, 'on');
position_plot = plot(ax, 1:numel(position_scaled), position_scaled, 'r', 'LineWidth', 2);
velocity_plot = plot(ax, 1:numel(velocity_concat), velocity_concat, 'b', 'LineWidth', 2);
position_plot.Color(4) = 0.3; % Set transparency for position plot (30%)
velocity_plot.Color(4) = 0.3; % Set transparency for velocity plot (30%)
title(ax, 'Blue signal: foot vertical velocity | Red signal: toe vertical position');
yline(ax, 0, '--');
ylim(ax, [global_y_min, global_y_max]);
xlim(ax, [1, 500]);

stride_xlines = gobjects(height(ContactL), 2);
for i = 1:height(ContactL)
    stride_start_idx = stride_start_indices_L(i);
    xline(ax, stride_start_idx, 'k-', 'Label', sprintf('Stride %d', i), ...
          'LineWidth', 1, 'LabelOrientation', 'aligned', 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'center');
    stride_xlines(i, 1) = xline(ax, ContactL.TotalTOIdx(i), 'r-', 'LineWidth', 1.5, 'LineStyle', ':', ...
        'Label', sprintf('Toe Off %d', i), 'LabelOrientation', 'aligned', ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'center', ...
        'ButtonDownFcn', @startDragging);
    stride_xlines(i, 2) = xline(ax, ContactL.TotalHSIdx(i), 'b-', 'LineWidth', 1.5, 'LineStyle', ':', ...
        'Label', sprintf('Heel Strike %d', i), 'LabelOrientation', 'aligned', ...
        'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'center', ...
        'ButtonDownFcn', @startDragging);
end

scroll_bar = uicontrol('Style', 'slider', ...
                       'Parent', fig, ...
                       'Units', 'normalized', ...
                       'Position', [0.1, 0.02, 0.8, 0.03], ...
                       'Min', 1, ...
                       'Max', max(numel(position_scaled) - 500, 1), ...
                       'Value', 1, ...
                       'SliderStep', [min(500 / numel(position_scaled), 1), min(0.1, 1)]);
addlistener(scroll_bar, 'ContinuousValueChange', @(src, event) updateXlim(src, ax));

fig.UserData = struct('Contact', ContactL, ...
                      'ax', ax, ...
                      'stride_xlines', stride_xlines, ...
                      'dragging', false, ...
                      'current_xline', [], ...
                      'stride_start_indices_L', stride_start_indices_L);

function startDragging(src, ~)
    fig.UserData.dragging = true;
    fig.UserData.current_xline = src;
    set(fig, 'WindowButtonMotionFcn', @dragXline);
end

function dragXline(~, ~)
    if fig.UserData.dragging
        pt = get(fig.UserData.ax, 'CurrentPoint');
        set(fig.UserData.current_xline, 'Value', round(pt(1, 1)));
    end
end

function finalizeDragging(~, ~)
    fig.UserData.dragging = false;
    set(fig, 'WindowButtonMotionFcn', '');
    if isempty(fig.UserData.current_xline)
        return;
    end
    updated_index = round(fig.UserData.current_xline.Value);
    for i = 1:height(ContactL)
        if fig.UserData.current_xline == stride_xlines(i, 1)
            ContactL.TotalTOIdx(i) = updated_index;
            ContactL.TOIdx(i) = updated_index - stride_start_indices_L(i) + 1;
        elseif fig.UserData.current_xline == stride_xlines(i, 2)
            ContactL.TotalHSIdx(i) = updated_index;
            ContactL.HSIdx(i) = updated_index - stride_start_indices_L(i) + 1; 
        end
    end
    assignin('base', 'ContactL', ContactL);
    fig.UserData.current_xline = [];
end

function updateXlim(scroll_bar, ax)
    start_point = round(get(scroll_bar, 'Value'));
    set(ax, 'XLim', [start_point, start_point + 500]);
end

waitfor(fig);

end
