load 'libra_models.rb'

Library.each do |l|
  l.sendmail = true
  l.check_new_book
end

