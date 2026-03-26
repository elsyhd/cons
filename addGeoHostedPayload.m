function r_all = addGeoHostedPayload(r_sat, tspan, lonGeo)

if nargin < 3
    lonGeo = deg2rad(113); %assume N5
end

% constant
Re = 6378e3;
hGeo = 35786e3;
rGeo = Re + hGeo;

Nt = length(tspan);
nSat = size(r_sat, 3);
r_all = zeros(3, Nt, nSat + 1);

r_all(:,:,1:nSat) = r_sat;

% GEO is stationary in ECEF
r_geo = [rGeo*cos(lonGeo);
         rGeo*sin(lonGeo);
         0];

for k = 1:Nt
    r_all(:,k,nSat + 1) = r_geo;
end

end
