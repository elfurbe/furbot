# encoding: UTF-8
require 'cinch'
require 'cinch/plugins/identify'
require 'cinch/plugins/urlscraper'
require 'cinch-calculate'
require 'cinch/plugins/downforeveryone'
require 'cinch-weatherman'
require '/usr/local/lib/site_ruby/1.9.1/x86_64-linux/snap/lib/cinch/plugins/link_scraper.rb'
require '/usr/local/lib/site_ruby/1.9.1/x86_64-linux/snap/lib/cinch/plugins/google.rb'
require '/usr/local/lib/site_ruby/1.9.1/x86_64-linux/snap/lib/cinch/plugins/s.rb'

bot = Cinch::Bot.new do
    configure do |c|
        c.server = "<server>"
        c.password = "<server password>"
        c.port = <server port>
        c.ssl.use = <true|false>
        c.channels = ["#channel1","#channel2"]
        c.nick = "furbot"
        c.user = "furbot"
        c.realname = "furbot"
        c.delay_joins = :identified
        c.plugins.prefix = "."
        c.plugins.plugins = [Cinch::Plugins::Identify,Cinch::Plugins::LinkScraper,Cinch::Plugins::Calculate,Cinch::Plugins::DownForEveryone,Cinch::Plugins::Weatherman,Cinch::Plugins::Google]
        c.plugins.options[Cinch::Plugins::Identify] = {
            :password   => "<nickserv password for bot>",
            :type       => :nickserv,
        }

    end

    on :message, "woo woo woo" do |m|
        m.reply "#{m.user.nick}: you know it"
    end
    on :message, "\u0001ACTION flips tables\u0001" do |m|
        m.reply "#{m.user.nick}: (╯°□°）╯︵ ┻━┻"
    end
    on :message, /.*(angry|mad).*/i do |m|
        m.reply "#{m.user.nick}: (╯°□°）╯︵ ┻━┻"
    end
end

bot.start
