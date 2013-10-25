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
require '/path/to/furbot_config.rb'

bot = Cinch::Bot.new do
    configure do |c|
        c.server = Furbot::Config::HOST[:server]
        c.password = Furbot::Config::HOST[:password]
        c.port = Furbot::Config::HOST[:port]
        c.ssl.use = Furbot::Config::HOST[:ssl]
        c.channels = Furbot::Config::HOST[:channels]
        c.nick = Furbot::Config::BOT[:nick]
        c.user = Furbot::Config::BOT[:user]
        c.realname = Furbot::Config::BOT[:realname]
        c.delay_joins = Furbot::Config::OPTIONS[:delay_joins]
        c.plugins.prefix = Furbot::Config::PLUGINS[:prefix]
        c.plugins.plugins = Furbot::Config::PLUGINS[:plugins]
        c.plugins.options[Cinch::Plugins::Identify] = {
            :password   => Furbot::Config::BOT[:password],
            :type       => Furbot::Config::IDENTIFYOPTS[:type],
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
