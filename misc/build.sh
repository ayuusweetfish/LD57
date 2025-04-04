BOON=~/Downloads/boon-macos-amd64/boon
NODE=~/Downloads/node-v20.12.2-darwin-x64/bin/node
LOVEJS_INDEX=~/Downloads/lovejs-11/node_modules/love.js/index.js

${BOON} build . --target love

# Web
rm -rf release/Game-Name-web
${NODE} ${LOVEJS_INDEX} -c -t "Game Name" -m 64000000 "release/Game Name.love" release/Game-Name-web
cp misc/web_index.html release/Game-Name-web/index.html
rm -rf release/Game-Name-web/theme

# (cd release/*-web; python3 -m http.server)
