namespace :mint do
  desc "TODO"
  task budget_scraper: :environment do
    browser = Watir::Browser.new :chrome
    browser.goto("https://mint.intuit.com/planning.event")
    browser.input(name: "Email").send_keys("pavan.sarguru@gmail.com")
    browser.input(name: "Password").send_keys("D1rkusC1rcus9841!")
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

end
