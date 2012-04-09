require 'kublai_parse'

# #### AUGMENT with Inter-Entity Relationships ####

class KublaiDiscussion
  def contributors
    ([[contributorName, createdDate.to_s[0..9]]]+comments.map{|c| [c.contributorName,c.createdDate.to_s[0..9]]}).uniq
  end
  
  def comments_by contributor
    comments.select{|c| c.contributorName == contributor}
  end

  def bidirectional_relationships
    cs = contributors

    relationships = []
    
    for c_a, c_a_d in cs
      for c_b, c_b_d in cs
        relationships << BidiRelationship.new( c_a, c_b, c_b_d, did, groupId) unless c_a == c_b
      end
    end
    
    return relationships
  end

end


# bidirectional relationship
class BidiRelationship
  attr_reader :a, :b, :timestamp, :topic, :group
  
  def initialize node_a, node_b, timestamp, topic, group
    @a = node_a
    @b = node_b
    @timestamp = timestamp
    @topic = topic
    @group = group
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
    ([timestamp, topic]+sorted_nodes).join('-')
  end
    
  def to_s
    "[#{@timestamp}] #{@a}<---#{@group}|#{@topic}--->#{@b}"
  end    
end


class KublaiFineDataset
  def bidirelationships
    @bidirelationships
  end
  def discussions
    @discussions
  end
  def initialize args
    jdiscussions = JSON.parse args[:json_discussions]
    @discussions = jdiscussions.map{|d| KublaiDiscussion.new d}
  end

  def refresh! opts={}
    
    @bidirelationships = extract_bidirelationships @discussions, opts

    puts
    puts "bidirelationships num"
    puts @bidirelationships.size
    puts
    
    @contributors = @bidirelationships.map{|r| r.random_nodes}.flatten.uniq

    puts
    puts "contributors num"
    puts @contributors.size
    puts
  end
  
  def export_csv nodes_filename, edges_filename
    write_file nodes_filename, @contributors.join("\n") 
    write_file edges_filename, @bidirelationships.map{|r| (r.sorted_nodes+[r.timestamp, r.topic, r.group]).join(',') }.join("\n") 

    puts
    puts "EXPORT CSV DONE"
    puts
  end
  
# private

  # Se tutti e due commentano più di un progetto si calcola il prodotto del numero dei commenti di A x il numero dei commenti di B per ciascun progetto, poi si sommano i numeri contenuti. Per esempio, se io e te abbiamo due progetti in comune, e in uno io ho lasciato tre commenti e tu uno, mentre nell'altro io ho lasciato due commenti e tu altri due, io e te siamo collegati da un link di intensità ( 3 x 1 ) + ( 2 x 2 ) = 7.
  # I commenti sui profili non contano.

  def extract_bidirelationships discussions, opts
    bidirelationships = {}

    i=0
    for d in discussions
      next if opts[:exclude_groups].respond_to?(:include?) && opts[:exclude_groups].include?(d.groupId)
      
      new_relationships = d.bidirectional_relationships
      
      for r in new_relationships
        next if opts[:exclude_contributors].respond_to?(:include?) && r.random_nodes.any?{|c| opts[:exclude_contributors].include?(c) } 
        
        bidirelationships[r.nodes_signature] = r

        i+=1; puts i if rand(100) == 50
      end

    end

    return bidirelationships.values
  end

  def write_file filename, content
    File.open(filename, 'w') {|f| f.write content }
  end
  
end
