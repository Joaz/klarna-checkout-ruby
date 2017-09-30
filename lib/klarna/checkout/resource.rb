require 'json'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/deep_merge'

require 'klarna/checkout/concerns/has_one'
require 'klarna/checkout/concerns/has_many'

module Klarna
  module Checkout
    class Resource
      extend HasOne
      extend HasMany
			attr_accessor :raw

      def initialize(args = {})
        self.raw=args
				self.class.defaults.deep_merge(args).each_pair do |attr, value|
          setter = "#{attr}="
          self.send(setter, value) if respond_to?(setter)
        end
      end

      def to_json(*keys)
        sanitized_json = json_sanitize(self.as_json, keys)
        JSON.generate(sanitized_json)
      end

      def json_sanitize(hash, keys = [])
        hash.reject! { |_, v| v.nil? }
        hash.slice!(*Array(keys)) if keys.any?
        hash
      end

      class << self
        def defaults=(hash)
          if hash
            raise ArgumentError.new unless hash.is_a? Hash

            @defaults ||= {}
            @defaults.deep_merge!(hash)
          else
            @defaults = {}
          end
        end

        def defaults
          @defaults || {}
        end
      end
    end
  end
end
