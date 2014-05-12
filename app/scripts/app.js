(function() {
  console.log('hoodie ❤')

  var defer = $.Deferred()
  var cache = window.applicationCache
  cache.addEventListener('updateready', defer.resolve)

  if (cache.status === cache.UPDATEREADY) {
    defer.resolve()
  }

  defer.promise().then(function() {
    console.log('Application Cache Reloading')
    window.location.reload()
  })
})()
