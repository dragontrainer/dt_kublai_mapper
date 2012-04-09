require 'rubygems'
require 'json'

require 'kublai_dataset'

kd_march = KublaiDataset.new :json_groups      => File.read('data/ning-groups3.json'), 
                       :json_discussions => File.read('data/ning-discussions3.json'), 
                       :json_members     => File.read('data/ning-members2.json')


kd_march.epurate_groups! ["2089256:Group:29729"]
kd_march.epurate_data_after! "2009-03-15T23:59:59"
kd_march.refresh! :method => :comments_in_discussion

suffix = "-2009-03-15T23-59-59_no-club-discussion-method"

kd_march.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd_march.export_graphml "export/kublai#{suffix}.graphml"
kd_march.export_pajek "export/kublai#{suffix}.net"
kd_march.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"

kd_december = KublaiDataset.new :json_groups      => File.read('data/ning-groups3.json'), 
                       :json_discussions => File.read('data/ning-discussions3.json'), 
                       :json_members     => File.read('data/ning-members2.json')


kd_december.epurate_groups! ["2089256:Group:29729"]
kd_december.epurate_data_after! "2009-12-31T23:59:59"
kd_december.refresh! :method => :comments_in_discussion

suffix = "-2009-12-31T23-59-59_no-club-discussion-method"

kd_december.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd_december.export_graphml "export/kublai#{suffix}.graphml"
kd_december.export_pajek "export/kublai#{suffix}.net"
kd_december.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"

kd_december_only_march_nodes = KublaiDataset.new :json_groups      => File.read('data/ning-groups3.json'), 
                       :json_discussions => File.read('data/ning-discussions3.json'), 
                       :json_members     => File.read('data/ning-members2.json')


kd_december_only_march_nodes.epurate_groups! ["2089256:Group:29729"]
kd_december_only_march_nodes.epurate_data_after! "2009-12-31T23:59:59"
kd_december_only_march_nodes.refresh! :method => :comments_in_discussion, :include_nodes=>kd_march.contributors

suffix = "-2009-12-31T23-59-59_no-club-only-march-members-discussion-method"

kd_december_only_march_nodes.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd_december_only_march_nodes.export_graphml "export/kublai#{suffix}.graphml"
kd_december_only_march_nodes.export_pajek "export/kublai#{suffix}.net"
kd_december_only_march_nodes.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"


exit

# ==========================


kd = KublaiDataset.new :json_groups      => File.read('data/ning-groups3.json'), 
                       :json_discussions => File.read('data/ning-discussions3.json'), 
                       :json_members     => File.read('data/ning-members2.json')


kd.epurate_groups! ["2089256:Group:29729"]
kd.epurate_data_after! "2009-03-24T10:00:01"
kd.refresh! :method => :comments_in_discussion

suffix = "-2009-03-24T10:00:01-no-club-discussioncountmethod"

kd.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd.export_graphml "export/kublai#{suffix}.graphml"
kd.export_pajek "export/kublai#{suffix}.net"
kd.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"

exit

# ==========================

kd.refresh! :method => :comments_in_group

suffix = "-all"

kd.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd.export_graphml "export/kublai#{suffix}.graphml"
kd.export_pajek "export/kublai#{suffix}.net"
kd.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"


# ==========================
kd.epurate_groups! ["2089256:Group:29729"]
kd.refresh! :method => :comments_in_group

suffix = "-no-club"

kd.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd.export_graphml "export/kublai#{suffix}.graphml"
kd.export_pajek "export/kublai#{suffix}.net"
kd.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"

# create a snapshot of the Kublai database as of May 15th 2009, excluding Club dei Progettisti
# create another snapshot as of Dec 31st 2009, again excluding Club dei progettisti. Each snapshot defines a network.


# ==========================
kd.epurate_data_after! "2009-12-31"
kd.refresh! :method => :comments_in_group

suffix = "-2009-12-31_no-club"

kd.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd.export_graphml "export/kublai#{suffix}.graphml"
kd.export_pajek "export/kublai#{suffix}.net"
kd.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"

# ==========================
kd.epurate_data_after! "2009-05-15"
kd.refresh! :method => :comments_in_group

suffix = "-2009-05-15_no-club"

kd.export_csv "export/nodes#{suffix}.csv", "export/edges#{suffix}.csv"
kd.export_graphml "export/kublai#{suffix}.graphml"
kd.export_pajek "export/kublai#{suffix}.net"
kd.export_pajek_use_names "export/kublai#{suffix}-NAMES.net"

# ==========================

# Gephi: https://gephi.org/users/supported-graph-formats/
# 
# Pajek: http://www.ccsr.ac.uk/methods/publications/snacourse/netdata.html
# 
# GraphML http://graphml.graphdrawing.org/primer/graphml-primer.html
# 
# A occhio, per me sarebbe più semplice Gephi, ma per te (che sai programmare) è probabilmente più semplice scriverti un programmino che "traduce" in Pajek.

# {"id":"2089256:Group:29729","contributorName":"5sn9vtte6got","title":"Club dei Progettisti","description":"Dove i kublaiani pi\u00f9 esperti si organizzano per migliorare la \"loro\" Kublai e dare una mano ai novellini. Iscriviti e contribuisci a fare di Kublai un posto pi\u00f9 accogliente!","createdDate":"2009-02-23T17:02:05.454Z","updatedDate":"2010-12-08T20:23:19.119Z","approved":"Y","allowInvitationRequests":"Y","allowInvitations":"Y","allowMemberMessaging":"Y","groupPrivac

