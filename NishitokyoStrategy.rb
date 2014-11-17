require 'mechanize'
require 'MyGmail'
module NishitokyoStrategy
#  include LogInterceptor

  def crawl
    res = get_mechanize_res
    alert_hit_count(res)
    make_books(res)
  end

  def get_mechanize_res
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    search_page = agent.get 'http://www.library.city.nishitokyo.lg.jp/detailsearch?1'
    form = search_page.form
    if(self.year.blank?)
      self.year = Time.now.year
    end
    form.field_with(:name=>'textKey1').value = title.to_s
    form.field_with(:name=>'textKey2').value = author.to_s
    form.field_with(:name=>'textKey3').value = publisher.to_s
    form.field_with(:name=>'textYearFrom').value = (self.year - 1).to_s
    form.field_with(:name=>'textYearTo').value = (self.year + 1).to_s
    form.field_with(:name=>'selectMaxView').value = "100"
    form.click_button
  end

  def make_books(mechanize_res)
    books = []
    mechanize_res.search("tr").each do |tr|
      tds = tr.search("td")
      if(tds.length < 6) then next end
      title = tds[2].text
      author = tds[3].text
      publisher = tds[4].text
      year = tds[5].text
      release = "http://www.library.city.nishitokyo.lg.jp" + ( (tds[2].child.attributes["href"].value).tr('.', '') )
      books << Book.new(:title=>title, :author=>author, :publisher=>publisher, :year=>year, :release=>release)
    end
    books
  end

  def alert_hit_count(mechanize_res)
    hit_count = 0
    count_xml = mechanize_res.search("p")[2].search("span")[1]
    if(count_xml) then hit_count = count_xml.text.gsub(/件中.*/, "").to_i end
    if(hit_count > 100)
      MyGmail.new.send("検索件数上限超過", "検索件数が#{hit_count}件です。100件目以降は通知されません。")
    end
  end

end
