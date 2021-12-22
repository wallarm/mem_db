# frozen_string_literal: true

require "re2"

class MemDB
  module RegexpEngines
    class Re2
      def self.quote(str)
        ::RE2::Regexp.quote(str)
      end

      def initialize(source, ignore_case: false)
        opts = {
          one_line: false
        }
        opts[:case_sensitive] = false if ignore_case
        multiline_source = "(?s:#{source})"

        @rx = ::RE2::Regexp.new(multiline_source, **opts)
      end

      def match?(str)
        @rx.match?(str)
      end
    end
  end
end
