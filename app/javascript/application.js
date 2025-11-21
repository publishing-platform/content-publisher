// Entry point for the build script in your package.json
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import UrlPreview from './components/url-preview'
import CopyToClipboard from './components/copy-to-clipboard'
import ImageCropper from './components/image-cropper'

const $urlPreview = document.querySelector('[data-module="url-preview"]')
if ($urlPreview) {
  new UrlPreview($urlPreview).init()
}

const $copyToClipboard = document.querySelector('[data-module="copy-to-clipboard"]')
if ($copyToClipboard) {
  new CopyToClipboard($copyToClipboard).init()
}

const $imageCropper = document.querySelector('[data-module="image-cropper"]')
if ($imageCropper) {
  new ImageCropper($imageCropper).init()
}
