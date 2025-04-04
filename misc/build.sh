BOON=~/Downloads/boon-macos-amd64/boon
NODE=~/Downloads/node-v20.12.2-darwin-x64/bin/node
LOVEJS_INDEX=~/Downloads/lovejs-11/node_modules/love.js/index.js

TARGET=${1:-all}

${BOON} build . --target ${TARGET}

# Web
rm -rf release/Game-Name-web
${NODE} ${LOVEJS_INDEX} -c -t "Game Name" -m 64000000 "release/Game Name.love" release/Game-Name-web
cp misc/web_index.html release/Game-Name-web/index.html
# Patch for filesystem access
sed -i '' 's/var SYSCALLS/try{if(!window.FS)window.FS=FS;}catch(e){}var SYSCALLS/' release/Game-Name-web/love.js
rm -rf release/Game-Name-web/theme
