module BaseHelpers
  alias :doing :lambda

  def login!(email, password)
    visit sign_in_path

    visit "/"
    fill_in "Email",    :with => email
    fill_in "Password", :with => password
    click "Sign in"

    click_button "Sign in"
  end

  def logout!
    visit sign_out_path
  end

  def should_have_validation_errors(*messages)
    within(:css, "#errorExplanation") do
      messages.each { |msg| page.should have_content(msg) }
    end
  end
  alias_method :should_have_validation_error, :should_have_validation_errors

  def should_be_on(path)
    page.current_url.should match(Regexp.new(path))
  end
  alias_method :should_redirect_to, :should_be_on

  def should_not_be_on(path)
    page.current_url.should_not match(Regexp.new(path))
  end
  alias_method :should_not_redirect_to, :should_not_be_on

  [:notice, :error].each do |name|
    define_method "should_have_#{name}" do |message|
      page.should have_css(".message.#{name}", :text => message)
    end
  end

  def fill_the_following(fields={})
    fields.each do |field, value|
      fill_in field,  :with => value
    end
  end
  alias_method :fill_with, :fill_the_following

  def should_have_the_following(*contents)
    contents.each do |content|
      page.should have_content(content)
    end
  end

  def should_have_table(table_name, *rows)
    within(table_name) do
      rows.each do |columns|
        columns.each { |content| page.should have_content(content) }
      end
    end
  end

  def stub_prompt_and_return(value)
    page.evaluate_script "window.prompt = function() { return '#{value}'; }"
  end

  def stub_popups_to_confirm
    page.evaluate_script "window.confirm = function() { return true; }"
  end

  def stub_alerts_to_close
    page.evaluate_script "window.alert = function() { return true; }"
  end
end

Rspec.configuration.include(BaseHelpers)
