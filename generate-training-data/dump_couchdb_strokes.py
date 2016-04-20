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

class NoStrokesError(Exception):
    pass

WIDTH = 16
HEIGHT = 16
def to_matrix(resp, interpolate=True, thicken=True):
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

    # Add in the interpolated points
    strokes = resp['data'] + interpolated_strokes
    points = [p for p in itertools.chain(*strokes)]

    if thicken:
        # Add a point between every other two points within a stroke
        thickened_strokes = []
        # Zip them together but offset by one then trim endpoints
        t_points = map(lambda p: [{'x':p['x']+1, 'y':p['y'], 't':p['t']},
                           {'x':p['x']-1, 'y':p['y'], 't':p['t']},
                           {'x':p['x'], 'y':p['y']+1, 't':p['t']},
                           {'x':p['x'], 'y':p['y']-1, 't':p['t']},
                           {'x':p['x']+1, 'y':p['y']+1, 't':p['t']},
                           {'x':p['x']+1, 'y':p['y']-1, 't':p['t']},
                           {'x':p['x']-1, 'y':p['y']+1, 't':p['t']},
                           {'x':p['x']-1, 'y':p['y']-1, 't':p['t']}],
                points)
        points = [p for p in itertools.chain(*t_points)]
    else:
        pass

    # Sort them by time 
    points = sorted(points,key=lambda x: x['t'])

    # Find the max and min x/y and then scale to that, rounding 
    # to the nearest pixel
    if not points:
        raise NoStrokesError()

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
        px = round(15 * (p['x'] - min_x) / range_x)
        py = round(15 * (p['y'] - min_y) / range_y)
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
    for (idx, l) in enumerate(fhandle):
        if idx % 1000 == 0:
            print("Processing {}...".format(idx))
        dat = json.loads(l)
        resp = requests.get("http://localhost:5984/detexify/{}".format(dat['id'])).json()
        try:
            symbol = to_symbol(resp)
            mtx = to_matrix(resp)
        except Exception as e:
            print(e)
            continue
        else:
            symbols.append(symbol)
            strokes.append(mtx)

    # Convert the symbols into an indicator matrix
    symbol_indicator, lookup = convert_to_indicator(symbols)
    legend_outfile.write(str(lookup))
    for ind, stroke in zip(symbol_indicator, strokes):
        ind_outfile.write(str(ind) + '\n')
        strokes_outfile.write(",".join([str(x) for x in itertools.chain(*stroke)]) + '\n')
    strokes_outfile.close(); ind_outfile.close(); legend_outfile.close()
