
# {"iconUrl"=>"http://api.ning.com:80/files/qwertyuiop/altre2copia.jpg", 
#   "updatedDate"=>"2010-12-21T19:31:07.164Z", 
#   "comments"=> XXXXXXXX
#   "groupPrivacy"=>"public", 
#   "createdDate"=>"2010-12-19T23:46:55.381Z", 
#   "url"=>"altrementi", 
#   "memberCount"=>"8", 
#   "allowMemberMessaging"=>"Y", 
#   "approved"=>"Y", 
#   "id"=>"2089256:Group:94806", 
#   "allowInvitationRequests"=>"Y", 
#   "members"=> XXXXXXXXXXX
#   "description"=>"<p>Questa rivista è dedicata a chi ha coraggio, a chi esplora, a chi crede  nei propri desideri e non rinuncia ad inseguire i propri sogni.</p>", 
#   "tilte"=>"Altrementi", 
#   "contributorName"=>"12345qwertyuiop", 
#   "allowInvitations"=>"Y"}
# 
# "comments"=>[
#   {"createdDate"=>"2010-12-21T09:40:41.314Z", 
#     "id"=>"2089256:Comment:95208", 
#     "description"=>"<p>Si, l'avevo intuito ;-)</p>", 
#     "contributorName"=>"12345qwertyuiop"},
# 
# "members"=>[
#   {"fullName"=>"John Doe", 
#     "contributorName"=>"12345qwertyuiop", 
#     "status"=>"admin"},
#   


class KublaiElement

  # THIS MUST BE OVERRIDDEN
  def legal_attributes
    [ ] 
  end
  
  def method_missing name, *args
    @data[name.to_s]
  end  
  
  def existed_at? date_as_string
    self.createdDate[0..date_as_string.size-1] < date_as_string
  end
  
private
  def default_values! hash, attribs
    attribs.keys.each do |k|
      default_value! hash, k, attribs[k]
    end
  end

  def default_value! hash, key, def_val
    hash[key] = def_val if not hash.include? key
  end

  def verify_well_formedness! hash
    verify_all_keys_are_legal! hash
    verify_all_attributes_are_present! hash
  end

  def verify_all_keys_are_legal! hash
    hash.keys.each do |k|
      if not legal_attributes.include? k
        raise "#{self.class.name} PARSE ERROR: Wrong key >>#{k}<< in data: #{hash.inspect}"
      end
    end    
  end

  def verify_all_attributes_are_present! hash
    legal_attributes.each do |att|
      if not hash.keys.include? att
        raise "#{self.class.name} PARSE ERROR: Missing key >>#{att}<< in data: #{hash.inspect}"
      end
    end
  end
  
end

class KublaiGroup < KublaiElement
  def legal_attributes
    %w(allowInvitationRequests allowInvitations allowMemberMessaging approved comments contributorName createdDate description groupPrivacy iconUrl id memberCount members title updatedDate url isPrivate)
  end
  
  def initialize hash
    default_values! hash, 'iconUrl'=>'', 
                          'description'=>'',
                          'approved'=>'N',
                          'comments'=>[],
                          'isPrivate'=>false
      
    verify_well_formedness! hash
    
    @data = hash
    @data['gid'] = @data['id']
    @data['members'] = parse_members @data['members']
    @data['comments'] = parse_comments @data['comments']    
  end

  def epurate_data_after! date_as_string
    @data['comments'] = @data['comments'].select{|c| c.existed_at? date_as_string}
  end
  
private

  def parse_members ary
    ary.map{|e| KublaiGroupMember.new e}
  end
  
  def parse_comments ary
    ary.map{|e| KublaiComment.new e}
  end
end

class KublaiGroupMember < KublaiElement
  def legal_attributes
    %w(contributorName)
  end
  
  def initialize hash
    verify_well_formedness! hash
    @data = hash
  end  
end

class KublaiComment < KublaiElement
  def legal_attributes
    %w(createdDate id description contributorName fileAttachments)
  end
  
  def initialize hash
    default_values! hash, 'fileAttachments'=>[]
    
    verify_well_formedness! hash
    @data = hash
  end  
  
end


# {"profilePhoto"=>"http://api.ning.com/files/a_file.png?crop=1%3A1", 
#   "location"=>"Roma", 
#   "birthdate"=>"1900-01-01", 
#   "country"=>"IT", 
#   "createdDate"=>"2010-12-24T17:16:07.974Z", 
#   "level"=>"member", 
#   "fullName"=>"John Doe", 
#   "gender"=>"m", 
   # "comments"=>[
   #   {"createdDate"=>"2010-12-21T13:08:57.730Z", 
   #     "id"=>"2089256:Comment:95110", 
   #     "description"=>"<p>Ciao Luca,</p>\n<p>benvento in kublai.</p>", 
   #     "contributorName"=>"6789asdfghjkl"}
   #     ]
#   "profileQuestions"=>{
#     "Relationship Status:"=>"Single", 
#     "Mi interesso di..."=>"cinema e audiovisivo, informazione, tecnologia, scienza, letteratura, ambiente ed ecologia", 
#     "Website:"=>"<a href=\"http://www.wordpress.com\">http://www.wordpress.com</a>"}, 
#   "contributorName"=>"12345qwertyuiop", 
#   "state"=>"active", 
#   "email"=>"an_email@example.com"}
# 

class KublaiMember < KublaiElement
  def legal_attributes
    %w( createdDate contributorName comments state )
  end

  def initialize hash
    default_values! hash, 'comments'=>[]
                          
    verify_well_formedness! hash
    @data = hash
  end

end

# 
# {"updatedDate"=>"2010-12-20T06:58:43.058Z", 
#   "createdDate"=>"2010-12-20T06:57:13.302Z", 
#   "title"=>"REPORT 2010 – dodici mesi con il Progetto Reti Glocali e AUGURI di buone feste !", 
#   "id"=>"2089256:Topic:94905", 
#   "groupId"=>"2089256:Group:33100", 
#   "description"=>"<p><strong>Segnalo agli amici di Kublai</strong> che (come l'anno scorso) è disponibile il resoconto delle attività svolte da Reti Glocali nel corso del 2010 e ... qualche buon proposito per il 2011.</p>\n<p> </p>\n<p>Buone feste ! :-)</p>\n<p> </p>\n<p style=\"text-align: center;\"><span style=\"font-size: x-large;\"><a href=\"http://www.slideshare.net/Enrige/report-2010-dodici-mesi-con-reti-glocali\" target=\"_self\">REPORT 2010</a></span></p>", 
#   "contributorName"=>"12345qwertyuiop"}
# 
# {"createdDate"=>"2010-12-22T12:55:14.206Z", 
#   "id"=>"2089256:Comment:95113", 
#   "description"=>"<p>La mappa che ho abbozzato al volo per questioni di tempo, è solo la punta di iceberg di un progetto complesso, che ho in mente, che riguarda un possibile terremoto nel servizio creditizio, che io non conosco bene ....ma voi si.</p>\n<p>Ma mettendo insieme queste intuizioni, servizi ed i portatori di interesse si possono immaginare dinamiche nuove e interessanti!.</p>", 
#   "contributorName"=>"12345qwertyuiop"}
# 

class KublaiDiscussion < KublaiElement
  def legal_attributes
    %w(updatedDate createdDate title id groupId description contributorName comments fileAttachments category isPrivate)
  end

  def initialize hash
    default_values! hash, 'comments'=>[],
                          'description'=>'',
                          'fileAttachments'=>[],
                          'category'=>'',
                          'groupId'=>'',
                          'isPrivate'=>false
    
    verify_well_formedness! hash
    @data = hash
    
    @data['did'] = @data['id']
    @data['comments'] = parse_comments @data['comments'] if @data['comments']
  end

  def epurate_data_after! date_as_string
    @data['comments'] = @data['comments'].select{|c| c.existed_at? date_as_string}
  end
  
private
  def parse_comments ary
    ary.map{|e| KublaiComment.new e}
  end

end