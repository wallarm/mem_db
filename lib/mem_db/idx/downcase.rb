# frozen_string_literal: true

class MemDB
  module Idx
    class Downcase
      include MemDB::Idx

      def initialize(original)
        @original = original
      end

      def field
        @original.field
      end

      def map_value(str)
        @original.map_value(str.to_s.downcase)
      end

      def map_query(str)
        @original.map_query(str.to_s.downcase)
      end
    end
  end
end
