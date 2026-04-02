function [A, Ctot, r_all] = simulateConstellation()

% set start time
startTime = datetime(2026, 4, 2, 0, 0, 0, 'TimeZone', 'UTC');
tspan = startTime + minutes(0:5:24*60);

% set variation parameters
h = 1500e3;
i = deg2rad(20);
%P = 4;
%RAAN = 2*pi*(0:P-1)/P;
RAAN = deg2rad([0.042 90 180 269.791]);
nSat = 24;
f = 0;

% users = [ ...
%     deg2rad(5.5),    deg2rad(95.3),   0;
%     deg2rad(-2.5),   deg2rad(140.7),  0;
%     deg2rad(1.67),   deg2rad(125.0),  0;
%     deg2rad(-10.0),  deg2rad(120.5),  0;
%     deg2rad(-7.5),   deg2rad(107.5),  0];
% 
% siteNames = { ...
%     'Banda Aceh', ...
%     'Jayapura', ...
%     'Minahasa Utara', ...
%     'Sumba Timur', ...
%     'Garut'};

users = [ ...
    deg2rad(0.5),    deg2rad(123.017),   0;
    deg2rad(-2.541),   deg2rad(140.737),  0;
    deg2rad(-8.504),   deg2rad(117.429),  0;
    deg2rad(5.5),  deg2rad(95.3),  0;
    deg2rad(-6.9),   deg2rad(108),  0];

siteNames = { ...
    'Gorontalp', ...
    'Jayapura', ...
    'Sumbawa', ...
    'Banda Aceh', ...
    'Garut'};

% propagate each satellites
r_leo = orbitProp(h, i, RAAN, nSat, tspan, f);
geoLat = deg2rad(0);
geoLon = deg2rad(113);
r_all = addGeoHostedPayload(r_leo, tspan, geoLat, geoLon);

% check availability
[A, visibleSat, meanVisibleAll, maxVisiblePerTarget] = satAvailability(r_all, users);
[~, meanGDOP] = satGDOP(r_all, users, visibleSat);

% check cost
Ctot = satCost(r_all, 1);

globalMeanAvailability = mean(A);
globalMeanVisible = mean(meanVisibleAll);
globalMeanGDOP = mean(meanGDOP(~isnan(meanGDOP)));

for idx = 1:numel(siteNames)
    fprintf('%s Availability = %.3f\n', siteNames{idx}, A(idx));
    fprintf('%s Mean Visible = %.2f\n', siteNames{idx}, meanVisibleAll(idx));
    fprintf('%s Max Visible            = %d\n', siteNames{idx}, maxVisiblePerTarget(idx));
    fprintf('%s Mean GDOP              = %.2f\n', siteNames{idx}, meanGDOP(idx));
end
fprintf('Global Mean Availability = %.3f\n', globalMeanAvailability);
fprintf('Global Mean Visible      = %.2f\n', globalMeanVisible);
fprintf('Global Mean GDOP         = %.2f\n', globalMeanGDOP);
fprintf('Total Cost   = USD %.2f\n', Ctot);

plotConstellation3DVideo(r_all, visibleSat, users, siteNames, tspan, 'constellation_simulation.mp4');
end
