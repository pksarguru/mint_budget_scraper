class MessagesController < ApplicationController
  def reply
    message_body = params["Body"].split
    from_number = params["From"]
    boot_twilio

    browser = new_browser
    browser.goto("https://mint.intuit.com/planning.event")

    browser.input(name: "Email").to_subtype.clear
    browser.input(name: "Password").to_subtype.clear

    browser.input(name: "Email").send_keys(ENV.fetch("USERNAME"))
    browser.input(name: "Password").send_keys(ENV.fetch("PW"))
    browser.button(name: "SignIn").click

    browser.wait_until {
      browser.a(id: "add-budget").present? ||
      browser.text.include?("Let's make sure it's you")
    }

    if browser.text.include?("Let's make sure it's you")
      puts "triggered the if conditional"

      browser.button(text: "Continue").click

      binding.pry
    else
      a = browser.spans

      array = a.select { |span| span.class_name == "amount" && !span.text.blank?}

      array.each { |num| puts num.text }

      spent = array[2].text.to_f

      budget = array[3].text.delete(",").to_f

      p "*****************"
      puts spent/budget

      current_day = Date.today.day
      days_in_month = Date.today.end_of_month.day

      month_progress = current_day.to_f/days_in_month.to_f

      budget_target = month_progress * budget

      budget_status = budget_target - spent

      if budget_status > 0
        send_status_text("You're under target budget by #{budget_status}")
      else
        send_status_text("You're over target budget by #{budget_status}")
      end
    end
  end

  private

  def boot_twilio
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    @client = Twilio::REST::Client.new account_sid, auth_token
  end

  def send_status_text(message)
    client = Twilio::REST::Client.new

    client.api.account.messages.create(
      from: ENV.fetch("TWILIO_PHONE_NUMBER"),
      to: ENV.fetch("SHILPY_PHONE_NUMBER"),
      body: message
    )
  end

  def send_sign_in_text
    client = Twilio::REST::Client.new

    client.api.account.messages.create(
      from: ENV.fetch("TWILIO_PHONE_NUMBER"),
      to: ENV.fetch("PAVAN_PHONE_NUMBER"),
      body: "Reply with sign in code"
    )
  end

  def new_browser
    options = Selenium::WebDriver::Chrome::Options.new

    # make a directory for chrome if it doesn't already exist
    chrome_dir = File.join Dir.pwd, %w(tmp chrome)
    FileUtils.mkdir_p chrome_dir
    user_data_dir = "--user-data-dir=#{chrome_dir}"
    # add the option for user-data-dir
    options.add_argument user_data_dir

    # let Selenium know where to look for chrome if we have a hint from
    # heroku. chromedriver-helper & chrome seem to work out of the box on osx,
    # but not on heroku.
    if chrome_bin = ENV["GOOGLE_CHROME_BIN"]
      options.add_argument "no-sandbox"
      options.binary = chrome_bin
      # give a hint to here too
      Selenium::WebDriver::Chrome.driver_path = \
        "/app/vendor/bundle/bin/chromedriver"
    end

    # for now, no headless :/
    # options.add_argument "window-size=1200x600"
    # options.add_argument "headless"
    # options.add_argument "disable-gpu"

    # make the browser
    Watir::Browser.new :chrome, options: options
  end
end
