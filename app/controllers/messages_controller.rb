class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:reply]

  def reply
    message_body = params["Body"].split.first
    from_number = params["From"]

    AccessCode.create(body: message_body)

    render plain: "OK"
  end
end
