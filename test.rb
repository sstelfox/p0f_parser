require 'json'
require 'json-schema'
require 'yaml'

schema = JSON.parse(File.read('./lib/p0f_parser/schemas/host.json'))
data1 = YAML.load(File.read('./spec/fixtures/full_host.yml'))
data2 = YAML.load(File.read('./spec/fixtures/min_host.yml'))

# Weird... either one works but they don't work together... somebody is storing state they shouldn't be...
puts JSON::Validator.fully_validate(schema, data1)
#puts JSON::Validator.fully_validate(schema, data2)
