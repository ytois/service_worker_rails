class Api::ApiController < ApplicationController
  protect_from_forgery with: :null_session

  def subscribe
    subscription = Subscription.find_by(endpoint: params[:endpoint])
    subscription = Subscription.new unless subscription.present?
    subscription.attributes = {
      endpoint: params[:endpoint],
      key: params[:key],
      auth: params[:auth],
    }
    session[:fire_base_endpoint] = params[:endpoint]
    if subscription.save
      render text: 'subscribe success'
    else
      render text: 'subscribe failed', status: 500
    end
  end

  def push_message
    if session[:fire_base_endpoint]
      subscription = Subscription.find_by(endpoint: session[:fire_base_endpoint])
      res = Webpush.payload_send(
        endpoint: subscription.endpoint,
        message:  JSON.generate({title: params[:title], body: params[:body], data: {url: params[:url]}}),
        auth:     subscription.auth,
        p256dh:   subscription.key,
        api_key:  Rails.application.secrets.firebase[:api_key],
      )
    end
    render text: res
  rescue Webpush::InvalidSubscription => e
    # 送信失敗したらDBから削除する
    subscription.destroy
    render text: 'destroy subscription'
  end
end
