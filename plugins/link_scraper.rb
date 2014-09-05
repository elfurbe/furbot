require 'mechanize'
require 'fastimage'
require 'json'
require 'cgi'
require 'nokogiri'
require 'twitter'
require 'asin'

module Cinch
  module Plugins
    class LinkScraper
      include Cinch::Plugin

      def initialize(*args)
        super

        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
        @agent.max_history = 0
      end
      def time_ago_in_words(t1, t2)
        s = t1.to_i - t2.to_i # distance between t1 and t2 in seconds

        resolution = if s > 29030400 # seconds in a year
          [(s/29030400), 'years'] 
        elsif s > 2419200
          [(s/2419200), 'months']
        elsif s > 604800
          [(s/604800), 'weeks']
        elsif s > 86400
          [(s/86400), 'days']
        elsif s > 3600 # seconds in an hour
          [(s/3600), 'hours'] 
        elsif s > 60
          [(s/60), 'minutes']
        else
          [s, 'seconds']
        end

        # singular v. plural resolution
        if resolution[0] == 1
          resolution.join(' ')[0...-1]
        else
          resolution.join(' ')
        end
      end

      listen_to :channel

      # Listens to all incoming messages in the channel for links. Grabs the
      # first parsable link out of a message that it can and loads it for
      # certain attributes. Basic pages will retrieve a title and the host
      # domain. YouTube links will be parsed for likes/dislikes/views. Tweets
      # will be parsed and returned to the channel. Images will have their
      # dimensions and file name fetched. Gists will be parsed for their owner
      # and post date.
      #
      # <davidcelis> I didn't know they did this: http://imgur.com/jYjq8
      # <snap> Voodoo Doughnuts sold me a bucket of "extra" doughnuts for $5! - Imgur (at imgur.com)
      def listen(m)
        return if m.user == @bot || m.user.nil?

        prefix = "#{m.user}:"

        URI.extract(m.message) do |link|
          begin
            uri = URI.parse(link)
            page = @agent.get(link)
          rescue URI::InvalidURIError, Mechanize::ResponseCodeError
            next
          end

          if page.is_a?(Mechanize::Image)
            size = FastImage.size(page.body_io)
            name = CGI.unescape(page.filename)
            m.reply "#{name} - #{size[0]}x#{size[1]}" and return
          end

          title = page.title.strip

          case uri.host
          when 'www.youtube.com', 'youtu.be'
            link = 'http://youtube.com/watch?v=' + link.split('/').last if uri.host == 'youtu.be'
            page = @agent.get(link + '&nofeather=True')

            title = page.at('title').content.strip.gsub("- YouTube", '').strip
            length = page.at("meta[itemprop='duration']")[:content].gsub("PT",'').gsub("M",":").gsub("S",'')
            hits = page.at(".watch-view-count").content.strip
            likes = page.at(".likes-count").content
            dislikes = page.at(".dislikes-count").content

            m.reply "#{prefix} #{title} length: #{length} (#{hits} views, #{likes} likes, #{dislikes} dislikes)"
          when 'gist.github.com'
            owner = page.search("//span[@class='author vcard']").text.strip
            time = page.search("//time[@class='js-relative-date']").first.text.strip

            m.reply "#{title} (posted by #{owner}, last updated on #{time})"
          when 'twitter.com'
            if link =~ /\/([^\/]+)\/status\/(\d+)$/
              client = Twitter::REST::Client.new do |config|
                config.consumer_key     = "#{Furbot::Config::GLOBAL_VARS[:twitter_consumer_key]}"
                config.consumer_secret  = "#{Furbot::Config::GLOBAL_VARS[:twitter_consumer_secret]}"
              end
              user = $1
              tweet = client.status($2)
              user = tweet.user.screen_name
              text = CGI.unescapeHTML(tweet.text)
              time_abs = tweet.created_at
              time = time_ago_in_words(Time.now, time_abs)

              m.reply "@#{user}: #{text} (#{time} ago)"
            else
              m.reply "#{title} (at #{uri.host})"
            end
          when 'www.amazon.com'
            ASIN::Configuration.configure do |config|
                config.secret           = "#{Furbot::Config::GLOBAL_VARS[:amzn_secret]}"
                config.key              = "#{Furbot::Config::GLOBAL_VARS[:amzn_key]}"
                config.associate_tag    = "#{Furbot::Config::GLOBAL_VARS[:amzn_associate_tag]}"
            end
            asin = link.scan(/http:\/\/(?:www\.|)amazon\.com\/(?:gp\/product|[^\/]+\/dp|dp)\/([^\/]+)/)
            client = ASIN::Client.instance
            items = client.lookup(asin, :ResponseGroup => [:Medium, :Offers])
            item = items.first
            title = item.item_attributes.title
            price = item.offers.offer.offer_listing.price.formatted_price
            price_cur = item.offers.offer.offer_listing.price.currency_code

            m.reply "Amazon: #{title} (#{price} #{price_cur})"
          else
            m.reply "#{title} (at #{uri.host})"
          end
        end
      end
    end
  end
end
