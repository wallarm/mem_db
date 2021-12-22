# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"
require "mem_db/regexp_engines/std"

class MemDB
  module Field
    class Pattern
      include MemDB::Field

      class Pattern
        WILDCARD = "*"

        class Rx
          def initialize(source, engine)
            parts = source.split(WILDCARD, -1).map { |part| engine.quote(part) }
            parts[0] = "\\A#{parts[0]}"
            parts[-1] = "#{parts[-1]}\\z"
            @rx = engine.new(parts.join(".*"))
          end

          def match?(str)
            @rx.match?(str)
          end
        end

        class Exact
          def initialize(source)
            @source = source
          end

          def match?(str)
            @source == str
          end
        end

        class Prefix
          def initialize(prefix)
            @prefix = prefix
          end

          def match?(str)
            str.start_with?(@prefix)
          end
        end

        class Suffix
          def initialize(suffix)
            @suffix = suffix
          end

          def match?(str)
            str.end_with?(@suffix)
          end
        end

        def initialize(source, rx_engine:)
          wildcard_count = source.count(WILDCARD)
          @pat =
            if wildcard_count.zero?
              Exact.new(source)
            elsif wildcard_count > 1
              Rx.new(source, rx_engine)
            elsif source.end_with?(WILDCARD)
              Prefix.new(source[0..-2])
            elsif source.start_with?(WILDCARD)
              Suffix.new(source[1..-1])
            else # rubocop:disable Lint/DuplicateBranch
              Rx.new(source, rx_engine)
            end
        end

        def match?(str)
          @pat.match?(str)
        end
      end

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(arr, rx_engine:)
          @patterns = arr.map { |source| Pattern.new(source, rx_engine: rx_engine) }
        end

        def match?(values)
          values.any? { |str| @patterns.any? { |pat| pat.match?(str) } }
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(el, rx_engine:)
          @pat = Pattern.new(el, rx_engine: rx_engine)
        end

        def match?(values)
          values.any? { |str| @pat.match?(str) }
        end
      end

      attr_reader :field

      def initialize(field, rx_engine: MemDB::RegexpEngines::Std)
        @field = field
        @rx_engine = rx_engine
      end

      def new_matching(value)
        if value.is_a?(Array)
          MultiMatching.new(value, rx_engine: @rx_engine)
        else
          SingleMatching.new(value, rx_engine: @rx_engine)
        end
      end
    end
  end
end
