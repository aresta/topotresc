import struct
import math
import io

MAX_ZOOM = 17
METATILE = 8
TILES_FOLDER = "../tiles/default/"

def get_tile( x, y, z):
    x = int(x)
    y = int(y)
    z = int(z)
    offset = xyz_to_meta_offset( x, y, z)
    file_url = xyz_to_meta( x, y, z)
    print( file_url, offset)
    image = get_tile_image( file_url, offset)
    return image

def xyz_to_meta( x, y, z):
    mask = METATILE -1
    x &= ~mask
    y &= ~mask
    hashes = {}
    for i in range(0,5):
        hashes[i] = ((x & 0x0f) << 4) | (y & 0x0f)
        x >>= 4
        y >>= 4
    meta = "%d/%u/%u/%u/%u/%u.meta" % ( z, hashes[4], hashes[3], hashes[2], hashes[1], hashes[0])
    return meta

def xyz_to_meta_offset( x, y, z):
    mask = METATILE -1
    offset = (x & mask) * METATILE + (y & mask)
    return offset

def get_tile_image( file_url, offset_index):
    file = open( TILES_FOLDER + file_url, 'rb')
    data = file.read()
    ntiles, x, y, z = struct.unpack('4I', data[4:20])
    offset_table = data[ 20 : 20+ntiles*2*4 ]
    offset_table = struct.unpack("%iI"%(ntiles*2), offset_table)
    offset, size = offset_table[offset_index*2], offset_table[offset_index*2+1]
    image = data[offset:offset+size]
    return image

if __name__ == "__main__":
    # https://topotresc.com/osm_tiles/15/16570/12209.png
    image = get_tile( 16570, 12209, 15) # St Llorenç
    tile_file = open("tile.png", "wb")
    tile_file.write( bytes(image))

    