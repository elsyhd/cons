function [gdop, meanGDOP] = satGDOP(r_sat, users, visibleSat)

% constant
Re = 6378e3;

Nt = size(r_sat, 2);
nUser = size(users, 1);

gdop = nan(Nt, nUser);
meanGDOP = nan(nUser, 1);

% loop for each user/ target point
for u = 1:nUser
    lat = users(u, 1);
    lon = users(u, 2);
    h = users(u, 3);

    % Geo -> ECEF
    xu = (Re + h)*cos(lat)*cos(lon);
    yu = (Re + h)*cos(lat)*sin(lon);
    zu = (Re + h)*sin(lat);
    ru = [xu; yu; zu];

    % loop for each timestep
    for k = 1:Nt
        visIdx = find(squeeze(visibleSat(k, :, u)) > 0);

        if numel(visIdx) < 4
            continue;
        end

        H = zeros(numel(visIdx), 4);

        % build the linearized pseudorange geometry matrix
        for j = 1:numel(visIdx)
            s = visIdx(j);
            rhoVec = r_sat(:, k, s) - ru;
            rho = norm(rhoVec);

            if rho <= 0
                continue;
            end

            los = rhoVec / rho;
            H(j, :) = [los.', 1];
        end

        normalMatrix = H.' * H;
        if rcond(normalMatrix) < 1e-12
            continue;
        end

        Q = inv(normalMatrix);
        gdop(k, u) = sqrt(trace(Q));
    end

    validIdx = ~isnan(gdop(:, u));
    if any(validIdx)
        meanGDOP(u) = mean(gdop(validIdx, u));
    end
end

end
