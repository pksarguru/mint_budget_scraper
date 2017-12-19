namespace :mint do
  desc "TODO"
  task budget_scraper: :environment do
    start_task_time = DateTime.now

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
      browser.button(text: "Continue").click

      send_sign_in_text

      browser.wait_until(15) {
        AccessCode.last.created_at > start_task_time
      }

      browser.input(id: "ius-mfa-confirm-code").send_keys(AccessCode.last.body)
      browser.input(id: "ius-mfa-otp-submit-btn").click
    end

    # binding.pry
    browser.wait_until(30) {
      browser.span(text: "Refreshing your accounts, this shouldn\'t take more than a couple minutes.").present? == false
    }

    a = browser.spans

    array = a.select { |span| span.class_name == "amount" && !span.text.blank?}

    spent = array[2].text.delete(",").to_f - 2000

    budget = array[3].text.delete(",").to_f - 2000

    p "*****************"
    puts spent/budget

    current_day = Date.today.day
    days_in_month = Date.today.end_of_month.day

    month_progress = current_day.to_f/days_in_month.to_f

    budget_target = month_progress * budget

    budget_status = budget_target - spent

    if budget_status > 0
      send_status_text("You're currently under the target budget by #{number_to_currency(budget_status)}")
    else
      send_status_text("You're currently over the target budget by #{number_to_currency(budget_status.abs)}")
    end
  end

  def send_status_text(message)
    client = Twilio::REST::Client.new

    client.api.account.messages.create(
      from: ENV.fetch("TWILIO_PHONE_NUMBER"),
      to: ENV.fetch("PAVAN_PHONE_NUMBER"),
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

  private

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
      options.detach = true
      options.binary = chrome_bin
      # give a hint to here too
      Selenium::WebDriver::Chrome.driver_path = \
        "/app/vendor/bundle/bin/chromedriver"
    end

    caps = Selenium::WebDriver::Remote::Capabilities.chrome

    caps[:chrome_options] = {detach: true}

    # for now, no headless :/
    # options.add_argument "window-size=1200x600"
    # options.add_argument "headless"
    # options.add_argument "disable-gpu"

    # make the browser
    Watir::Browser.new :chrome, options: options
  end
end
