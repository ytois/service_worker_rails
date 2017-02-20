if navigator.serviceWorker?
  navigator.serviceWorker.register('/serviceworker.js', { scope: './' })
    .then (reg) ->
      console.log('[Companion]', 'Service worker registered!')

# Push通知を有効にする
pushSubscribe = ->
  navigator.serviceWorker.getRegistration()
    .then (registration) ->
      registration.pushManager
        .subscribe({userVisibleOnly: true})
        .then (subscription) ->
          data = {
            endpoint: subscription.endpoint
            key: btoa(String.fromCharCode.apply(
              null
              new Uint8Array(subscription.getKey('p256dh'))
            )).replace(/\+/g, '-').replace(/\//g, '_')
            auth: btoa(String.fromCharCode.apply(
              null,
              new Uint8Array(subscription.getKey('auth'))
            )).replace(/\+/g, '-').replace(/\//g, '_')
          }
          sendSubscription(data)
          $('#endpoint').val(data.endpoint)
          $('#key').val(data.key)
          $('#auth').val(data.auth)
        .catch (err) ->
          console.log err

# Push通知を無効にする
unSubscribe = ->
  navigator.serviceWorker.getRegistration()
    .then (registration) ->
      registration.pushManager.getSubscription()
        .then (subscription) ->
          subscription.unsubscribe()
            .then (success) ->
              console.log 'unsubscribe success!'
            .catch (error) ->
              console.log error

# サーバーへユーザーの情報を登録する
sendSubscription = (data) ->
  $.ajax(
    type: 'POST'
    url: '/api/subscribe'
    data: data
    success: ->
      console.log 'subscribe success!'
    dataType: 'json'
  )

pushSend = (message) ->
  $.ajax(
    type: 'POST'
    url: '/api/push_message'
    data: message
    success: ->
      console.log 'success!'
    dataType: 'json'
  )

$(document).ready ->
  $('#push-setting').on 'click', ->
    pushSubscribe()
  $('#push-unsubscribe').on 'click', ->
    unSubscribe()
  $('#push-send').on 'click', ->
    message = {
      title: $('#push-title').val()
      body: $('#push-message').val()
      url: $('#push-url').val()
    }
    pushSend(message)

notificationPermission = ->
  Notification.permission
