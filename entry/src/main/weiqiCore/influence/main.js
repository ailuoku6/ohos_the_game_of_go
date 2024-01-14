// let influence = {}
//
// influence.areaMap = require('./areaMap')
// influence.nearestNeighborMap = require('./nearestNeighborMap')
// influence.radianceMap = require('./radianceMap')
// influence.map = require('./influenceMap')
//
// module.exports = influence

import areaMap from './areaMap';
import nearestNeighborMap from './nearestNeighborMap';
import radianceMap from './radianceMap';
import map from './influenceMap';

export {areaMap,nearestNeighborMap,radianceMap,map}
