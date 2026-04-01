function plotConstellation3DVideo(r_sat, visibleSat, users, siteNames, tspan, outputFile)

if nargin < 6
    outputFile = 'constellation_simulation.mp4';
end

% constant
Re = 6378e3;

nUser = size(users, 1);
nSat = size(r_sat, 3);
Nt = size(r_sat, 2);
nLeo = max(nSat - 1, 0);

targetPos = zeros(3, nUser);
for u = 1:nUser
    lat = users(u, 1);
    lon = users(u, 2);
    h = users(u, 3);
    
    % Geo -> ECEF
    targetPos(:, u) = [(Re + h)*cos(lat)*cos(lon);
                       (Re + h)*cos(lat)*sin(lon);
                       (Re + h)*sin(lat)];
end

targetCenter = mean(targetPos, 2);
viewDir = targetCenter / norm(targetCenter);
equatorNormal = [0; 0; 1];
viewDir = viewDir - dot(viewDir, equatorNormal) * equatorNormal;
if norm(viewDir) < 1e-9
    viewDir = [1; 0; 0];
else
    viewDir = viewDir / norm(viewDir);
end

[earthX, earthY, earthZ] = sphere(80);

fig = figure('Color', 'k');
ax = axes(fig);
hold(ax, 'on');
surf(ax, Re * earthX, Re * earthY, Re * earthZ, ...
    'FaceColor', [0.1 0.35 0.75], ...
    'EdgeColor', 'none', ...
    'FaceAlpha', 1.0);
lighting(ax, 'gouraud');
material(ax, 'dull');
camlight(ax, 'headlight');

% plot all target points
for u = 1:nUser
    plot3(ax, targetPos(1,u), targetPos(2,u), targetPos(3,u), 'o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [1 1 1], ...
        'MarkerEdgeColor', [1 0 1], ...
        'LineWidth', 1.2, ...
        'LineStyle', 'none');
    text(ax, targetPos(1,u), targetPos(2,u), targetPos(3,u), ['  ' siteNames{u}], ...
        'Color', [1 1 1], 'FontSize', 9, 'FontWeight', 'bold');
end

% plot all LEO sat and track
leoMarkers = gobjects(nLeo, 1);
leoTrails = gobjects(nLeo, 1);
for s = 1:nLeo
    leoTrails(s) = plot3(ax, nan, nan, nan, ...
        'Color', [0.55 0.55 0.55], 'LineWidth', 0.8);
    leoMarkers(s) = plot3(ax, r_sat(1,1,s), r_sat(2,1,s), r_sat(3,1,s), ...
        'o', 'MarkerSize', 8, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c', ...
        'LineStyle', 'none');
end

% plot GEO sat
geoTrail = plot3(ax, nan, nan, nan, ...
    'Color', [1 0.8 0.2], 'LineWidth', 1.2);
geoMarker = plot3(ax, r_sat(1,1,nSat), r_sat(2,1,nSat), r_sat(3,1,nSat), ...
    's', 'MarkerSize', 10, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y', ...
    'LineStyle', 'none');
text(ax, r_sat(1,1,nSat), r_sat(2,1,nSat), r_sat(3,1,nSat), ...
    '  GEO', 'Color', [1 1 0], 'FontSize', 10, 'FontWeight', 'bold');

losLines = gobjects(nLeo, nUser);
for s = 1:nLeo
    for u = 1:nUser
        losLines(s, u) = plot3(ax, [0 0], [0 0], [0 0], 'r-', ...
            'LineWidth', 1.2, 'Visible', 'off');
    end
end

title(ax, 'Regional Nav Satellite Constellation Simulation', 'Color', 'w');
xlabel(ax, 'X (m)', 'Color', 'w');
ylabel(ax, 'Y (m)', 'Color', 'w');
zlabel(ax, 'Z (m)', 'Color', 'w');
axis(ax, 'equal');
grid(ax, 'on');
set(ax, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');

plotRadius = max(vecnorm(reshape(r_sat, 3, []), 2, 1));
camtarget(ax, [0 0 0]);
campos(ax, 2.8 * plotRadius * viewDir');
camup(ax, [0 0 1]);
camva(ax, 9);

vw = VideoWriter(outputFile, 'MPEG-4');
vw.FrameRate = 7.5;
open(vw);

trailWindow = 12;

% loop for each timestep
for k = 1:Nt
    trailStart = max(1, k - trailWindow);
    trailEnd = min(Nt, k + trailWindow);

    % loop for each sat
    for s = 1:nLeo
        set(leoTrails(s), ...
            'XData', r_sat(1,trailStart:trailEnd,s), ...
            'YData', r_sat(2,trailStart:trailEnd,s), ...
            'ZData', r_sat(3,trailStart:trailEnd,s));
        set(leoMarkers(s), 'XData', r_sat(1,k,s), 'YData', r_sat(2,k,s), 'ZData', r_sat(3,k,s));

        visibleUsers = find(squeeze(visibleSat(k, s, :)) > 0);
        if ~isempty(visibleUsers)
            set(leoMarkers(s), 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);

            for u = 1:nUser
                if any(visibleUsers == u)
                    set(losLines(s, u), ...
                        'XData', [targetPos(1,u) r_sat(1,k,s)], ...
                        'YData', [targetPos(2,u) r_sat(2,k,s)], ...
                        'ZData', [targetPos(3,u) r_sat(3,k,s)], ...
                        'Visible', 'on');
                else
                    set(losLines(s, u), 'Visible', 'off');
                end
            end
        else
            set(leoMarkers(s), 'MarkerFaceColor', [0 0.8 1], 'MarkerEdgeColor', [0 0.8 1]);
            for u = 1:nUser
                set(losLines(s, u), 'Visible', 'off');
            end
        end
    end

    set(geoTrail, ...
        'XData', r_sat(1,trailStart:trailEnd,nSat), ...
        'YData', r_sat(2,trailStart:trailEnd,nSat), ...
        'ZData', r_sat(3,trailStart:trailEnd,nSat));
    set(geoMarker, 'XData', r_sat(1,k,nSat), 'YData', r_sat(2,k,nSat), 'ZData', r_sat(3,k,nSat));
    if any(squeeze(visibleSat(k, nSat, :)) > 0)
        set(geoMarker, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);
    else
        set(geoMarker, 'MarkerFaceColor', [1 0.8 0.2], 'MarkerEdgeColor', [1 0.8 0.2]);
    end

    title(ax, sprintf('3D Constellation at %s', string(tspan(k))), 'Color', 'w');
    drawnow;
    writeVideo(vw, getframe(fig));
end

close(vw);

end
