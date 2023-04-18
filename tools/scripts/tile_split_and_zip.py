import sys
from PIL import Image
from io import BytesIO
from zipfile import ZipFile
from urllib.parse import unquote_plus

def parse_file_name( file_name ):
    file_name_parts = file_name.split('.')
    if file_name_parts[1] != 'png':
        raise Exception("ERROR: unexpected file extension", file_name_parts[1])
    file_name_parts = file_name_parts[0].split('/')
    zoom = file_name_parts[0]
    if not zoom.isdigit():
        raise Exception("ERROR: unexpected path structure extension", file_name)
    zoom = int(zoom)
    if zoom < 7 or zoom > 17:
        raise Exception("ERROR: unexpected path structure extension", file_name)
    coords = file_name_parts[-1]
    coords = coords.split('_')
    tile_x = coords[0]
    tile_y = coords[1]
    if not tile_x.isdigit() or not tile_y.isdigit():
        raise Exception("ERROR: unexpected file name", coords)
    return int(tile_x), int(tile_y), zoom
 
ZIP_TILE_SIZE = 8
TILE_SIZE = 256
FOLDER_DEST = 'tilezips'

if __name__ == '__main__':
    file_name = sys.argv[1]
    tile_x, tile_y, zoom = parse_file_name( file_name )   
    img = Image.open( file_name )
    size_x, size_y = img.size
    print("size_x, size_y", size_x, size_y)
    block_size = size_x // TILE_SIZE

    print("Start:", file_name)
    folder_mask_x = ~(int('11111',2))    # '...11111110000' mask to convert tile coord to folder names
    folder_mask_y = ~(int('1111111',2))  # y folders contain zips that already contain 8x8 tiles each
    
    image_bf = BytesIO()
    for zx in range( int(block_size/ZIP_TILE_SIZE)):
        base_x = zx * ZIP_TILE_SIZE
        for zy in range( int(block_size/ZIP_TILE_SIZE)):
            base_y = zy * ZIP_TILE_SIZE
            zip_folder = "%s_%d_%d_%d" % (FOLDER_DEST, zoom, (tile_x + base_x) & folder_mask_x , (tile_y + base_y) & folder_mask_y)
            zip_name = "%s_%d_%d.zip" % ( zip_folder, tile_x + base_x ,tile_y + base_y )
            zip_bf = BytesIO()
            with ZipFile( zip_bf, 'w') as zip:
                for tx in range( ZIP_TILE_SIZE ):
                    i = base_x + tx
                    for ty in range( ZIP_TILE_SIZE ):
                        j = base_y + ty
                        image_bf.seek(0)  # reset the buffer
                        image_bf.truncate(0)
                        img.crop(( i*TILE_SIZE, j*TILE_SIZE, (i+1)*TILE_SIZE, (j+1)*TILE_SIZE )).\
                            convert('RGB').convert('P', palette=Image.ADAPTIVE).\
                            save( image_bf, format="PNG", optimize=True)
                        zip.writestr("%d_%d.png" % ( tile_x + i, tile_y + j ), image_bf.getvalue())
            zip_bf.seek(0)
            with open( zip_name, "wb") as f:
                f.write( zip_bf.getbuffer())
            print("Processed:", zip_name)

    print("Done!")
