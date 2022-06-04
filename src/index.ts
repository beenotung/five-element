let { max, min, floor, random } = Math

let R = 0
let G = 1
let B = 2
let A = 3

let WATER = 1
let FIRE = 2
let WOOD = 3
let GOLD = 4
let SOIL = 5

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
let PIXEL = 10

let imageData: ImageData

function resize() {
  let rect = canvas.getBoundingClientRect()
  w = floor(rect.width / PIXEL)
  h = floor(rect.height / PIXEL)
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

function draw() {
  requestAnimationFrame(draw)
  let x = floor(random() * w)
  let y = floor(random() * h)
  let i = (y * w + x) * 4
  let e = floor(random() * 5) + 1
  let r = rs[e]
  let g = gs[e]
  let b = bs[e]
  imageData.data[i + R] = r
  imageData.data[i + G] = g
  imageData.data[i + B] = b
  context.putImageData(imageData, 0, 0)
}
requestAnimationFrame(draw)
