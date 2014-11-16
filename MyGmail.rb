require 'gmail'
load 'MyJSON.rb'

class MyGmail
  def initialize
  @settings = MyJSON.load_json("settings.txt")
    @gmail = Gmail.new(@settings['email'], @settings['email_pw'])
  end

  def send(title, content)
    target = @settings["target_email"]
    @gmail.deliver do
      to target
      subject title
      text_part do
        body content
      end
    end
  end
end

