require 'sinatra'
require 'mongoid'
require 'slim'
Mongoid.load!('mongoid.yml')
load 'libra_models.rb'

get ('/') {slim :index, locals: { libraries: Library.all }}

post ('/') do
  library = Library.create(params[:library])
  library.check_new_book
  redirect '/'
end

get ('/:id/edit') do
  @library = Library.find(params[:id])
  slim :edit
end

get ('/:id/delete') do
  @library = Library.find(params[:id])
  slim :delete
end

get ('/new') do
  @library = Library.new
  slim :new
end

put ('/:id') do
  @library = Library.find(params[:id])
  @library.update_attributes(params[:library])
  @library.books = []
  @library.check_new_book
  redirect '/'
end

delete ('/:id') do
  Library.find(params[:id]).destroy
  redirect '/'
end

__END__
@@ index
doctype html
html
  head
    title Libra
  body
    h1 検索対象の一覧
    a href="/new" 新規作成
  - if libraries.any?
    table
      thead
        tr
          th 検索対象
          th 書名
          th 著者
          th 出版社
          th 出版年
          th 編集
          th 削除
          th 登録済み書籍
      tbody
        - for library in libraries
          tr
            td =  library.name
            td =  library.title
            td = library.author
            td = library.publisher
            td = library.year
            td
              a href = (library.id.to_s + "/edit") 編集
            td
              a href = (library.id.to_s + "/delete") 削除
            - for book in library.books
              tr
                td
                td
                td
                td
                td
                td
                td
                td = book.title
  - else
    p 検索対象が登録されていません

@@ new
doctype html
html
  head
    title Libra
  body
    h1 検索対象の作成
    form action="/" method="POST"
      input type="submit" value=" 作成 "
      == slim :form 

@@ edit
doctype html
html
  head
    title Libra
  body
    h1 検索対象の編集
    form action="/#{@library.id}" method="POST"
      input type="hidden" name="_method" value="PUT"
      input type="submit" value=" 更新 "
      == slim :form

@@ delete
doctype html
html
  head
    title Libra
  body
    h1 以下を削除してもよろしいですか？
    p #{@library.name} #{@library.title} #{@library.author} #{@library.publisher} #{@library.year}
    form action="/#{@library.id}" method="POST"
      input type="hidden" name="_method" value="DELETE"
      input type="submit" value="Delete"
    a href="/" キャンセル

@@ form
      table
        tr
          th 検索対象
          th 書名
          th 著者
          th 出版社
          th 出版年
        tr
          td
            select.name name="library[name]"
              option value="西東京市" 西東京市
              option value="コミック" コミック
          td
            input.title type="text" name="library[title]" value="#{@library.title}" size="32"
          td
            input.author type="text" name="library[author]" value="#{@library.author}" size="16"
          td
            input.publisher type="text" name="library[publisher]" value="#{@library.publisher}" size="16"
          td
            input.year type="text" name="library[year]" value="#{@library.year}" size="16"
