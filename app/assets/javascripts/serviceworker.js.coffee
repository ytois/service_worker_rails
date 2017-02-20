CACHE_VERSION = 'v1'
CACHE_NAME = CACHE_VERSION + ':sw-cache-'

onInstall = (event) ->
  console.log('[Serviceworker]', "Installing!", event)

onActivate = (event) ->
  console.log '[Serviceworker]', 'Activating!', event
  event.waitUntil caches.keys().then((cacheNames) ->
    Promise.all cacheNames.filter((cacheName) ->
      # Return true if you want to remove this cache,
      # but remember that caches are shared across
      # the whole origin
      cacheName.indexOf(CACHE_VERSION) != 0
    ).map((cacheName) ->
      caches.delete cacheName
    )
  )

onFetch = (event) ->
  console.log '[Serviceworker]', 'Fetching offline content', event

# プッシュ通知受信時
onPush = (event) ->
  console.log '[Serviceworker]', 'Push!', event
  if event.data?
    title = event.data.json().title
    data = event.data.json()
    message = event.data.json()
  else
    title = 'default title'
    message = { body: 'default body' }
  event.waitUntil self.registration.showNotification(title, message)

# 通知クリック時の挙動
onNotificationClick = (event) ->
  console.log 'On notification click: ', event.notification.tag
  event.notification.close()

  event.waitUntil(
    if event.notification.data?
      url = event.notification.data.url
    else
      url = '/'
    clients.openWindow(url)
    # clients.matchAll(type: 'window')
    #   .then( (clientList) ->
    #     i = 0
    #     while i < clientList.length
    #       client = clientList[i]
    #       if client.url == '/' and 'focus' of client
    #         client.focus()
    #       i++
    #     if clients.openWindow
    #       clients.openWindow('/')
    #   )
  )

self.addEventListener('install', onInstall)
self.addEventListener('activate', onActivate)
# self.addEventListener('fetch', onFetch)
self.addEventListener('push', onPush)
self.addEventListener('notificationclick', onNotificationClick)
