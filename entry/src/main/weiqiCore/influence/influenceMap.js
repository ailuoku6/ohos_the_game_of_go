// const areaMap = require('./areaMap')
// const nearestNeighborMap = require('./nearestNeighborMap')
// const radianceMap = require('./radianceMap')
// const {getNeighbors, average} = require('./helper')

import areaMap from './areaMap';
import nearestNeighborMap from './nearestNeighborMap';
import radianceMap from './radianceMap';
import {getNeighbors,average} from './helper';

const influenceMap = function(data, {discrete = false, maxDistance = 6, minRadiance = 2} = {}) {
    let height = data.length
    let width = height === 0 ? 0 : data[0].length
    let areamap = areaMap(data)
    let map = areamap.map(row => [...row])
    let pnnmap = nearestNeighborMap(data, 1)
    let nnnmap = nearestNeighborMap(data, -1)
    let prmap = radianceMap(data, 1)
    let nrmap = radianceMap(data, -1)
    let max = -Infinity
    let min = Infinity

    for (let x = 0; x < width; x++) {
        for (let y = 0; y < height; y++) {
            if (map[y][x] !== 0) continue

            let s = Math.sign(nnnmap[y][x] - pnnmap[y][x])
            let faraway = s === 0 || (s > 0 ? pnnmap : nnnmap)[y][x] > maxDistance
            let dim = s === 0 || Math.round((s > 0 ? prmap : nrmap)[y][x]) < minRadiance

            if (faraway || dim) map[y][x] = 0
            else map[y][x] = s * (s > 0 ? prmap[y][x] : nrmap[y][x])

            max = Math.max(max, map[y][x])
            min = Math.min(min, map[y][x])

            if (discrete) map[y][x] = Math.sign(map[y][x])
        }
    }

    // Postprocessing

    for (let x = 0; x < width; x++) {
        for (let y = 0; y < height; y++) {
            if (areamap[y][x] !== 0) continue

            let sign = Math.sign(map[y][x])

            let neighbors = getNeighbors([x, y])
                .filter(([i, j]) => data[j] && data[j][i] != null)
            let friendlyNeighbors = sign === 0 ? null : neighbors
                .filter(([i, j]) => Math.sign(map[j][i]) === sign)

            // Prevent single point areas

            if (sign !== 0) {
                if (
                    neighbors.length >= 2
                    && neighbors.every(([i, j]) => Math.sign(map[j][i]) !== sign)
                ) {
                    map[y][x] = 0
                    continue
                }
            }

            // Fix ragged areas

            if (sign !== 0) {
                if (friendlyNeighbors.length === 1) {
                    let [i, j] = friendlyNeighbors[0]

                    if (data[j][i] === sign) {
                        map[y][x] = 0
                        continue
                    }
                }
            }

            // Fix empty pillars

            let distance = Math.min(x, y, width - x - 1, height - y - 1)

            if (distance <= 2 && sign !== 0) {
                let signedNeighbors = neighbors
                    .filter(([i, j]) => map[j] && map[j][i] !== 0)

                if (signedNeighbors.length >= 2) {
                    let [[i1, j1], [i2, j2]] = signedNeighbors
                    let s = Math.sign(map[j1][i1])

                    if (
                        (signedNeighbors.length >= 3 || i1 === i2 || j1 === j2)
                        && signedNeighbors.every(([i, j]) => Math.sign(map[j][i]) === s)
                    ) {
                        map[y][x] = !discrete
                            ? average(signedNeighbors.map(([i, j]) => map[j][i]))
                            : s
                        sign = s
                    }
                }
            }

            // Blur

            if (!discrete && sign !== 0) {
                map[y][x] = average([[x, y], ...friendlyNeighbors].map(([i, j]) => map[j][i]))
            }
        }
    }

    for (let x = 0; x < width; x++) {
        for (let y = 0; y < height; y++) {
            if (areamap[y][x] !== 0 || map[y][x] === 0) continue

            let sign = Math.sign(map[y][x])

            // Normalize

            if (!discrete) {
                if (sign > 0) {
                    map[y][x] = Math.min(map[y][x] / max, 1)
                } else if (sign < 0) {
                    map[y][x] = Math.max(-map[y][x] / min, -1)
                }
            }
        }
    }

    return areaMap(map)
}

export default influenceMap;