export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/luarocks/bin
bash .ci/setup_lua.sh || exit
eval "$("$HOME/.lua/luarocks" path)"
