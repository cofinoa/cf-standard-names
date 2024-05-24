#!/usr/bin/env bash
# BEGIN
# dir where git files will be exported/checkout
PREFIX_LOCAL=docs/local/
# output dir and file wher index and htmels files will be created
OUTDIR=docs/raw.githubusercontent.com/
mkdir -p ${OUTDIR}
OUTFILE=${OUTDIR}index.html
# create images dir and copy them
printf "Copying images ...\n"
if [ -d "${OUTDIR}$DIR" ]; then
  printf "  already exist (skip)\n"
else
  mkdir -p ${OUTDIR}/build/media/
  cp -r images ${OUTDIR}/build/media/
fi


# PROLOGUE
printf ''                                                  > ${OUTFILE}
printf '<!DOCTYPE html>\n<html lang="en">\n<head>\n'      >> ${OUTFILE}
printf '<title>CF Standard Names</title>\n'               >> ${OUTFILE}
printf '</head>\n<body>\n'                                >> ${OUTFILE}
printf '<h1>CF Standard Names</h1>\n<dl>\n'               >> ${OUTFILE}
 
#https://cdn.githubraw.com/cofinoa/cf-standard-names/78/cf_standard_names/build/cf-standard-name-table.html
test_print_file () {
  if [ -f "${PREFIX_LOCAL}${DIR}/${FILE}" ]; then
    printf "      <a href="${URL}">${TEXT}</a> &nbsp;\n" >> ${OUTFILE}
  else
    printf "      ${TEXT} &nbsp;\n"                      >> ${OUTFILE}
  fi
}

test_print_file_javascript () {
  if [ -f "${PREFIX_LOCAL}${DIR}/${FILE}" ]; then
    printf "      <a href="cf-standard-names/${URL}">${TEXT}</a> &nbsp;\n" >> ${OUTFILE}
    TABLEDIR=${OUTDIR}cf-standard-names/${DIR}
    TABLEFILE=${TABLEDIR}/${FILE}
    mkdir -p ${TABLEDIR}
    printf "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <title>CF Standard Name Table</title>\n    <script>\n" >  ${TABLEFILE}
    printf "      VERSION = \"${TAG}\"\n      FILE = \"${FILE}\"\n"                                                 >> ${TABLEFILE}
    printf "    </script>\n    <script defer src=\"../../remoteload.js\">\n    </script>\n"                            >> ${TABLEFILE}
    printf "  </head>\n  <body onload=\"loadTable(VERSION, FILE)\">\n  </body>\n</html>"                            >> ${TABLEFILE}
  else
    printf "      ${TEXT} &nbsp;\n"                      >> ${OUTFILE}
  fi
}

print_all_files () {
  FILE=cf-standard-name-table.xml
  TEXT=XML
  URL="https://raw.githubusercontent.com/cofinoa/cf-standard-names/${TAG}/cf_standard_names/src/${FILE}"
  #URL="https://cdn.githubraw.com/cofinoa/cf-standard-names/${TAG}/cf_standard_names/src/${FILE}"
  #URL=${DIR}/${FILE}
  test_print_file
  
  FILE=cf-standard-name-table.html
  TEXT=HTML
  #URL="https://raw.githubusercontent.com/cofinoa/cf-standard-names/${TAG}/cf_standard_names/build/${FILE}"
  #URL="https://cdn.githubraw.com/cofinoa/cf-standard-names/${TAG}/cf_standard_names/build/${FILE}"
  URL=${DIR}/${FILE}
  #test_print_file
  test_print_file_javascript

  FILE=kwic_index_for_cf_standard_names.html
  TEXT=KWIC
  #URL="https://raw.githubusercontent.com/cofinoa/cf-standard-names/${TAG}/cf_standard_names/build/${FILE}"
  #URL="https://cdn.githubraw.com/cofinoa/cf-standard-names/${TAG}/cf_standard_names/build/${FILE}"
  URL=${DIR}/${FILE}
  #test_print_file
  test_print_file_javascript
}

process_tag(){
  printf "Processing ${TITLE} ...\n"
  if [ -d "${PREFIX_LOCAL}$DIR" ]; then
    printf "  already exist (skip)\n"
  else
    mkdir -p ${PREFIX_LOCAL}${DIR}
    git archive --format=tar ${TAG} | tar -x --strip-components=2 --directory=${PREFIX_LOCAL}${DIR} --exclude cf_standard_names/build/media cf_standard_names/src/cf-standard-name-table.xml cf_standard_names/build
  fi

  printf "  <dt><h2>${TITLE}</h2></dt>\n" >> ${OUTFILE}
  printf "    <dd>\n" >> ${OUTFILE}
  print_all_files
  printf "    </dd>\n" >> ${OUTFILE}
}  

# LATEST
TAG=$(git describe --tags --abbrev=0 master)
DIR=latest
TITLE="latest (v${TAG})"
process_tag

# ALL VERSIONS
for TAG in $(git tag --sort -v:refname)
do
  DIR=${TAG}
  TITLE="v${TAG}"
  process_tag
done

# EPILOGUE
printf "</dl>\n</body>\n</html>" >> ${OUTFILE}
printf "DONE\n"
#END
