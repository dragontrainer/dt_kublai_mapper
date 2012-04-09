require 'rubygems'
require 'json'

require 'ning_anonymizer'

na = NingAnonymizer.new :json_groups      => File.read('data/ning-groups3.json'), 
                        :json_discussions => File.read('data/ning-discussions3.json'), 
                        :json_members     => File.read('data/ning-members2.json')

na.anonymize_all!
na.save_json

