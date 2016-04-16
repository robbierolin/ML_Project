import requests
import json
import itertools

def convert_to_indicator(li):
    uniq = sorted(set(li))
    lookup = dict([(y,x+1) for x,y in enumerate(uniq)])
    ind = [lookup[x] for x in li]
    return ind, lookup

def to_symbol(resp):
    return resp['id'].replace("latex2e-OT1-_","")

WIDTH = 100
HEIGHT = 100
def to_matrix(resp):
    mtx = [[1 for x in range(WIDTH)] for y in range(HEIGHT)]
    # Join the different strokes
    points = itertools.chain(*resp['data'])
    # Find the max and min x/y and then scale to that, rounding 
    # to the nearest pixel
    p = next(points)
    min_x = p['x']
    max_x = p['x']
    min_y = p['y']
    max_y = p['y']
    for p in points:
        if p['x'] < min_x:
            min_x = p['x']
        elif p['x'] > max_x:
            max_x = p['x']
        if p['y'] < min_y:
            min_y = p['y']
        elif p['y'] > max_y:
            max_y = p['y']

    range_x = max_x - min_x
    range_y = max_y - min_y
    # Put the points into a matrix
    points = itertools.chain(*resp['data'])
    for p in points:
        px = round(99 * (p['x'] - min_x) / range_x)
        py = round(99 * (p['y'] - min_y) / range_y)
        mtx[px][py] = 0

    # Collapse into one big vector
    return mtx

if __name__ == '__main__':
    strokes_outfile = open("strokes.mtx", "w")
    ind_outfile = open("strokes.ind", "w")
    legend_outfile = open("strokes.legend", "w")

    fhandle = open("sample.json", "r")
    symbols = []
    strokes = []
    for l in fhandle:
        dat = json.loads(l)
        resp = requests.get("http://localhost:5984/detexify/{}".format(dat['id'])).json()
        symbols.append(to_symbol(resp))
        strokes.append(to_matrix(resp))

    # Convert the symbols into an indicator matrix
    symbol_indicator, lookup = convert_to_indicator(symbols)
    legend_outfile.write(str(lookup))
    for ind, stroke in zip(symbol_indicator, strokes):
        ind_outfile.write(str(ind) + '\n')
        strokes_outfile.write(",".join([str(x) for x in itertools.chain(*stroke)]) + '\n')

    strokes_outfile.close(); ind_outfile.close(); legend_outfile.close()
