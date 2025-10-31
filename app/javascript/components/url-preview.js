function UrlPreview ($module) {
  this.$module = $module
  this.urlPreview = this.$module.querySelector('.js-url-preview-url')
  this.basePath = this.$module.querySelector('.js-url-preview-path')
  this.defaultMessage = this.$module.querySelector('.js-url-preview-default-message')
  this.errorMessage = this.$module.querySelector('.js-url-preview-error-message')
  this.path = this.$module.getAttribute('data-url-preview-path')
  this.input = document.querySelector('[data-url-preview="input"]')
  this.hideClass = 'visually-hidden'
}

UrlPreview.prototype.init = function () {
  this.input.addEventListener('blur', this.handleBlur.bind(this))
}

UrlPreview.prototype.showErrorMessage = function () {
  this.urlPreview.classList.add(this.hideClass)
  this.defaultMessage.classList.add(this.hideClass)
  this.errorMessage.classList.remove(this.hideClass)
}

UrlPreview.prototype.showNoTitleMessage = function () {
  this.urlPreview.classList.add(this.hideClass)
  this.defaultMessage.classList.remove(this.hideClass)
  this.errorMessage.classList.add(this.hideClass)
}

UrlPreview.prototype.showPathPreview = function (path) {
  this.urlPreview.classList.remove(this.hideClass)
  this.defaultMessage.classList.add(this.hideClass)
  this.errorMessage.classList.add(this.hideClass)
  this.basePath.innerHTML = path
}

UrlPreview.prototype.fetchPathPreview = function (path, input) {
  const url = new URL(document.location.origin + path)
  url.searchParams.append('title', input.value)

  const controller = new window.AbortController()
  const options = { credentials: 'include', signal: controller.signal }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options)
    .then(function (response) {
      if (!response.ok) {
        throw Error('Unable to generate response.')
      }

      return response.text()
    })
}

UrlPreview.prototype.handleBlur = function (event) {
  const input = event.target

  if (!input.value) {
    this.showNoTitleMessage()
    return
  }

  this.fetchPathPreview(this.path, this.input)
    .then(this.showPathPreview.bind(this))
    .catch(this.showErrorMessage.bind(this))
}

export default UrlPreview
