export const getNeighbors = ([x, y]) => [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]

export const getChain = function(data, v, result = [], done = {}, sign = null) {
    if (sign == null) sign = data[v[1]][v[0]]
    let neighbors = getNeighbors(v)

    result.push(v)
    done[v] = true

    for (let n of neighbors) {
        if (!data[n[1]] || data[n[1]][n[0]] !== sign || n in done)
            continue

        getChain(data, n, result, done, sign)
    }

    return result
}

export const average = function(arr, defaultValue = null) {
    if (arr.length !== 0) {
        return arr.reduce((sum, x) => sum + x, 0) / arr.length
    }

    return defaultValue
}
