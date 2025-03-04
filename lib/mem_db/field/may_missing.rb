# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class MayMissing
      include MemDB::Field

      class Any
        include MemDB::Field::Matching

        def match?(_values)
          true
        end
      end

      ANY_MATCHING = Any.new

      def initialize(original)
        @original = original
      end

      def field
        @original.field
      end

      def query_field
        @original.query_field
      end

      def new_matching(value)
        if value.nil?
          ANY_MATCHING
        else
          @original.new_matching(value)
        end
      end

      def field_value(obj)
        if obj[field].nil?
          nil
        else
          @original.field_value(obj)
        end
      end

      def prepare_query(obj)
        @original.prepare_query(obj)
      end
    end
  end
end
