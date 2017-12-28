#!/usr/bin/env node
const util = require("util");
const fs = require('fs');

const print = x => JSON.stringify(x, undefined, 2).split('\n').forEach(x => console.log(x));

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
const line_num = x.region.start.line;
const filename = x.file;
console.error(filename);
const lines = fs.readFileSync(filename).toString().split('\n');
switch (x.tag) {
    case "missing type annotation":
        const annotation = x.details.split('\n')[2];
        lines.forEach((line, i) => {
            // console.log(i + ":" + line);
            if (i + 1 === line_num) {
                console.log(annotation);
            }
            console.log(line);
        });
        return;
    case "unused import":
        lines.forEach((line, i) => {
            if (i + 1 !== line_num) {
                console.log(line);
            }
        });
        return;
    default:
        console.error('unknown data:', x);
        return process.exit(1);
}
