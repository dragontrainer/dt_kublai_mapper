require 'rubygems'
require 'json'

require 'kublai_dataset'

def export_kublai dataset, suffix
  dataset.export_csv "export/kublai_nodes#{suffix}-ANON.csv", "export/kublai_edges#{suffix}-ANON.csv"
  dataset.export_csv_use_names "export/kublai_nodes#{suffix}-NAME.csv", "export/kublai_edges#{suffix}-NAME.csv"
  dataset.export_graphml "export/kublai#{suffix}-ANON.graphml"
  dataset.export_foaf "export/kublai#{suffix}-ANON.rdf"
  dataset.export_pajek "export/kublai#{suffix}-ANON.net"
  dataset.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"
end

KUBLAI_MEMBERS = [
  "12gujudhf95af",
  "1m0m1tps7y8vt", 
  "2hensbe49wzs7",
  "2x978uukipw7n",
  "wzpholrkru6w",
  "1px4y7w7ywm28",
  "1hingz7r7g5tu",
  "5sn9vtte6got" ,
  "1syxk7ht0zx6e",
  "2u31ko9k8s2zz",
  "2yge2gzg2xm67",
  "082kwlby6ag7j",
  "18sob3b1v4nux",
  "3sburis6cfbzw",
  "3cm6e4tn711lw",
  "3nbz0nfl1yrxa",
  "236zy90fbei98",
  "3hgwv9m2lwdfp",
  "3oco30facpoy6",
  "3icm8j68oqtvy",
  "687uhk4pl3fc",
  "trw0ex0tq1m4"
]

KUBLAI_GROUPS = [
  "2089256:Group:29729",
  "2089256:Group:60521",
  "2089256:Group:68380",
  "2089256:Group:64832",
  "2089256:Group:57878"
]

kd = KublaiDataset.new :json_groups      => File.read('data/ning-groups-anonymized.json'), 
                       :json_discussions => File.read('data/ning-discussions-anonymized.json'), 
                       :json_members     => File.read('data/ning-members-anonymized.json')

# kd.refresh! :method => :comments_in_group, :no_weight_lesser_than => 50, :no_weight_greater_than => 1000
# export_kublai kd, "-alltime-allgroups-bygroup-get50_let1000"

# kd.refresh! :method => :comments_in_group
# export_kublai kd, "-alltime-allgroups-bygroup-allweights"

# kd.refresh! :method => :comments_in_group, :no_weight_lesser_than => 50, :no_weight_greater_than => 1000
# export_kublai kd, "-alltime-noclub-bygroup-get50_let1000"

kd.epurate_groups! KUBLAI_GROUPS

kd.refresh! :method => :comments_in_group, :exclude_contributors => KUBLAI_MEMBERS
export_kublai kd, "-alltime-noclub_noteam-bygroup-allweights"

kd.epurate_data_after! "2009-12-31"
kd.refresh! :method => :comments_in_group, :exclude_contributors => KUBLAI_MEMBERS
export_kublai kd, "-20091231-noclub_noteam-bygroup-allweights"

kd.epurate_data_after! "2009-03-15"
kd.refresh! :method => :comments_in_group, :exclude_contributors => KUBLAI_MEMBERS
export_kublai kd, "-20090315-noclub_noteam-bygroup-allweights"

# ALL, NO CLUB, NAMES, GROUP, 
# 15 march 2009, NO CLUB, NAMES, GROUP, 



