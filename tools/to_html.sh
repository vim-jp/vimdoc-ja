to_html_setup() {
  echo "TODO: to_html_setup"
}

to_html_teardown() {
  echo "TODO: to_html_teardown"
}

to_html_dir() {
  srcdir=$1 ; shift
  dstdir=$1 ; shift
  ext=$1 ; shift
  for i in "${srcdir}/"*.${ext} ; do
    dst="${i##*/}"
    dst="${dst%.*}.html"
    to_html_file "$i" "${dstdir}/${dst}"
  done
}

to_html_file() {
  src=$1 ; shift
  dst=$1 ; shift
  echo "convert: ${src} -> ${dst}"
  #vim -e -s -u "tools/to_html.vim" -c "call ToJekyllHTML('${src}', '${dst}')" -c "silent! visual" -c qall!
}
