import os

__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

f = open(os.path.join(__location__, 'turret.txt'), 'r')

array = []
Running = True
while Running:
    line = f.readline()
    if(line == ''):
        Running = False
    line = line.split(' , ')
    for pixel in line:
        if(pixel == '0'):
            array.append(15)
        if(pixel == '1'):
            array.append(14)

f.close()
print(array)
