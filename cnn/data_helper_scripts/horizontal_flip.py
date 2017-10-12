import PIL
import sys
import glob
import errno
import re
import numpy as np
import scipy.misc

from PIL import Image

print "Horizontal and vertical flips..."


path = '/home/pav/Desktop/Link to Thesis/Matlab Code/main/output/mw/monochrome/test_set/*.png'
pathW = '/home/pav/Desktop/Link to Thesis/Matlab Code/main/output/mw/monochrome/h_flip/'
pathF = '/home/pav/Desktop/Link to Thesis/Matlab Code/main/output/mw/monochrome/test_set/'

files = glob.glob(path)  

p = re.compile('/[WR]_.+.png')

for name in sorted(files):
  strName = p.findall(name).pop()
  strName = strName[1:]
  im = Image.open(pathF + strName)
  A = np.asarray(im)
  about_y = np.fliplr(A)
  about_x = np.flipud(A)
  scipy.misc.imsave(pathW + 'hor_' + strName, about_y )
  scipy.misc.imsave(pathW + 'ver_' + strName, about_x )

print "Done."
