load 'libra_models.rb'

class NishitokyoCrawler
  def call
    Library.where(name: "西東京市").each do |l|
      l.sendmail = true
      l.check_new_book
    end
  end
end

class ComicCrawler
  def call
    Library.where(name: "コミック").each do |l|
      l.sendmail = true
      l.check_new_book
    end
  end
end
