# frozen_string_literal: true

require_relative "test_helper"

module Prism
  class DoesNotParseTest < TestCase
    base = File.join(__dir__, "nixtures")
    relatives = ENV["FOCUS"] ? [ENV["FOCUS"]] : Dir["**/*.txt", base: base]

    relatives.each do |relative|
      filepath = File.join(base, relative)

      define_method "test_ripper_fails_to_parse_snippets_#{relative}" do
        file_contents = File.read(filepath, binmode: true, external_encoding: Encoding::UTF_8)
        file_contents.split(/(?<=\S)\n\n(?=\S)/).each do |snippet|
          assert_nil(Ripper.sexp_raw(snippet.rstrip), "Ripper parsed successfully (which is unexpected)")
        end
      end

      define_method "test_prism_fails_to_parse_snippets_#{relative}" do
        file_contents = File.read(filepath, binmode: true, external_encoding: Encoding::UTF_8)
        file_contents.split(/(?<=\S)\n\n(?=\S)/).each do |snippet|
          result = Prism.parse(snippet.rstrip, filepath: relative)
          assert_not_empty result.errors
        end
      end
    end
  end
end
