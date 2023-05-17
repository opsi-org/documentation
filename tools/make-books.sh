#!/usr/bin/env bash

# Use and adapt this script only if there are multiple manuals
# Each manual build is based on a book template found in the mandatory directory books.
# This script creates pdf versions of the manual.
# If no manual is in the parameter list, all available manuals are built to pdf.
# If called from the command line, the script user the term "master" (or "main") as branch reference.
# If called from drone, the script uses additional variables (like a branch name).
# The script uses another script to provide the attribute list of the yaml file dynamically.
# Be aware that a manual name MUST NOT contain a blank.

set -e
set -u
set -o noclobber
set -o errexit
set -o pipefail
set -o nounset
IFS=$'\n\t'


LANGUAGE=de
ACTION=
VERSION=
FAILURE_LEVEL=
DEFAULT_VERSION="4.2-$LANGUAGE"
DRY_RUN=false
FONTS_DIRECTORY="fonts"
MANUAL_NAME=
RELEASE_DATE=$(date +'%B %d, %Y')
STYLE="opsi"
STYLES_DIRECTORY="resources/themes"
BUILD_BASE_DIR="build"
AVAILABLE_MANUALS=(manual getting-started releasenotes windows-client-manual linux-client-manual macos-client-manual opsi-script-manual quickinstall opsi-script-reference-card supportmatrix)

ERR_UNSUPPORTED_MANUAL=21
ERR_UNSUPPORTED_ACTION=22

DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
# define path and file of .yml to parse
YMLFILE="$DIR/../antora-playbook.yml"

# yamlparse.sh is a script to get a list of key/value pairs from site.yml which
# will then be used as additional dynamically created argument set for asciidoctor-pdf.
# Else the attributes used can´t be resolved and are printed like {key}

source $DIR/yamlparse.sh

# if we are working local without drone, get the actual branch the pdf build is made for.
# the correct branch name will be printed when the pdf is created.
# check if git is present
if command -v git &> /dev/null; then
    # check if we are on a branch and get the name if we are on one
    if currentbranch=$(git symbolic-ref --short -q HEAD)
    then
        DEFAULT_VERSION=${currentbranch}
    else
        DEFAULT_VERSION='4.2'
    fi
fi

if [[ -z "${VERSION:-}" ]]; then
    if [[ -n "${DRONE_TAG:-}" ]]; then
        VERSION=${DRONE_TAG/v//}
    else
        [[ -n "${DRONE_BRANCH:-}" ]] && VERSION=${DRONE_BRANCH/v//} || VERSION=${DEFAULT_VERSION}
    fi
fi

function usage()
{
    # create a list of modules separated by |
    local list=$(echo ${AVAILABLE_MANUALS[@]} | sed -r 's/[ ]+/|/g')

    echo
    echo "Usage: ./bin/makepdf [-c] [-d] [-h] [-l] [-m] [-n <${list}>]"
    echo
    echo "-h ... help"
    echo "-l ... set language default is de"
    echo "-e ... Set failure level to ERROR (default: FATAL)"
    echo "-c ... clean the build/ directory (contains the pdf)"
    echo "-d ... Debug mode, prints the book to be converted. Only in combination with -m and/or -n"
    echo "-m ... Build all available manuals"
    echo "-n ... Build manual <name>. Only in combination with -m"
    echo
}

function clean_build_dir()
{
    echo "Cleaning build directory..."
    rm -rvf "build/"
    echo "...build directory cleaned."
}

function convert_antora_nav_to_asciidoc_list()
{
    local filename="$1"
    while read line; do

        if [[ ${line} =~ \]$ ]]; then
			# on multi manual repos, the level offset is corrected with 2 (NF-2)
            if [[ $(echo "$line" | awk -F"*" '{print NF}') == 2 ]]; then
                # echo "skip"
                revised_line=$(echo "$line" | sed "s|xref:|include::${2}|" | sed 's/\[.*\]//g' | sed -r 's/^\*{1,} //')
                echo "${revised_line}[leveloffset=+1]"
                echo
            else               
                level_offset=$(echo "$line" | awk -F"*" '{print NF-2}')
                # level_offset=$(echo "$line" | awk -F"*" '{print NF-1}')
                # echo $level_offset
                revised_line=$(echo "$line" | sed "s|xref:|include::${2}|" | sed 's/\[.*\]//g' | sed -r 's/^\*{1,} //')
                echo "${revised_line}[leveloffset=+${level_offset}]"
                # echo "${revised_line}[]"
                echo
            fi
        fi
    done < "${filename}"
}

# function convert_antora_nav_to_asciidoc_list()
# {
#     local filename="$1"
#     while read line; do

#         if [[ ${line} =~ \]$ ]]; then
# 			# on multi manual repos, the level offset is corrected with 2 (NF-2)
#             level_offset=$(echo "$line" | awk -F"*" '{print NF-2}')
#             # level_offset=$(echo "$line" | awk -F"*" '{print NF-1}')
#             # echo $level_offset
#             revised_line=$(echo "$line" | sed "s|xref:|include::${2}|" | sed 's/\[.*\]//g' | sed -r 's/^\*{1,} //')
#             echo "${revised_line}[leveloffset=+${level_offset}]"
#             # echo "${revised_line}[]"
#             echo
#         fi
#     done < "${filename}"
# }


function validate_manual()
{
    # make a comma-separated list of the modules
    local list=$(echo ${AVAILABLE_MANUALS[@]} | sed -r 's/[ ]+/, /g')
    local manual="$1"

    # ok if manual is in the list of possible manuals
    if [[ ${AVAILABLE_MANUALS[@]} =~ (^|[[:space:]])"${manual}"($|[[:space:]]) ]]; then
       return 0
    fi

    echo "[${manual}] is not a valid manual."
    echo "Available manuals are: ${list}."
    return $ERR_UNSUPPORTED_MANUAL
}

function build_html_manual()
{

    local manual="$1"
    local release_date="$2"
    local revision="$3"
    local build_directory=""
    # local manual_infix="$(tr '[:lower:]' '[:upper:]' <<< ${manual:0:1})${manual:1}"
    local manual_infix=$manual
    local out_file=""
    if  [[ ${manual} == "opsi"* ]]; then
        echo "manual string contains 'opsi'"
        build_directory="$(pwd)/${BUILD_BASE_DIR}/html/${LANGUAGE}/${manual}"
        out_file="${build_directory}/${manual_infix}.html"
    else 
        build_directory="$(pwd)/${BUILD_BASE_DIR}/html/${LANGUAGE}/opsi-${manual}"
        out_file="${build_directory}/opsi-${manual_infix}.html"
    fi
    echo "output file: ${out_file}"
    local book_file="books/${manual_infix}-${LANGUAGE}.adoc"
    local nav_file="docs/${LANGUAGE}/modules/${manual}/nav.adoc"
    local module_base_path="docs/${LANGUAGE}/modules/${manual}/pages/"

    echo "Using book file: ${book_file} and nav ${nav_file} to build ${manual} (${LANGUAGE})"

    # Get the dynamic list of attributes from site.yml
    # The output after sed is a string like -a key=value -a key=value ...
    # For testing, also use the yamltest.sh script
    # You can do the same for extensions like kroki if needed (currently not implemented).
    # Be aware, that the tabs.js extension MUST not be used in case (html only)
    local attributes=("$(parse_yaml $YMLFILE | grep asciidoc_attributes | sed 's/asciidoc_attributes_/-a /g' | sed 's/\")/\"/' | sed 's/=(/=/' | sed "s/\"'/\'/" | sed "s/'\"/\'/")")

    if [[ "$DRY_RUN" == true ]]; then
        echo "Manual Generation - **DRY RUN**"
        echo
        echo "${manual} manual would be created with the following content:"
        echo
        cat $book_file <(convert_antora_nav_to_asciidoc_list "$nav_file" "$module_base_path")
        return 0
    fi

    if [[ ! -f $book_file ]]; then
        echo "$book_file not found"
        # exit 0 to not break cicd
        exit 0
    fi

    param=''
    param+='-a encoding=UTF-8 '
    param+='-a doctype=book '
    param+='-a icons=font '
    param+='-a xrefstyle=short '
    param+='-a lang=${LANGUAGE} '
    param+='-a stylesdir=$(pwd)/resources/stylesheets '
    param+='-a stylesheet=opsi.css '
    param+='-a examplesdir='$(pwd)/docs/${LANGUAGE}/modules/${manual}/examples/' '
    param+='-a imagesdir='$(pwd)/docs/${LANGUAGE}/modules/${manual}/assets/images/' '
    # param+='-a imagesdir='/workspaces/opsidoc/assets/images/' '
    param+='-a partialsdir='$(pwd)/docs/${LANGUAGE}/modules/${manual}/pages/partials/' '
    param+='-a revnumber='${revision}' '
    param+='-a revdate="'${release_date}'" '
    param+="$attributes"' '
    param+='--verbose '
    param+='-a toc=left '
    param+='-a toclevels=3 '
    param+='-a source-highlighter=highlightjs '
    # param+='-a highlightjs-theme='$(pwd)/resources/stylesheets/monokai.css' '
    # param+='-a source-highlighter=rouge '
    # param+='-a rouge-style=pastie '
    param+='-r ./tools/IncludeProcessor.rb '
    param+='-r ./tools/ChangeXref.rb '
    # param+='-r asciidoctor-interdoc-reftext '
    param+='--trace '
    param+='--out-file '${out_file}' '
    # param+='--out-file '$(pwd)/${BUILD_BASE_DIR}/${revision}/${manual}/opsi_${manual_infix}.html' '

    pwd

    createhtml="asciidoctor $FAILURE_LEVEL $param - < <(cat $book_file <(convert_antora_nav_to_asciidoc_list "$nav_file" "$module_base_path"))"

    # echo $createhtml
    eval $createhtml
}

function build_pdf_manual()
{
    local manual="$1"
    local release_date="$2"
    local revision="$3"
    local build_directory=""
    local out_file=""
    # local manual_infix="$(tr '[:lower:]' '[:upper:]' <<< ${manual:0:1})${manual:1}"
    local manual_infix=$manual
     if  [[ ${manual} == "opsi"* ]]; then
        echo "manual string contains 'opsi'"
        build_directory="$(pwd)/${BUILD_BASE_DIR}/pdf/${LANGUAGE}/${manual}"
        out_file="${build_directory}/${manual_infix}.pdf"
    else 
        build_directory="$(pwd)/${BUILD_BASE_DIR}/pdf/${LANGUAGE}/opsi-${manual}"
        out_file="${build_directory}/opsi-${manual_infix}.pdf"
    fi
    echo "output file: ${out_file}"
    local book_file="books/${manual_infix}-${LANGUAGE}.adoc"
    local nav_file="docs/${LANGUAGE}/modules/${manual}/nav.adoc"
    local module_base_path="docs/${LANGUAGE}/modules/${manual}/pages/"

    # Get the dynamic list of attributes from site.yml
    # The output after sed is a string like -a key=value -a key=value ...
    # For testing, also use the yamltest.sh script
    # You can do the same for extensions like kroki if needed (currently not implemented).
    # Be aware, that the tabs.js extension MUST not be used in case (html only)
    local attributes=("$(parse_yaml $YMLFILE | grep asciidoc_attributes | sed 's/asciidoc_attributes_/-a /g' | sed 's/\")/\"/' | sed 's/=(/=/' | sed "s/\"'/\'/" | sed "s/'\"/\'/")")

    echo "Using book file: ${book_file} and nav ${nav_file} to build ${manual} (${LANGUAGE})"

    if [[ ! -f $book_file ]]; then
        echo "$book_file not found"
        # exit 0 to not break cicd
        exit 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "Manual Generation - **DRY RUN**"
        echo
        echo "${manual} manual would be created with the following content:"
        echo
        cat $book_file <(convert_antora_nav_to_asciidoc_list "$nav_file" "$module_base_path")
        return 0
    fi

   

    echo "Generating the ${manual} manual from branch '${revision}', dated: ${release_date}"
    mkdir -p "$build_directory"

    # https://docs.asciidoctor.org/asciidoctor.js/latest/cli/options/

    # Create argument list, necessary as we have dynamic attributes coming from another file
    # The param string needs to be properly constructed, please be careful, see comment below.

    param=''
    param+='-d book '
    param+='-a pdf-stylesdir='${STYLES_DIRECTORY}/' '
    param+='-a pdf-fontsdir='${FONTS_DIRECTORY}' '
    param+='-a pdf-style='${STYLE}' '
    param+='-a format="pdf" '
    param+='-a lang=${LANGUAGE} '
    # param+='-a manual=${manual} '
#    param+='-a experimental="" ' #   experimental already set in site.yml
    param+='-a examplesdir='$(pwd)/docs/${LANGUAGE}/modules/${manual}/examples/' '
    param+='-a imagesdir='$(pwd)/docs/${LANGUAGE}/modules/${manual}/assets/images/' '
    param+='-a partialsdir='$(pwd)/docs/${LANGUAGE}/modules/${manual}/pages/partials/' '
    param+='-a revnumber='${revision}' '
    param+='-a revdate="'${release_date}'" '
    param+="$attributes"' '
    param+='--base-dir '$(pwd)' '
    param+='-a allow-uri-read '
    param+='-a toc '
    param+='-a toclevels=3 '
    # param+='-a source-highlighter=~ '
    param+='-a source-highlighter=highlightjs '
    # param+='-a highlightjs-theme='$(pwd)/resources/stylesheets/monokai.css' '
    # param+='-a rouge-style=pastie '
    param+='-r ./tools/IncludeProcessor.rb '
    param+='-r ./tools/ChangeXref.rb '
    # param+='-r asciidoctor-interdoc-reftext '
    param+='--out-file '${out_file}' '
    param+='--trace '
    param+='--verbose '

# please uncomment in case you want/need debugging
#    echo "Parameterlist, useful for debugging"
#    echo $param
#    echo
#    cat $book_file <(convert_antora_nav_to_asciidoc_list "$nav_file")
#    exit

    createpdf="asciidoctor-pdf $FAILURE_LEVEL $param - < <(cat $book_file <(convert_antora_nav_to_asciidoc_list "$nav_file" "$module_base_path"))"
#    createpdf="asciidoctor-pdf $FAILURE_LEVEL $param - < <(cat $book_file)"

    # echo $createpdf
    eval $createpdf



}

function build_manuals()
{
    local actual_manual

    echo ${LANGUAGE}
    echo ${MANUAL_NAME}

    # if no specific manual is named, then build them all
    if [[ -z "${MANUAL_NAME}" ]]; then
        for actual_manual in "${AVAILABLE_MANUALS[@]}"
        do
	       build_pdf_manual ${actual_manual} "$RELEASE_DATE" "$VERSION"
           build_html_manual ${actual_manual} "$RELEASE_DATE" "$VERSION"
        done
    # build the given manual
    else
        validate_manual "$MANUAL_NAME"
        build_pdf_manual "$MANUAL_NAME" "$RELEASE_DATE" "$VERSION"
        build_html_manual "$MANUAL_NAME" "$RELEASE_DATE" "$VERSION"
    fi
}

while getopts ":hecdmn:l::" o
do
    case ${o} in
        d )
            DRY_RUN=true
            ;;
        l )
            LANGUAGE=$OPTARG
            # BUILD_BASE_DIR="build//${LANGUAGE}"
            ;;
        n )
            MANUAL_NAME=$OPTARG
            ;;
        m )
            ACTION="BUILD_MANUALS"
            ;;
        c )
            ACTION="CLEAN"
            ;;
        e )
            FAILURE_LEVEL='--failure-level=ERROR'
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            exit 1
            ;;
        h|* )
            ACTION="HELP"
            ;;
    esac
done
shift $((OPTIND-1))

echo $ACTION

case "$ACTION" in
    BUILD_MANUALS)
        build_manuals
        ;;
    CLEAN)
        clean_build_dir
        ;;
    HELP | *)
        usage
        exit $ERR_UNSUPPORTED_ACTION
        ;;
esac
