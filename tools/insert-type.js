#!/usr/bin/env node
const fs = require('fs');
const stdin = fs.readFileSync(0);
const o = JSON.parse(stdin.toString());
if (!Array.isArray(o)) {
    console.error('unknown input:', o);
    return process.exit(1);
}
if (o.length < 1) {
    console.error('Error: empty array. Expect at least one element.');
    return process.exit(1);
}
const x = o[0];
if (x.tag !== 'missing type annotation') {
    console.error('unknown data:', x);
    return process.exit(1);
}
const annotation = x.details.split('\n')[2];
const line_num = x.region.start.line;
const filename = x.file;
const lines = fs.readFileSync(filename).toString().split('\n');
console.error(filename);
lines.forEach((line, i) => {
    // console.log(i + ":" + line);
    if (i + 1 === line_num) {
        console.log(annotation);
    }
    console.log(line);
});
