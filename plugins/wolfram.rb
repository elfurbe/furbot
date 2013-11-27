require 'open-uri'
require 'nokogiri'

module Cinch
    module Plugins
        class Wolfram
        include Cinch::Plugin

        match /wa (.+)$/i

        def execute(m, query)
            begin
                    url = "http://api.wolframalpha.com/v2/query?appid=#{Furbot::Config::GLOBAL_VARS[:wolframapi]}&input=#{CGI.escape(query)}"
                    @page = Nokogiri::XML(open(url))

                    success = @page.xpath("//queryresult/@success").text
                    moreinfo = "http://www.wolframalpha.com/input/?i=#{CGI.escape(query)}"

                    if success == "true"
                            input = @page.xpath("//pod[@position='100']//plaintext[1]").text.gsub(/\s+/, ' ')
                            output = @page.xpath("//pod[@position='200']/subpod[1]/plaintext[1]").text.gsub(/\s+/, ' ')
                            input = input[0..140]+"..." if input.length > 140
                            output = output[0..140]+"..." if output.length > 140

                            if output.length < 1 and input.length > 1
                                    reply = " => Plaintext not available. Clicken das linken below."
                            elsif output.length < 1 and input.length < 1
                                    reply = "Um, what?"
                            else
                                    reply = "=> " + output
                            end

                    else
                            reply = "Um, what?"
                    end

                    m.reply "You asked Wolfram about:"
                    m.reply "#{input}"
                    m.reply "Here's what they said:"
                    m.reply "#{reply}"
                    m.reply "Wolfram 7 | More info: #{moreinfo}"
            rescue
                    m.reply "Wolfram 7 | Error"
            end
        end
        end
    end
end
