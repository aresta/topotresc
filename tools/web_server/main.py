from flask import Flask, render_template, escape, url_for, send_file, send_from_directory, redirect
from PIL import Image
from io import BytesIO
import random
import os
import threading

MAX_ZOOM = 17
TILE_SIZE = 256
BLOCK_SIZE = {
    7:8, 8:8, 9:8, 10:8, 11:8, 12:8, 
    13:16, 14:16,
    15:16, 16:32, 17:32 }
FOLDER_MASK_X = ~(int('11111',2))
FOLDER_MASK_Y = ~(int('1111111',2))
WWW_FOLDER = '../www/'
TILES_FOLDER = "../tiles/"
prefix = "topotresc"
api = "api"

img_cache = {}
img_cache_size = 30
lock = threading.Semaphore()
app = Flask(__name__)

@app.route('/')
def root():
    return redirect( f"/{prefix}/index.html")

# serveix site estatic: www
@app.route( f"/{prefix}/<path:path>")
def static_site(path):
    return send_from_directory( WWW_FOLDER, path)

# serveix tiles: /api/.../xxx.png
@app.route(f"/{api}/<z>/<x>/<y>.png")
def get_tile( x, y, z):
    x = int(x)
    y = int(y)
    z = int(z)
    block_size = BLOCK_SIZE[z]
    block_mask = ~(block_size-1)
    folder_x = x & FOLDER_MASK_X
    folder_y = y & FOLDER_MASK_Y
    file_x = (x & block_mask)
    file_y = (y & block_mask)
    file_path = f"{z}/{folder_x}/{folder_y}/{file_x}_{file_y}.png"

    lock.acquire() # per evitar que varis requests en paralel vagin al disc a per la mateixa imatge
    if file_path in img_cache:
        lock.release()
        img = img_cache[file_path]
    else:
        if os.path.isfile( TILES_FOLDER + file_path):
            print(" + loading from disk", file_path)
            img = Image.open( TILES_FOLDER + file_path)
            while len( img_cache) >= img_cache_size:
                print(" *** Cache full")
                to_remove = random.choice( list( img_cache.keys() ))
                del img_cache[ to_remove ]
            img_cache[file_path] = img.copy()
            lock.release()
        else: 
            lock.release()
            return None
    tile = img.crop((
        (x - file_x) * TILE_SIZE,
        (y - file_y) * TILE_SIZE,
        (x - file_x + 1) * TILE_SIZE,
        (y - file_y + 1) * TILE_SIZE ))
    buf = BytesIO()
    tile.save( buf, format='PNG')
    buf.seek(0)
    return send_file( buf, mimetype='image/png')
