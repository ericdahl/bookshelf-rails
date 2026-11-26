require "test_helper"
require "capybara/selenium/driver"
require "capybara/selenium/driver_specializations/chrome_driver"

# Chrome 158+ rejects the "*" origin that Capybara 3.40's ChromeDriver#reset!
# passes to the CDP Storage.clearDataForOrigin command ("invalid argument: * is
# not a valid URL"), which errors every system test on teardown. Clear cookies
# browser-wide and the remaining storage for the app server's origin instead.
# Remove once a Capybara release handles this.
module ChromeStorageClearWorkaround
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")
    other_types = params[:storageTypes].to_s.split(",") - [ "cookies" ]
    server = Capybara.current_session.server
    if other_types.any? && server
      super(cmd, origin: server.base_url, storageTypes: other_types.join(","))
    end
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageClearWorkaround)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
