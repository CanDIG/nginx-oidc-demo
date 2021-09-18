#!/usr/bin/env bash
# download, install and setup nginx and party
# this script uses template https://betterdev.blog/minimal-safe-bash-script-template
# for better bashing
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT


script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

tempdir="${script_dir}/../.tmp"

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-c]

Setup NGINX with lua-openresty.

System requirements -
- linux OS, preferably Debian based
- regular dev tools like gcc etc. (in ubuntu they are software-properties-common  build-essential)
- lua - latest
- luarocks - latest
- libreadline-devel
- LuaJIT - https://luajit.org/install.html
- pcre and pcre-devel
- zlib and zlib-devel

environment variables requirements
- export LUA_LIB=/usr/local/lib/lua/<VERSION>     <-- your lua version here
- export LUA_INC=/usr/local/include
- export LUAJIT_LIB=/usr/local/lib
- export LUAJIT_INC=/usr/local/include/luajit-2.0

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-c, --clean     Explicitly call cleanup local to this script
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

clean_explicit() {
  rm -rf $tempdir
  rm -rf $HOME/.luarocks
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -c | --clean) clean_explicit
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  return 0
}

parse_params "$@"
setup_colors

# script logic begins
mkdir -p $tempdir

downloads=( "http://nginx.org/download/nginx-1.21.3.tar.gz"
            "https://www.openssl.org/source/openssl-1.1.1l.tar.gz"
            "https://github.com/openresty/lua-nginx-module/archive/refs/tags/v0.10.20.tar.gz"
            "https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.1.tar.gz"
            "https://github.com/facebookarchive/luaffifb/archive/master.tar.gz" )

# download all the things
for artifact in "${downloads[@]}"
do
  wget -P $tempdir $artifact
done

# uncompress all the things
for compressed_file in $tempdir/*
do
  echo "Uncompressing ${compressed_file}..."
  tar -zxf $compressed_file -C $tempdir
done

# install stuff
# install luaffifb
cd $tempdir/luaffifb-master
luarocks make --local
cd ../../

# install luarocks modules
$(which luarocks) install lua-cjson --local
$(which luarocks) install lua-resty-openidc --local

# install NGINX
cd $tempdir/nginx-1.21.3
./configure --prefix=/opt/nginx --with-http_ssl_module --with-ld-opt="-Wl,-rpath,/usr/local/lib/lua/5.4/" \
  --add-module=${tempdir}/ngx_devel_kit-0.3.1 \
  --add-module=${tempdir}/lua-nginx-module-0.10.20 \
  --with-openssl=${tempdir}/openssl-1.1.1l
make -j2
sudo make install