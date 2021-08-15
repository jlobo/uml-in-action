#!/bin/bash
set -e 

TYPES="-tpng -tsvg -teps -tpdf -tvdx -txmi -tscxml -thtml -ttxt -tutxt -tlatex -tbraille -teps:text -tlatex:nopreamble"
normilize() {
    RMV=$(readlink -f $1) && echo ${RMV#$PWD/}
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -k|--keep) KEEP=1 && [[ -d "$2" ]] && REMOVE=$(normilize $2) && shift;;
        -h|--help) HELP=1;;
        -o|--output)
            [[ -z "$2" ]] && echo "Path is needed" && exit 1
            [[ ! -d "$2" ]] && echo "Folder not found '$2'" && exit 1
            
            OUTPUT=$(normilize $2); shift;;
        *)

        [ $(echo "$TYPES" | grep -owe "$1") ] && TYPE="$1" && shift && continue

        if [[ ! $1 = -* ]]; then
            [[ ! -f "$1" ]] && echo "File not found '$1'" && exit 1
            
            FILES="$FILES$(normilize $1)|" && shift && continue
        fi

        echo -e "Unknown parameter passed: $1 \nType -h or --help for more information."; exit 1;;
    esac
    shift
done

if [ ! -z "$HELP" ]; then
    echo "Convert the template diagram to the specified image"
    echo "Syntax: [-k|--keep] [-o|--output <dir>] [-h|--help] <files>"
    echo
    echo "options:"
    echo "-k|--keep <dir>     Keeps the structure of the folder"
    echo "-o|--output <dir>   Generate images in the specified directory"
    echo "-tpng               To generate images using PNG format (default)"
    echo "-tsvg               To generate images using SVG format"
    echo "-teps               To generate images using EPS format"
    echo "-tpdf               To generate images using PDF format"
    echo "-tvdx               To generate images using VDX format"
    echo "-txmi               To generate XMI file for class diagram"
    echo "-tscxml             To generate SCXML file for state diagram"
    echo "-thtml              To generate HTML file for class diagram"
    echo "-ttxt               To generate images with ASCII art"
    echo "-tutxt              To generate images with ASCII art using Unicode characters"
    echo "-tlatex             To generate images using LaTeX/Tikz format"
    echo "-tlatex:nopreamble  To generate images using LaTeX/Tikz format without preamble"
    echo
    exit 0
fi 

[[ -z "$FILES" ]] && FILES=$(git diff --name-only HEAD^ HEAD | grep .puml | tr '\n' '|')
FILES=${FILES%|}
[[ -z "$FILES" ]] && echo "There are no files to process" && exit 0

echo "HELP:    $HELP"
echo "TYPE:    $TYPE"
echo "OUTPUT:  $OUTPUT"
echo "KEEP:    $KEEP"
echo "REMOVE:  $REMOVE"
echo "FILES:   $FILES"

if [[ $KEEP ]]; then
    TMP=$(printf "$FILES" | xargs -n 1 -d '|' | sed "s/$REMOVE\///1" | tr '\n' '|' | sed 's/|$//')
    FILES=$(printf "$TMP" | xargs -n 1 -d '|' -I _ echo "$OUTPUT/"_ | tr '\n' '|' | sed 's/|$//')
    
    printf "$TMP" | xargs -n 1 -d '|' -I _ dirname "$OUTPUT/"_ | uniq | xargs mkdir -p -v
    printf "$TMP" | xargs -n 1 -d '|' -I _ cp "$REMOVE/"_ "$OUTPUT/"_ -v
fi
printf "FILESv2: $FILES \n\n"

DIAGRAMS=$(java -jar plantuml.jar -v "$TYPE" $([[ ! $KEEP && ! -z $OUTPUT ]] && echo "-o '$OUTPUT'") "${FILES//|/ }" 2>&1 \
    | grep -i "creating file:" | cut -d " " -f 10- | awk '{print}' ORS='%0A' | sed 's/%0A$//')

[[ $KEEP ]] && printf "$FILES" | xargs -n 1 -d '|' rm -v

echo "::set-output name=diagrams::$DIAGRAMS"
exit 0