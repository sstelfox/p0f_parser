require 'json'
require 'json-schema'
require 'yaml'

schema = JSON.parse(File.read('./lib/p0f_parser/schemas/host.json'))
data = YAML.load(File.read('./test.yml'))

puts JSON::Validator.fully_validate(schema, data, :errors_as_objects => true)
