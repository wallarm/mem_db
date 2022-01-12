# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"
require "mem_db/regexp_engines/std"

class MemDB
  module Field
    class Regexp
      include MemDB::Field

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(arr, rx_engine:, ignore_case:)
          @patterns = arr.map { |source| rx_engine.new(source, ignore_case: ignore_case) }
        end

        def match?(values)
          values.any? { |str| @patterns.any? { |pat| pat.match?(str) } }
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(el, rx_engine:, ignore_case:)
          @pat = rx_engine.new(el, ignore_case: ignore_case)
        end

        def match?(values)
          values.any? { |str| @pat.match?(str) }
        end
      end

      attr_reader :field

      def initialize(field, rx_engine: MemDB::RegexpEngines::Std, ignore_case: false)
        @field = field
        @rx_engine = rx_engine
        @ignore_case = ignore_case
      end

      def new_matching(value)
        if value.is_a?(Array)
          MultiMatching.new(value, rx_engine: @rx_engine, ignore_case: @ignore_case)
        else
          SingleMatching.new(value, rx_engine: @rx_engine, ignore_case: @ignore_case)
        end
      end
    end
  end
end
