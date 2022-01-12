# frozen_string_literal: true

class MemDB
  module RegexpEngines
    class Std
      def self.quote(str)
        ::Regexp.quote(str)
      end

      def initialize(source, ignore_case: false)
        opts = ::Regexp::MULTILINE
        opts |= ::Regexp::IGNORECASE if ignore_case

        @rx = ::Regexp.new(source, opts)
      end

      def match?(str)
        @rx.match?(str)
      end
    end
  end
end
