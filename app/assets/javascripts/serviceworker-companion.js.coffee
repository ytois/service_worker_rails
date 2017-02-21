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

# Push設定のトグルを有効にする
pushToggleActivate = ->
  $('#push-toggle-wrapper').show() # 一旦デフォルトで表示

  # Chrome, Firefox以外はメッセージ表示
  ua = navigator.userAgent.toLowerCase()
  if (ua.indexOf("chrome") or ua.indexOf("firefox")) < 0
    $('#alert-browser').show()

  navigator.serviceWorker.getRegistration()
    .then (registration) ->
      # SWがインストール済みの場合、トグルボタンを表示する
      if registration?
        $('#push-toggle-wrapper').show()

        # 通知が許可、またはデフォルトの場合はアクティブにする
        unless Notification.permission == "denied"
          $('#push-toggle').attr("disabled", false)
        else
          $('#alert-notification-setting').show()

        # Subscriptionが登録されている場合はトグルボタンをONにする
        registration.pushManager.getSubscription()
          .then (subscription) ->
            if (subscription?) and ($('#push-toggle').prop("checked") is false)
              $('#push-toggle').prop("checked", true)

$(document).ready ->
  pushToggleActivate()

  $('#push-toggle').on 'change', ->
    if $(this).prop('checked')
      pushSubscribe()
    else
      unSubscribe()
  $('#push-send').on 'click', ->
    message = {
      title: $('#push-title').val()
      body: $('#push-message').val()
      url: $('#push-url').val()
    }
    pushSend(message)

