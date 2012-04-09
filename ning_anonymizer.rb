require 'rubygems'
require 'json'

class NingAnonymizer
  
  FIELDS_TO_REMOVE = %w(
    fullName
    status
    gender
    location
    country
    birthdate
    email
    profileQuestions
    level
    profilePhoto
    zip
  )
  
  def initialize(options)
    @jgroups = JSON.parse options[:json_groups]
    @jdiscussions = JSON.parse options[:json_discussions]
    @jmembers = JSON.parse options[:json_members]
  end
  
  def anonymize_all!
    anonymize_members!
    anonymize_groups!
    anonymize_discussions!
  end

  def anonymize_groups!
    @jgroups.each do |g|
      g["members"].each do |m|
        anonymize!(m)
      end if g["members"].respond_to?(:each)
    end
  end

  def anonymize_discussions!
  end

  def anonymize_members!
    @jmembers.each do |m|
      anonymize!(m)
    end
  end

  def save_json(options={})
    ts = Time.now.strftime("%Y%m%d-%H%M%S")
    write_file( (options[:members_file]||"data/ning-members-anonymized_#{ts}.json"), @jmembers.to_json )
    write_file( (options[:groups_file]||"data/ning-groups-anonymized_#{ts}.json"), @jgroups.to_json )
    write_file( (options[:discussions_file]||"data/ning-discussions-anonymized_#{ts}.json"), @jdiscussions.to_json )
  end
  
  private 

  def write_file filename, content
    File.open(filename, 'w') {|f| f.write content }
  end
  
  def anonymize!(what)
    FIELDS_TO_REMOVE.each do |k|
      what.delete(k)
    end if what.respond_to?(:delete)   
  end
end