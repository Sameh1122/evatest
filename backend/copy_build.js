const fs = require('fs');
const path = require('path');

const src = path.join(__dirname, '../frontend/build/web');
const dest = path.join(__dirname, 'public');

console.log(`Syncing Flutter web build from ${src} to ${dest}...`);

if (!fs.existsSync(src)) {
  console.error('Source directory does not exist:', src);
  process.exit(1);
}

if (fs.existsSync(dest)) {
  fs.rmSync(dest, { recursive: true, force: true });
}

fs.cpSync(src, dest, { recursive: true });

console.log('Successfully synced build files to backend/public!');
