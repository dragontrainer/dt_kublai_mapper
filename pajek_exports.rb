require 'rubygems'
require 'fastercsv'

require 'kublai_dataset'

def calculate_means(file_name)
  # load degrees
  degrees = FasterCSV.read(file_name, :headers=>:first_row)
  puts "elements read: #{degrees.size}"
  
  # purge kublai members
  kublai_member_names = KUBLAI_MEMBERS.map{|m| m[1]}
  degrees.delete_if{|e| kublai_member_names.include?( e[1]) }
  puts "elements after purging kublai members: #{degrees.size}"
  
  # extract the degrees
  numbers = degrees.map{|e| e[2].to_f }.sort.reverse
  
  # calculate the top 10 mean
  top_10 = numbers[0..9]
  top_10_mean = top_10.inject(0.0){|t,n|t+=n}/10
  
  # calculate the top 25 mean
  top_25 = numbers[0..24]
  top_25_mean = top_25.inject(0.0){|t,n|t+=n}/25

  # calculate the top 50 mean
  top_50 = numbers[0..9]
  top_50_mean = top_50.inject(0.0){|t,n|t+=n}/50
  
  return [top_10_mean, top_25_mean, top_50_mean]
end

# calculate means
[ ["Marzo 2009", "export/degree_march.csv"],
  ["Dicembre 2009", "export/degree_december.csv"],
  ["Dicembre 2009 (solo memberi presenti a marzo)", "export/degree_december_only_march_members.csv"],
].each do |desc,file|
  top_10_mean, top_25_mean, top_50_mean = calculate_means( file )
  
  puts %{
    Dati di #{desc}: top 10: #{top_10_mean}, top 25: #{top_25_mean}, top 50:#{top_50_mean}
  }
end

