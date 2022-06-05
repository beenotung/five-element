let { sign, sqrt, max, min, floor, random } = Math

let R = 0
let G = 1
let B = 2
let A = 3

let WATER = 1
let FIRE = 2
let WOOD = 3
let GOLD = 4
let SOIL = 5

let grows = new Array(5).fill(0)
let attacks = new Array(5).fill(0)

grows[WATER] = WOOD
grows[WOOD] = FIRE
grows[FIRE] = SOIL
grows[SOIL] = GOLD
grows[GOLD] = WATER

attacks[WATER] = FIRE
attacks[FIRE] = GOLD
attacks[GOLD] = WOOD
attacks[WOOD] = SOIL
attacks[SOIL] = WATER

let rs: number[] = []
let gs: number[] = []
let bs: number[] = []

rs[0] = 190
gs[0] = 190
bs[0] = 190

rs[WATER] = 0
gs[WATER] = 0
bs[WATER] = 0

rs[FIRE] = 255
gs[FIRE] = 63
bs[FIRE] = 0

rs[WOOD] = 0
gs[WOOD] = 255
bs[WOOD] = 255

rs[GOLD] = 255
gs[GOLD] = 255
bs[GOLD] = 255

rs[SOIL] = 255
gs[SOIL] = 190
bs[SOIL] = 0

function findElement<E extends HTMLElement>(selector: string): E {
  let e = document.querySelector<E>(selector)
  if (!e) throw new Error('Could not find element, selector: ' + selector)
  return e
}

let canvas = findElement<HTMLCanvasElement>('canvas#world')
let context = canvas.getContext('2d')!
if (!context) throw new Error('2d context not available')

let w = 10
let h = 10
let n = w * h
let PIXEL = 10

let imageData: ImageData

let elementXs: number[] = []
let elementYs: number[] = []
let elements: number[] = []
let elementCount = 0

let forces: number[][] = []
for (let e = 1; e <= 5; e++) {
  forces[e] = []
}

function resize() {
  let rect = canvas.getBoundingClientRect()
  let oldW = w
  let oldH = h
  w = floor(rect.width / PIXEL)
  h = floor(rect.height / PIXEL)
  n = w * h
  for (let i = 0; i < elementCount; i++) {
    elementXs[i] = floor((elementXs[i] / oldW) * w)
    elementYs[i] = floor((elementYs[i] / oldH) * h)
  }
  for (let e = 1; e <= 5; e++) {
    forces[e].length = n
    forces[e].fill(0)
  }
  canvas.width = w
  canvas.height = h
  imageData = context.getImageData(0, 0, w, h)
  for (let i = 0; i < imageData.data.length; i += 4) {
    imageData.data[i + R] = rs[0]
    imageData.data[i + G] = gs[0]
    imageData.data[i + B] = bs[0]
    imageData.data[i + A] = 255
  }
}
window.addEventListener('resize', resize)
resize()

function place(x: number, y: number, e: number) {
  elementCount++
  elementXs.push(x)
  elementYs.push(y)
  elements.push(e)
  let i = (y * w + x) * 4
  let r = rs[e]
  let g = gs[e]
  let b = bs[e]
  imageData.data[i + R] = r
  imageData.data[i + G] = g
  imageData.data[i + B] = b
}

let isMouseDown = false
window.addEventListener('mousedown', event => {
  isMouseDown = true
  let x = floor(event.clientX / PIXEL)
  let y = floor(event.clientY / PIXEL)
  let e = floor(random() * 5) + 1
  place(x, y, e)
})
window.addEventListener('mousemove', event => {
  if (!isMouseDown) return
  let x = floor(event.clientX / PIXEL)
  let y = floor(event.clientY / PIXEL)
  let e = floor(random() * 5) + 1
  place(x, y, e)
})
window.addEventListener('mouseup', event => {
  isMouseDown = false
})

let OverCorrectionFactor = (1 + sqrt(5)) / 2

let ForceFactor = 1

let batch = 100_000

function initForceField() {
  for (let idx = 0; idx < elementCount; idx++) {
    let x = elementXs[idx]
    let y = elementYs[idx]
    let e = elements[idx]
    let i = floor(y) * w + floor(x)
    forces[grows[e]][i] = 1
    forces[attacks[e]][i] = -1
    forces[e][i] = 0.5
  }
}

function calcForceField() {
  for (let b = 0; b < batch; b++) {
    let e = floor(random() * 5) + 1
    let y = floor(random() * h)
    let x = floor(random() * w)
    let i = y * w + x
    let value = forces[e][i]
    if (value === 1 || value === -1) {
      continue
    }
    let sum = 0
    ;[
      [y - 1, x],
      [y + 1, x],
      [y, x - 1],
      [y, x + 1],
    ].forEach(([y, x]) => {
      y = y === -1 ? 1 : y === h ? h - 1 : y
      x = x === -1 ? 1 : x === w ? w - 1 : x
      let i = y * w + x
      sum += forces[e][i]
    })
    let avg = sum / 4.0
    let correction = avg - value
    forces[e][i] += correction * OverCorrectionFactor
  }
}

function drawForceField() {
  if (mode === 0) {
    imageData.data.fill(0)
  } else {
    let force = forces[mode]
    for (let i = 0; i < n; i++) {
      let c = floor((force[i] / 2 + 0.5) * 256)
      let offset = i * 4
      imageData.data[offset + R] = c
      imageData.data[offset + G] = c
      imageData.data[offset + B] = c
      imageData.data[offset + A] = 255
    }
  }
}

function moveElementInForceField() {
  for (let idx = 0; idx < elementCount; idx++) {
    let e = elements[idx]
    let y = elementYs[idx]
    let x = elementXs[idx]
    let i = floor(y) * w + floor(x)
    let upI = y - 1 < 0 ? i + w : i - w
    let leftI = x - 1 < 0 ? i + 1 : i - 1
    let dy = forces[e][i] - forces[e][upI]
    let dx = forces[e][i] - forces[e][leftI]
    x += dx * ForceFactor
    x = x < 0 ? -x : x >= w ? (w << 1) - x : x
    y += dy * ForceFactor
    y = y < 0 ? -y : y >= h ? (h << 1) - y : y
    elementXs[idx] = x
    elementYs[idx] = y
    i = (floor(y) * w + floor(x)) * 4
    imageData.data[i + R] = rs[e]
    imageData.data[i + G] = gs[e]
    imageData.data[i + B] = bs[e]
    imageData.data[i + A] = 255
  }
}

function draw() {
  initForceField()
  calcForceField()
  drawForceField()
  moveElementInForceField()
  context.putImageData(imageData, 0, 0)
  requestAnimationFrame(draw)
}
requestAnimationFrame(draw)

let mode = 0
window.addEventListener('keypress', event => {
  switch (event.key) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
      mode = +event.key
    default:
      break
  }
})
