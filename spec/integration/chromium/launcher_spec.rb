require 'spec_helper'
require 'tmpdir'

RSpec.describe 'launcher' do
  before { skip unless chromium? }

  before(:all) do
    @execution = Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH'])
    @playwright_chromium = @execution.playwright.chromium
  end
  after(:all) do
    @execution.stop
  end
  let(:browser_type) { @playwright_chromium }

  it 'should return background pages', skip: ENV['CI'] do
    extension_path = File.join('spec', 'assets', 'simple-extension')

    launch_params = {
      headless: false,
      args: [
        "--disable-extensions-except=#{extension_path}",
        "--load-extension=#{extension_path}",
      ],
    }
    Dir.mktmpdir do |user_data_dir|
      browser_type.launch_persistent_context(user_data_dir, **launch_params) do |context|
        background_pages = context.background_pages
        background_page = background_pages.first || context.expect_event('backgroundpage')
        expect(background_page).not_to be_nil
        expect(context.background_pages).to include(background_page)
        context.close
        expect(context.pages).to be_empty
        expect(context.background_pages).to be_empty
      end
    end
  end
end
