const fs = require('fs');
const path = require('path');

const filesToPatch = [
  'node_modules/youtubei.js/bundle/node.cjs',
  'node_modules/youtubei.js/bundle/node.js',
  'node_modules/youtubei.js/bundle/browser.cjs',
  'node_modules/youtubei.js/bundle/browser.js',
];

let replaced = 0;

for (const file of filesToPatch) {
  const filePath = path.join(__dirname, file);
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Replace Emoji regex
    const emojiRegex = '/^(?:\\p{Emoji}|\\u200d)+$/u';
    if (content.includes(emojiRegex)) {
        content = content.split(emojiRegex).join('/^.+$/');
        replaced++;
    }
    
    // Replace text filter regex
    const textRegex = '/[^\\p{L}\\p{N}\\p{P}\\p{Z}]/gu';
    if (content.includes(textRegex)) {
        content = content.split(textRegex).join('/[^\\\\w\\\\s.,!?]/g');
        replaced++;
    }

    fs.writeFileSync(filePath, content, 'utf8');
  }
}

console.log(`Patched youtubei.js to remove unsupported unicode property escapes. Replacements made: ${replaced}`);
