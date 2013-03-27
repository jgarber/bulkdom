module Bulkdom
  class DomainList
    attr_accessor :list, :tlds, :results, :processed, :verbose

    def initialize()
      @list, @tlds = ["example"], [".com"]
      @processed = 0
      @results = Hash.new { |h, k| h[k] = {} }
    end

    def process
      tlds.each do |tld|
        list.each do |word|
          next unless results[tld][word].nil?
          registered = dns_is_registered(word, tld) || whois_is_registered(word, tld)
          puts "#{word}#{tld} is #{registered ? 'registered' : 'available'}" if verbose
        end
      end
      "OK"
    end

    def return_available(tld)
      process unless processed == list.size * tlds.size
      results[tld].select {|d,t| t == false }.keys
    end

    private

    def dns_is_registered(word, tld)
      Resolv.getaddress(word + tld)
      mark(word, tld, true)
    rescue Resolv::ResolvError
      false
    end

    def whois_is_registered(word, tld)
      mark(word, tld, Whois.registered?(word + tld))
    end

    def mark(word, tld, is_registered)
      results[tld][word] = is_registered
      self.processed += 1
      is_registered
    end
  end
end
