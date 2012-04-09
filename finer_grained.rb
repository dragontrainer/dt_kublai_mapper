require 'rubygems'
require 'json'

require 'kublai_fine_dataset'

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

kd = KublaiFineDataset.new :json_discussions => File.read('data/ning-discussions-anonymized.json')

kd.refresh! :exclude_groups => KUBLAI_GROUPS, :exclude_contributors => KUBLAI_MEMBERS

kd.export_csv "export/kublai_nodes-finer_grained-ANON.csv", "export/kublai_edges-finer_grained-ANON.csv"
