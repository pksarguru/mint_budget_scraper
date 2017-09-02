namespace :mint do
  desc "TODO"
  task budget_scraper: :environment do
    browser = new_browser
    browser.goto("https://mint.intuit.com/planning.event")
    browser.input(name: "Email").send_keys(ENV.fetch("USERNAME"))
    browser.input(name: "Password").send_keys(ENV.fetch("PW"))
    browser.button(name: "SignIn").click

    browser.wait_until { browser.a(id: "add-budget").present? }

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
      puts "You're under target budget by #{budget_status}"
    else
      puts "You're over target budget by #{budget_status}"
    end
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
