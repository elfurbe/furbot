# encoding: UTF-8
require_relative 'furbot_config.rb'

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
        c.plugins.options[Cinch::Plugins::MessageHistory] = {
            :user_messages => Furbot::Config::MSGHISTOPTS[:user_messages],
            :channel_messages => Furbot::Config::MSGHISTOPTS[:channel_messages]
        }

    end

    @redis = Redis.new(:host => "127.0.0.1", :port => 6379)
    def self.redis(); @redis; end

    on :message, "woo woo woo" do |m|
        m.reply "#{m.user.nick}: you know it"
    end
    on :message, /.*(^|[\s\t\r\n\f])(9000)([\s\t\r\n\f]|$).*/i do |m|
        m.reply "IT'S OVER 9000!!!!!!!!! https://www.youtube.com/watch?v=SiMHTK15Pik"
    end
    on :message, "\u0001ACTION flips tables\u0001" do |m|
        m.reply "#{m.user.nick}: (╯°□°）╯︵ ┻━┻"
    end
    on :message, /.*(^|[\s\t\r\n\f])(angry|mad)([\s\t\r\n\f]|$).*/i do |m|
        m.reply "#{m.user.nick}: (╯°□°）╯︵ ┻━┻"
    end
    on :message, /^(syn)$/i do |m|
        m.reply "SYN-ACK"
    end
    on :message, /^(ack)$/i do |m|
        history = bot.redis.lrange("#{m.channel}:#{m.user.nick}:messages", 1, 1).map { |msg| JSON.parse msg }
        if history.first['message'].casecmp("syn") == 0
            m.reply "ESTABLISHED"
        end
    end
end

bot.start
