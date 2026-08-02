const fs = require('fs');
const path = require('path');

const targetDir = path.join(__dirname, 'node_modules/youtubei.js');

let replaced = 0;

function walkDir(dir) {
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      walkDir(fullPath);
    } else if (fullPath.endsWith('.js') || fullPath.endsWith('.cjs') || fullPath.endsWith('.mjs')) {
      patchFile(fullPath);
    }
  }
}

function patchFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;
    
    // Replace Emoji regex (various formats due to escaping)
    // Sometimes it's /^(?:\p{Emoji}|\u200d)+$/u
    // Sometimes it's new RegExp("^(?:\\p{Emoji}|\\u200d)+$", "u")
    const emojiRegex1 = '/^(?:\\\\p{Emoji}|\\\\u200d)+$/u';
    const emojiRegex2 = '/^(?:\\p{Emoji}|\\u200d)+$/u';
    if (content.includes(emojiRegex1)) {
        content = content.split(emojiRegex1).join('/^.+$/');
        changed = true;
    }
    if (content.includes(emojiRegex2)) {
        content = content.split(emojiRegex2).join('/^.+$/');
        changed = true;
    }
    
    const textRegex1 = '/[^\\\\p{L}\\\\p{N}\\\\p{P}\\\\p{Z}]/gu';
    const textRegex2 = '/[^\\p{L}\\p{N}\\p{P}\\p{Z}]/gu';
    if (content.includes(textRegex1)) {
        content = content.split(textRegex1).join('/[^\\\\w\\\\s.,!?]/g');
        changed = true;
    }
    if (content.includes(textRegex2)) {
        content = content.split(textRegex2).join('/[^\\\\w\\\\s.,!?]/g');
        changed = true;
    }

    if (changed) {
        fs.writeFileSync(filePath, content, 'utf8');
        replaced++;
    }
}

walkDir(targetDir);

console.log(`Patched youtubei.js recursively to remove unsupported unicode property escapes. Files patched: ${replaced}`);
