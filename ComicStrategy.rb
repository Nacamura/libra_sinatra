module ComicStrategy

  @@books_cache

  def crawl
    @@books_cache ||= make_to_books(get_mechanize_res)
    filter_books(@@books_cache)
  end

  def get_urls
    urls = []
    months = (0..2).map{|i| Time.now.months_since(i).strftime('%y%m')}
    months.each do |m|
      urls << 'http://www.taiyosha.co.jp/comic/comic' + m + '_date1.html'
      urls << 'http://www.taiyosha.co.jp/comic/comic' + m + '_date2.html'
    end
    urls
  end

  def get_mechanize_res
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    get_urls.map do |url|
      begin
        agent.get url
      rescue Mechanize::ResponseCodeError
      end
    end
  end

  def make_to_books(mechanize_res)
    books = []
    mechanize_res.each do |res|
      if(res.nil?) then next end
      res.search('tr').each do |tr|
        tds = tr.search('td')
        if(tds.length != 6) then next end
        release = tds[0].text.slice(0,5)
        publisher = tds[1].text
        title = tds[2].text
        author = tds[3].text
        books << Book.new(:title=>title, :author=>author, :publisher=>publisher, :release=>release)
      end
    end
    books
  end

  def filter_books(books)
    books.select do |b|
      b === self
    end
  end
  
end
