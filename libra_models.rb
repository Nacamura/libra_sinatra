require 'sinatra'
require 'mongoid'
Mongoid.load!('mongoid.yml')
load 'CrawlStrategy.rb'
load 'MyGmail.rb'

class Book
  include Mongoid::Document
  field :author, type: String
  field :publisher, type: String
  field :title, type: String
  field :year, type: Integer
  field :release, type: String
  embedded_in :library

  def ==(other)
    if(other.instance_of? self.class)
      if(other.title == self.title)
        if(other.author == self.author)
          if(other.publisher == self.publisher)
            if(other.year == self.year)
              return true
            end
          end
        end
      end
    end
    return false
  end

  def eql?(other)
    self == other
  end

  def ===(other)
    if(matches?(self.title, other.title))
      if(matches?(self.author, other.author))
        if(matches?(self.publisher, other.publisher))
          return true
        end
      end
    end
    return false
  end

  def matches?(book_attr, keyword)
    book_attr ||= ''
    (keyword.nil? || keyword=='') || (book_attr.gsub(/(\s|　)/, '').include? keyword.gsub(/(\s|　)/, ''))
  end

end

class Library
  include Mongoid::Document
  field :name, type: String
  field :author, type: String
  field :publisher, type: String
  field :title, type: String
  field :year, type: Integer
  field :sendmail, type: Boolean
  embeds_many :books

  def check_new_book
    new_books = find_new_books(crawl_library)
    register(new_books)
  end

  def crawl_library
    extend(STRATEGY_MAPPING[name]).crawl
  end

  def find_new_books(crawled_books)
    crawled_books.delete_if {|cb| books.include? cb}
  end

  def register(new_books)
    unless new_books.empty?
      books.concat new_books
      notify(new_books) if sendmail
    end
  end

  def notify(new_books)
    mail_body = ""
    new_books.each do |b|
      if(b.release.include?("http")) then
        mail_body += "著者, 書名\r\n"
        mail_body += b.author + ', ' + b.title + "\r\n"
      else
        mail_body += "著者, 書名, 発売日\r\n"
        mail_body += b.author + ', ' + b.title + ', ' + b.release + "\r\n"
      end
    end
    MyGmail.new.send('新しい本が登録されました', mail_body)
  end

end
