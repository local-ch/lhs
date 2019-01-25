# frozen_string_literal: true

def load_json(name)
  File.read("spec/support/fixtures/json/#{name}.json")
end
