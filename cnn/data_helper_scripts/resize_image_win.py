import PIL
import sys
import glob
import errno
import re

from PIL import Image

print ("Resizing...")

final_width = 110
final_height = 110

path = '.\\*.png'
pathF = '.\\'
pathW = pathF

files = glob.glob(path)  

p = re.compile('[WRB]_.+.png')
 
for name in sorted(files): # 'file' is a builtin type, 'name' is a less
  strName = p.findall(name).pop()
  print(strName)  
  #strName = strName[1:]
  im = Image.open(pathF + strName)
  imaged = im.resize((final_width, final_height), Image.ANTIALIAS)
  imaged.save(pathW + strName, quality=100)
  
print (pathF)
print ("Done.")

