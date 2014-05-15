#!/bin/bash
inputDir=$1
outputDir=$2

data=($(ls $inputDir|grep '.avi'))
lengthData=$(ls -l $inputDir|grep '.avi'|wc -l)
lengthData=$(echo $lengthData -1|bc)

for i in $(eval echo "{0..$lengthData}"); do
    echo ${data[i]:0:-4}
    HandBrakeCLI -i $inputDir/${data[i]:0:-4}.avi -o $outputDir/${data[i]:0:-4}.mp4
done
