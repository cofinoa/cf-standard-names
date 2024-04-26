#!/usr/bin/env bash
# BEGIN
PREFIX=doc/
mkdir -p ${PREFIX}
OUTFILE=${PREFIX}index.html
# create images dir and copy them
printf "Copying images ...\n"
if [ -d "${PREFIX}$DIR" ]; then
  printf "  already exist (skip)\n"
else
  mkdir -p ${PREFIX}/build/media/
  cp -r images ${PREFIX}/build/media/
fi


# PROLOGUE
printf ''                                                  > ${OUTFILE}
printf '<!DOCTYPE html>\n<html lang="en">\n<head>\n'      >> ${OUTFILE}
printf '<title>CF Standard Names</title>\n'               >> ${OUTFILE}
printf '</head>\n<body>\n'                                >> ${OUTFILE}
printf '<h1>CF Standard Names</h1>\n<dl>\n'               >> ${OUTFILE}
 
test_print_file () {
  if [ -f "${PREFIX}$FILE" ]; then
    printf "      <a href="${FILE}">${TEXT}</a> &nbsp;\n" >> ${OUTFILE}
  else
    printf "      ${TEXT} &nbsp;\n"                       >> ${OUTFILE}
  fi
}

print_all_files () {
  FILE=${DIR}/cf-standard-name-table.xml
  TEXT=XML
  test_print_file
  FILE=${DIR}/cf-standard-name-table.html
  TEXT=HTML
  test_print_file
  FILE=${DIR}/kwic_index_for_cf_standard_names.html
  TEXT=KWIC
  test_print_file
}

process_tag(){
  printf "Processing ${TITLE} ...\n"
  if [ -d "${PREFIX}$DIR" ]; then
    printf "  already exist (skip)\n"
  else
    mkdir -p ${PREFIX}${DIR}
    git archive --format=tar ${TAG} | tar -x --strip-components=2 --directory=${PREFIX}${DIR} --exclude cf_standard_names/build/media cf_standard_names/src/cf-standard-name-table.xml cf_standard_names/build
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
