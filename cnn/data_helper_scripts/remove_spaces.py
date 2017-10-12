import PIL
import sys
import glob
import errno
import re
import os

from PIL import Image

print ("Remove spaces...")

final_width = 110
final_height = 110

path = './SquaredImages/TrainingMWOneSecond90/Testing/*.png'
pathW = './SquaredImages/TrainingMWOneSecond90/Testing/'
#pathF = './Training/Testing\\'

files = glob.glob(path)  

p = re.compile('[WRB]_.+.png')
p1 = re.compile('\s') 

for name in sorted(files): # 'file' is a builtin type, 'name' is a less
  #print(name)
  strName = p.findall(name).pop()
  match = p1.search(strName)
  if match:
    for m in re.finditer(p1,strName):
      str_name = strName[0:m.start()] + '_flip.png'
    
    im = Image.open(pathW + strName)
    im.save(pathW + str_name, quality=100)
    os.remove(pathW + strName)
  
print ("Done.")

