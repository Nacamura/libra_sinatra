require 'clockwork'
load 'crawl_with_libra.rb'

module Clockwork
  handler do |job|
  	job.call
  end

  every(1.day, NishitokyoCrawler.new, :at=>'19:00')
  every(1.day, ComicCrawler.new, :at=>'14:00')


end

