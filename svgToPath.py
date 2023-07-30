# This progrma is repsonsible for converting the svg file to a colleciton of coordinates from 0,0, to 1000, 1000


# convert the format of number,number to number number
inputFile = open("pseudoPath.txt", "r")
outputFile = open("path.txt", "w")

for line in inputFile:
    line = line.replace(",", " ")
    # flip the y axis
    data = line.split()
    data[1] = str(500 - float(data[1]))
    outputFile.write(data[0] + " " + data[1] + "\n")

inputFile.close()
outputFile.close()