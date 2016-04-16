import itertools
import json
import sys

import requests

def convert_to_indicator(li):
    uniq = sorted(set(li))
    lookup = dict([(y,x+1) for x,y in enumerate(uniq)])
    ind = [lookup[x] for x in li]
    return ind, lookup

def to_symbol(resp):
    return resp['id'].replace("latex2e-OT1-_","")

WIDTH = 100
HEIGHT = 100
def to_matrix(resp, interpolate=True):
    # Initialize the final matrix
    mtx = [[1 for x in range(WIDTH)] for y in range(HEIGHT)]
    if interpolate:
        # Add a point between every other two points within a stroke
        interpolated_strokes = []
        for stroke in resp['data']:
            # Zip them together but offset by one then trim endpoints
            temp = [t for t in zip(stroke, [0] + stroke)]
            temp = temp[1:len(temp)-1]
            s = map(lambda s: {'x': (s[0]['x'] + s[1]['x']) / 2,
                               'y': (s[0]['y'] + s[1]['y']) / 2,
                               't': (s[0]['t'] + s[1]['t']) / 2},
                    temp)
            interpolated_strokes.append(s)
    else:
        interpolated_strokes = []

    strokes = resp['data'] + interpolated_strokes
    # Join the different strokes
    points = [p for p in itertools.chain(*strokes)]
    # Sort them by time 
    points = sorted(points,key=lambda x: x['t'])
    # Find the max and min x/y and then scale to that, rounding 
    # to the nearest pixel
    p = points[0]
    min_x = p['x']
    max_x = p['x']
    min_y = p['y']
    max_y = p['y']
    for p in points[1:]:
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
    for p in points:
        px = round(99 * (p['x'] - min_x) / range_x)
        py = round(99 * (p['y'] - min_y) / range_y)
        mtx[px][py] = 0

    # Collapse into one big vector
    return mtx

if __name__ == '__main__':

    if len(sys.argv) != 2:
        sys.exit(1)

    in_filename = sys.argv[1]
    output_prefix = in_filename.replace('.json','')
    strokes_outfile = open(output_prefix + '.mtx', 'w')
    ind_outfile = open(output_prefix + '.ind', 'w')
    legend_outfile = open(output_prefix + '.legend', 'w')

    fhandle = open(in_filename, "r")

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
