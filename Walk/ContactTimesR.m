function [ContactR, stride_start_indices_R] = ContactTimesR(data)

% Check if the Contact table exists
if isfield(data.segmented.new_seg.Segmented.Rseg, 'Contact') && ~isempty(data.segmented.new_seg.Segmented.Rseg.Contact)
    % Use existing table
    ContactR = data.segmented.new_seg.Segmented.Rseg.Contact;

    % Compute stride_start_indices_R based on existing data
    position_cells = data.segmented.new_seg.Segmented.Rseg.Pos_seg(:, 60);
    num_strides = height(ContactR);
    stride_start_indices_R = zeros(num_strides, 1);
    for i = 1:num_strides
        stride_start_indices_R(i) = sum(cellfun(@numel, position_cells(1:i-1))) + 1;
    end
else
    % Perform calculations to create the table
    position_cells = data.segmented.new_seg.Segmented.Rseg.Pos_seg(:, 60);
    velocity_cells = data.segmented.new_seg.Segmented.Rseg.V_seg(:, 12);
    num_strides = numel(position_cells);
    stride_start_indices_R = zeros(num_strides, 1);
    ContactR = table('Size', [num_strides, 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, ...
                     'VariableNames', {'HSIdx', 'TOIdx', 'TotalHSIdx', 'TotalTOIdx'});

    for i = 1:num_strides
        position_stride = position_cells{i};
        velocity_stride = velocity_cells{i};
        stride_start_indices_R(i) = sum(cellfun(@numel, position_cells(1:i-1))) + 1;

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

        ContactR.HSIdx(i) = zero_crossings;
        ContactR.TOIdx(i) = min_pos_idx;
    end
    ContactR.TotalHSIdx = ContactR.HSIdx + stride_start_indices_R - 1;
    ContactR.TotalTOIdx = ContactR.TOIdx + stride_start_indices_R - 1;
end

% Visualization and updates remain unchanged
position_concat = vertcat(data.segmented.new_seg.Segmented.Rseg.Pos_seg{:, 60});
velocity_concat = vertcat(data.segmented.new_seg.Segmented.Rseg.V_seg{:, 12});
position_min = min(position_concat);
position_max = max(position_concat);
velocity_min = min(velocity_concat);
velocity_max = max(velocity_concat);
position_scaled = ((position_concat - position_min) / (position_max - position_min)) * ...
                  (velocity_max - velocity_min) + velocity_min - 3;

global_y_min = min([position_scaled; velocity_concat]) - 1;
global_y_max = max([position_scaled; velocity_concat]) + 1;

screen_size = get(0, 'ScreenSize'); % Get full screen size
fig = figure('Name', 'Interactive Signal Visualization - Right', ...
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

stride_xlines = gobjects(height(ContactR), 2);
for i = 1:height(ContactR)
    stride_start_idx = stride_start_indices_R(i);
    xline(ax, stride_start_idx, 'k-', 'Label', sprintf('Stride %d', i), ...
          'LineWidth', 1, 'LabelOrientation', 'aligned', 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'center');
    stride_xlines(i, 1) = xline(ax, ContactR.TotalTOIdx(i), 'r-', 'LineWidth', 1.5, 'LineStyle', ':', ...
        'Label', sprintf('Toe Off %d', i), 'LabelOrientation', 'aligned', ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'center', ...
        'ButtonDownFcn', @startDragging);
    stride_xlines(i, 2) = xline(ax, ContactR.TotalHSIdx(i), 'b-', 'LineWidth', 1.5, 'LineStyle', ':', ...
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

fig.UserData = struct('Contact', ContactR, ...
                      'ax', ax, ...
                      'stride_xlines', stride_xlines, ...
                      'dragging', false, ...
                      'current_xline', [], ...
                      'stride_start_indices_R', stride_start_indices_R);

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
    for i = 1:height(ContactR)
        if fig.UserData.current_xline == stride_xlines(i, 1)
            ContactR.TotalTOIdx(i) = updated_index;
            ContactR.TOIdx(i) = updated_index - stride_start_indices_R(i) + 1;
        elseif fig.UserData.current_xline == stride_xlines(i, 2)
            ContactR.TotalHSIdx(i) = updated_index;
            ContactR.HSIdx(i) = updated_index - stride_start_indices_R(i) + 1 ;
        end
    end
    assignin('base', 'ContactR', ContactR);
    fig.UserData.current_xline = [];
end

function updateXlim(scroll_bar, ax)
    start_point = round(get(scroll_bar, 'Value'));
    set(ax, 'XLim', [start_point, start_point + 500]);
end

waitfor(fig);

end
