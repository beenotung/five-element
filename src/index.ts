let { max, min, floor, random } = Math

let R = 0
let G = 1
let B = 2
let A = 3

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
  let r = floor(random() * 256)
  let g = floor(random() * 256)
  let b = floor(random() * 256)
  imageData.data[i + R] = r
  imageData.data[i + G] = g
  imageData.data[i + B] = b
  context.putImageData(imageData, 0, 0)
}
requestAnimationFrame(draw)
