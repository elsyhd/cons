function [A, Ctot, r_all] = simulateConstellation()

% set start time
startTime = datetime(2026, 3, 21, 0, 0, 0, 'TimeZone', 'UTC');
tspan = startTime + minutes(0:5:24*60);

% set variation parameters
h = 800e3;
i = deg2rad([10 10 15 15 20 20 25 25]);
RAAN = deg2rad(linspace(0, 300, 8));
nSat = 50;

users = [ ...
    deg2rad(5.5),    deg2rad(95.3),   0;
    deg2rad(-2.5),   deg2rad(140.7),  0;
    deg2rad(1.67),   deg2rad(125.0),  0;
    deg2rad(-10.0),  deg2rad(120.5),  0;
    deg2rad(-7.5),   deg2rad(107.5),  0];

siteNames = { ...
    'Banda Aceh', ...
    'Jayapura', ...
    'Minahasa Utara', ...
    'Sumba Timur', ...
    'Garut'};

% propagate each satellites
r_leo = orbitProp(h, i, RAAN, nSat, tspan);
geoLat = deg2rad(0);
geoLon = deg2rad(113);
r_all = addGeoHostedPayload(r_leo, tspan, geoLat, geoLon);

% check availability
[A, visibleSat, meanVisibleAll, maxVisiblePerTarget] = satAvailability(r_all, users);
[gdop, meanGDOP] = satGDOP(r_all, users, visibleSat);

% check cost
Ctot = satCost(r_all, 1);

for idx = 1:numel(siteNames)
    fprintf('%s Availability = %.3f\n', siteNames{idx}, A(idx));
    fprintf('%s Mean Visible (overall) = %.2f\n', siteNames{idx}, meanVisibleAll(idx));
    fprintf('%s Max Visible            = %d\n', siteNames{idx}, maxVisiblePerTarget(idx));
    fprintf('%s Mean GDOP              = %.2f\n', siteNames{idx}, meanGDOP(idx));
end
fprintf('Total Cost   = %.2f\n', Ctot);

plotConstellation3DVideo(r_all, visibleSat, users, siteNames, tspan, 'constellation_simulation.mp4');
end
