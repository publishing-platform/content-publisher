import 'cropperjs/dist/cropper.min.js'

function ImageCropper ($module) {
  this.$module = $module
  this.$image = this.$module.querySelector('.app-c-image-cropper__image')
}

ImageCropper.prototype.init = function () {
  // This only runs if the image isn't cached
  this.$image.addEventListener('load', function () {
    this.initCropper()
  }.bind(this))

  // This should only run if the image is cached
  if (this.$image.complete) {
    this.initCropper()
  }
}

ImageCropper.prototype.initCropper = function () {
  if (!this.$image.complete) {
    return
  }

  const $inputX = this.$module.querySelector('.js-image-cropper-x')
  const $inputY = this.$module.querySelector('.js-image-cropper-y')
  const $inputWidth = this.$module.querySelector('.js-image-cropper-width')
  const $inputHeight = this.$module.querySelector('.js-image-cropper-height')

  const width = this.$image.clientWidth
  const height = this.$image.clientHeight
  const naturalWidth = this.$image.naturalWidth
  const naturalHeight = this.$image.naturalHeight
  let scaledRatio = 1
  const minCropWidth = 960
  const minCropHeight = 640

  // Set the crop box limits
  let minCropBoxWidth = minCropWidth
  let minCropBoxHeight = minCropHeight

  // Read existing crop box data
  let cropBoxX = $inputX.value
  let cropBoxY = $inputY.value
  let cropBoxWidth = $inputWidth.value
  let cropBoxHeight = $inputHeight.value

  if (width < naturalWidth || height < naturalHeight) {
    // Determine the scale ratio of the resized image
    scaledRatio = width / naturalWidth

    // Adjust the crop box limits to the scaled image
    minCropBoxWidth = Math.round(minCropBoxWidth * scaledRatio)
    minCropBoxHeight = Math.round(minCropBoxHeight * scaledRatio)

    // Adjust the crop box to the scaled image
    cropBoxX = cropBoxX * scaledRatio
    cropBoxY = cropBoxY * scaledRatio

    cropBoxWidth = cropBoxWidth * scaledRatio
    cropBoxHeight = cropBoxHeight * scaledRatio

    // Ensure the cropbox doesn't exceed the canvas
    if (cropBoxWidth + cropBoxX > width) cropBoxX = width - cropBoxWidth
    if (cropBoxHeight + cropBoxY > height) cropBoxY = height - cropBoxHeight
  }

  if (this.$image) {
    new window.Cropper(this.$image, { // eslint-disable-line
      viewMode: 2,
      aspectRatio: 3 / 2,
      autoCrop: true,
      autoCropArea: 1,
      guides: false,
      zoomable: false,
      highlight: false,
      minCropBoxWidth: minCropBoxWidth,
      minCropBoxHeight: minCropBoxHeight,
      rotatable: false,
      scalable: false,
      data: {
        x: cropBoxX,
        y: cropBoxY,
        width: cropBoxWidth,
        height: cropBoxHeight
      },
      ready: function () {
        // Get canvas data
        const canvasData = this.cropper.getCanvasData()

        // Set crop box data
        this.cropper.setCropBoxData({
          left: cropBoxX + canvasData.left,
          top: cropBoxY + canvasData.top,
          width: cropBoxWidth,
          height: cropBoxHeight
        })
      },
      crop: function () {
        // Get crop data
        const cropData = this.cropper.getData({ rounded: true })

        // Ensure the crop size is not smaller than the minimum values
        if (cropData.width < minCropWidth) {
          cropData.width = minCropWidth
          cropData.x -= minCropWidth - cropData.width
        }
        if (cropData.height < minCropHeight) {
          cropData.height = minCropHeight
          cropData.y -= minCropHeight - cropData.height
        }

        // Set crop data in inputs
        $inputX.value = cropData.x
        $inputY.value = cropData.y
        $inputWidth.value = cropData.width
        $inputHeight.value = cropData.height
      }
    })
  }
}

export default ImageCropper
