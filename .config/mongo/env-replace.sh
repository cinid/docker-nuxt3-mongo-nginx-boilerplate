#!/bin/bash

# Environment variable replace string
replaceString="s|\$MONGO_HOST|$MONGO_HOST|g; s|\$MONGO_PORT|$MONGO_PORT|g; s|\$MONGO_ROOT_DIR|$MONGO_ROOT_DIR|g; s|\$MONGO_LOG_DIR|$MONGO_LOG_DIR|g; s|\$MONGO_ROOT_USERNAME|$MONGO_ROOT_USERNAME|g; s|\$MONGO_ROOT_PASSWORD|$MONGO_ROOT_PASSWORD|g"

inputFiles=()
outputFiles=()
argIsInput=0
argIsOutput=0
argDeleteInput=0
argDeleteOutput=0
# Read arguments into inputFiles and outPutFiles arrays
while [ $# -gt 0 ]
do
    case $1 in
        -i|--input)
            argIsInput=1
            argIsOutput=0
            ;;
        -o|--output)
            argIsInput=0
            argIsOutput=1
            ;;
        -di|--delete-input)
            argDeleteInput=1
            ;;
        -do|--delete-output)
            argDeleteOutput=1
            ;;
        *)
            if [ ${argIsInput} -gt 0 ]
            then
                inputFiles+=("${1}")
            elif [ ${argIsOutput} -gt 0 ]
            then
                outputFiles+=("${1}")
            fi
            ;;
    esac
    shift
done

# Get min occurence of inputFiles to outputFiles
inputFilesLength=${#inputFiles[@]}
outputFilesLength=${#outputFiles[@]}
minLength=$(( ${inputFilesLength} < ${outputFilesLength} ? ${inputFilesLength} : ${outputFilesLength} ))
for ((i=0; $i<$minLength; i++))
do
    inputFile="${inputFiles[$i]}"
    outputFile="${outputFiles[$i]}"

    # Replace if input file exists
    if [[ -f ${inputFile}  ]]
    then
        # Copy if output file does not exist
        if [[ ! -f ${outputFile} ]]
        then
            # Copy file incl. permission to data directory
            cp -p ${inputFile} ${outputFile}
        fi
        # Substitute variables in mongo configuration inplace
        cat ${inputFile} | sed -i "${replaceString}" ${outputFile}

        # Delete input file for security reasons
        if [ ${argDeleteInput} -gt 0 ]
        then
            rm -f ${inputFile}
        fi

        # Delete output file for security reasons
        if [ ${argDeleteOutput} -gt 0 ]
        then
            rm -f ${outputFile}
        fi
    fi
done
