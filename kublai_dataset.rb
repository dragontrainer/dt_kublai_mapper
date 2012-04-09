require 'kublai_parse'

# #### AUGMENT with Inter-Entity Relationships ####

class KublaiDiscussion
  def contributors
    comments.map{|c| c.contributorName}.uniq
  end
  
  def comments_by contributor
    comments.select{|c| c.contributorName == contributor}
  end

  # TODO: refactor this and KublaiGroup to a new KublaiCommentable Module or something
  def non_zero_bidirectional_relationships
    # contributors X contributors, excluding A x A, where contributor belongs to Group
    cs = contributors

    num_comments = {}
    cs.each{|c| num_comments[c] = comments_by(c).size }

    relationships = []
    
    for c_a in cs
      for c_b in (cs - [c_a])
        relationships << BidiRelationship.new( c_a,c_b, num_comments[c_a] * num_comments[c_b])
      end
    end
    
    return relationships
  end

end

class KublaiGroup
  
  # I commenti a un progetto sono sia i commenti sul wall del progetto che le discussioni e i commenti alle discussioni sul thread di quel progetto. 
  
  def comments_by contributor
    comments_on_the_wall_by(contributor) + comments_in_discussions_by(contributor)
  end
  
  def comments_on_the_wall_by contributor
    comments.select{|c| c.contributorName == contributor}
  end

  def comments_in_discussions_by contributor
    return [] if not @discussions
    @discussions.map{|d| d.comments_by contributor}.flatten
  end
    
  def contributors
    (contributors_to_wall + contributors_to_discussions).uniq
  end

  def contributors_to_wall
    comments.map{|c| c.contributorName}.uniq
  end

  def contributors_to_discussions
    return [] if not @discussions
    @discussions.map{|d| d.contributors}.flatten.uniq
  end
  
  def add_discussion discussion
    @discussions ||= []
    @discussions << discussion
  end  
  
  def delete_discussions!
    @discussions = []
  end
  
  # La relazione costruita al tempo da me e Ruggero è questa:
  # 
  # A e B sono collegati da un link bidirezionale e pesato (di intensità non solo 0 o 1, ma che può assumere un qualunque valore positivo) che è dato dalla somma in i del prodotto del numero di commenti lasciati da A per il numero di commenti lasciati da B su tutti gli i progetti di Kublai. 
  # 
  # Sui progetti a cui commenta solo uno o nessuno tra A e B questo prodotto sarà naturalmente 0. Sui progetti a cui partecipano entrambi sarà un numero positivo. 
  
  # TODO: refactor this and KublaiDiscussion to a new KublaiCommentable Module or something
  def non_zero_bidirectional_relationships
    # contributors X contributors, excluding A x A, where contributor belongs to Group

    cs = contributors

    num_comments = {}
    cs.each{|c| num_comments[c] = comments_by(c).size }

    relationships = []
    
    for c_a in cs
      for c_b in (cs - [c_a])
        relationships << BidiRelationship.new( c_a,c_b, num_comments[c_a] * num_comments[c_b])
      end
    end
    
    return relationships
  end

  def non_zero_bidirectional_relationships2
    # contributors X contributors, excluding A x A, where contributor belongs to Discussion    
    return non_zero_bidirectional_relationships_on_wall() + 
           @discussions.map{|d| d.non_zero_bidirectional_relationships}.flatten
  end

  def non_zero_bidirectional_relationships_on_wall
    cs = contributors_to_wall

    num_comments = {}
    cs.each{|c| num_comments[c] = comments_on_the_wall_by(c).size }

    relationships = []
    
    for c_a in cs
      for c_b in (cs - [c_a])
        relationships << BidiRelationship.new( c_a,c_b, num_comments[c_a] * num_comments[c_b])
      end
    end
    
    return relationships
  end

  
end


# bidirectional relationship
class BidiRelationship
  attr_reader :a, :b, :weight
  
  def initialize node_a, node_b, weight
    @a = node_a
    @b = node_b
    @weight = weight
  end
  
  def same_nodes? bidirelationship2
    self.sorted_nodes == bidirelationship2.sorted_nodes
  end  
  
  def has_contributor? contributor
    @a == contributor or @b == contributor
  end
  
  def includes? contributor_list
    contributor_list.any?{|c| self.has_contributor? c}
  end
  
  def random_nodes
    [@a,@b]
  end
  
  def sorted_nodes
    random_nodes.sort
  end

  # I use this as an hack to speed up things 
  def nodes_signature
    sorted_nodes.join '-'
  end

  def add! bidirelationship2
    raise "ERROR: BidiRelationship cannot add to #{self} a relationship #{bidirelationship2} with different nodes." if not self.same_nodes? bidirelationship2
    @weight += bidirelationship2.weight
  end
  
  def to_s
    "#{@a}<---#{@weight}--->#{@b}"
  end    
end


class KublaiDataset
  def bidis
    @bidirelationships
  end
  def initialize args
    jgroups = JSON.parse args[:json_groups]
    @groups = jgroups.map{|g| KublaiGroup.new g}

    jdiscussions = JSON.parse args[:json_discussions]
    @discussions = jdiscussions.map{|d| KublaiDiscussion.new d}

    jmembers = JSON.parse args[:json_members]
    @members = jmembers.map{|d| KublaiMember.new d}        
  end

  def refresh! opts={}
    delete_discussions_from_groups! @groups
    add_discussions_to_groups! @groups, @discussions
    
    puts
    puts "groups num"
    puts @groups.size
    puts

    @bidirelationships = extract_bidirelationships @groups, opts

    puts
    puts "bidirelationships num"
    puts @bidirelationships.size
    puts

    if opts[:no_weight_lesser_than]
      @bidirelationships.reject!{|r| r.weight < opts[:no_weight_lesser_than]}
      puts "FILTERING BY WEIGHT.. < #{opts[:no_weight_lesser_than]}"
      puts 
      puts "bidirelationships num"
      puts @bidirelationships.size
      puts
    end

    if opts[:no_weight_greater_than]
      @bidirelationships.reject!{|r| r.weight < opts[:no_weight_greater_than]}
      puts "FILTERING BY WEIGHT.. < #{opts[:no_weight_greater_than]}"
      puts 
      puts "bidirelationships num"
      puts @bidirelationships.size
      puts
    end

    if opts[:exclude_contributors]
      @bidirelationships.reject!{|r| r.includes? opts[:exclude_contributors]}
      puts "FILTERING BY CONTRIBUTORS.. "
      puts 
      puts "bidirelationships num"
      puts @bidirelationships.size
      puts
    end

    
    @contributors = @bidirelationships.map{|r| r.random_nodes}.flatten.uniq

    puts
    puts "contributors num"
    puts @contributors.size
    puts
  end
  
  def export_csv nodes_filename, edges_filename
    write_file nodes_filename, @contributors.join("\n") 
    write_file edges_filename, @bidirelationships.map{|r| (r.sorted_nodes+[r.weight]).join(',') }.join("\n") 

    puts
    puts "EXPORT CSV DONE"
    puts
  end

# ====================
  def export_csv_use_names nodes_filename, edges_filename
    
    names = {}

    @contributors.each_with_index do |c,i|

      name = @members.find{|m| m.contributorName == c}.fullName

      j = 2
      while names.values.include? name
        name = "#{name} #{j}"
        j+=1
      end

      names[c] = name
    end
    
    write_file nodes_filename, names.values.join("\n") 
    write_file edges_filename, @bidirelationships.map{|r| ([names[r.sorted_nodes.first],names[r.sorted_nodes.last],r.weight]).join(',') }.join("\n") 

    puts
    puts "EXPORT CSV DONE"
    puts
  end

  def export_foaf filename
    write_file filename, convert_to_foaf(@bidirelationships)

    puts
    puts "EXPORT FOAF DONE"
    puts
  end

  def export_graphml filename
    write_file filename, convert_to_graphml(@bidirelationships)

    puts
    puts "EXPORT GRAPHML DONE"
    puts
  end

  def export_pajek filename
    write_file filename, convert_to_pajek(@bidirelationships)

    puts
    puts "EXPORT PAJEK DONE"
    puts
  end
  
  def export_pajek_use_names filename
    write_file filename, convert_to_pajek_use_names(@bidirelationships)

    puts
    puts "EXPORT PAJEK DONE"
    puts
  end
  
  def epurate_data_after! date_as_string
    @groups = @groups.select{|g| g.existed_at? date_as_string}
    @members = @members.select{|m| m.existed_at? date_as_string}
    @discussions = @discussions.select{|d| d.existed_at? date_as_string}

    @groups.each{|g| g.epurate_data_after! date_as_string}
    @discussions.each{|d| d.epurate_data_after! date_as_string}
  end

  def epurate_groups! groups
    @groups = @groups.reject{|g| groups.include? g.gid }
    @discussions = @discussions.reject{|d| groups.include? d.groupId }
  end

private
  def delete_discussions_from_groups! groups
    groups.each{|g| g.delete_discussions!}
  end

  def add_discussions_to_groups! groups, discussions
    for d in discussions
      linked_groups = groups.select{|g| g.gid == d.groupId}
    
      puts "WARNING: Discussion #{d.did} matches several groups with groupId [#{d.groupId}]." if linked_groups.size > 1
      puts "WARNING: Discussion #{d.did} has groupId [#{d.groupId}] and links to no group." if linked_groups.empty?
    
      linked_groups.first.add_discussion d unless linked_groups.empty?
    end
  end

  # Se tutti e due commentano più di un progetto si calcola il prodotto del numero dei commenti di A x il numero dei commenti di B per ciascun progetto, poi si sommano i numeri contenuti. Per esempio, se io e te abbiamo due progetti in comune, e in uno io ho lasciato tre commenti e tu uno, mentre nell'altro io ho lasciato due commenti e tu altri due, io e te siamo collegati da un link di intensità ( 3 x 1 ) + ( 2 x 2 ) = 7.
  # I commenti sui profili non contano.

  def extract_bidirelationships groups, opts
    bidirelationships = {}

    i=0
    for g in groups

      if opts[:method] == :comments_in_discussion
        new_relationships = g.non_zero_bidirectional_relationships2
      elsif opts[:method] == :comments_in_group
        new_relationships = g.non_zero_bidirectional_relationships
      end
      
      for r in new_relationships
        if bidirelationships[r.nodes_signature]
          bidirelationships[r.nodes_signature].add! r 
        else
          bidirelationships[r.nodes_signature] = r
        end

        i+=1; puts i if rand(100) == 50
      end

    end

    return bidirelationships.values
  end

  def convert_to_graphml bidirelationships
    contributors = bidirelationships.map{|r| r.random_nodes}.flatten.uniq

    gml = %{  <graphml xmlns="http://graphml.graphdrawing.org/xmlns"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
      http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
      <key id="d1" for="edge" attr.name="weight" attr.type="double"/>
      <graph id="G" edgedefault="undirected">

    }

    gml << contributors.map{|c| "    <node id=\"#{c}\"/>"}.join("\n")

    bidirelationships.each_with_index do |r,i| 
      gml << %{    <edge id="e#{i}" source="#{r.sorted_nodes.first}" target="#{r.sorted_nodes.last}"><data key="d1">#{r.weight}</data></edge> } + "\n"
    end

    gml << %{
      </graph>
      </graphml>  
    }

    return gml
  end    

  def convert_to_foaf bidirelationships
    subjects = bidirelationships.inject(Hash.new) do |h, rel|
                h[rel.a] ||= []
                h[rel.a] << rel.b
                h
             end
      

    foaf = %{<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
             xmlns:foaf="http://xmlns.com/foaf/0.1/">

    }
    
    subjects.each do |key, values|
      foaf << %{<foaf:Person rdf:ID="#{key}">
          <foaf:name>#{key}</foaf:name>
          #{values.map{|v| %{<foaf:knows rdf:resource="##{v}" />}}.join("\n")}
        </foaf:Person>
      }      
    end

    foaf << %{</rdf:RDF>}

    return foaf
  end    
  
  def convert_to_pajek bidirelationships
    contributors = bidirelationships.map{|r| r.random_nodes}.flatten.uniq

    pajek = "*Vertices #{contributors.size}" +"\r\n"

    contributors.each_with_index do |c,i|
      pajek << %{#{i+1} "#{c}"}+"\r\n"
    end

    pajek << "*Edges"+"\r\n"

    bidirelationships.each do |r| 
      a = contributors.index(r.sorted_nodes.first)+1
      b = contributors.index(r.sorted_nodes.last)+1
      pajek << %{#{a} #{b} #{r.weight}}+"\r\n"
    end

    return pajek
  end

  def convert_to_pajek_use_names bidirelationships
    contributors = bidirelationships.map{|r| r.random_nodes}.flatten.uniq

    pajek = "*Vertices #{contributors.size}" +"\r\n"

    names = {}

    contributors.each_with_index do |c,i|

      name = @members.find{|m| m.contributorName == c}.fullName

      j = 2
      while names.values.include? name
        name = "#{name} #{j}"
        j+=1
      end

      names[c] = name
        
      pajek << %{#{i+1} "#{name}"}+"\r\n"
    end

    pajek << "*Edges"+"\r\n"

    bidirelationships.each do |r| 
      a = contributors.index(r.sorted_nodes.first)+1
      b = contributors.index(r.sorted_nodes.last)+1
      pajek << %{#{a} #{b} #{r.weight}}+"\r\n"
    end

    return pajek
  end

  def write_file filename, content
    File.open(filename, 'w') {|f| f.write content }
  end
  
end
