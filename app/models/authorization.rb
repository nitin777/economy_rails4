class Authorization < ActiveRecord::Base
  #attr_accessible :provider, :uid, :user_id
  belongs_to :user
  
	def self.find_or_create_linkedin_user(auth_hash)
		auth = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
	  unless auth
	  	auth = self.create_social_user(auth_hash["info"], auth_hash['credentials'], auth_hash["provider"], auth_hash["uid"])
	  else
	  	auth = self.update_social_user(auth, auth_hash["info"], auth_hash['credentials'])
	  end
	  auth
	end
	
	def self.create_social_user(auth_hash, credentials, provider, uid)
		#user
		usr = User.find_by_email(auth_hash["email"])
		unless usr
	    usr = User.create(:username => auth_hash["name"],
	    									:email => auth_hash["email"],
	    									:first_name => auth_hash["first_name"],
	    									:last_name => auth_hash["last_name"],
	    									:address => auth_hash["location"],
	    									:image => auth_hash["image"],
	    									:contact => auth_hash["urls"]["public_profile"],
	    									:phone => auth_hash["phone"],
	    									:is_provider => true)
	    usr.save(:validate => false)
	  else
	  	usr.phone = auth_hash["phone"]
	  	usr.username = auth_hash["name"]
			usr.first_name = auth_hash["first_name"]
			usr.last_name = auth_hash["last_name"]
			usr.address = auth_hash["location"]
			usr.image = auth_hash["image"]
			usr.contact = auth_hash["urls"]["public_profile"]	  	
			usr.is_provider = true
	  	usr.save(:validate => false)	  	
	  end  
    #role		
    usr.role = Role.find_by_role_type("User")
    #authorization
    auth = create :user_id => usr.id,
    							:provider => provider,
    							:uid => uid, 
    							:token => credentials['token'], 
    							:secret => credentials['secret'], 
    							:screen_name => auth_hash['name']
    auth.save							    
    return auth
	end
	
	def self.update_social_user(auth, auth_hash, credentials)
		#user
  	usr = auth.user
  	usr.phone = auth_hash["phone"]
  	usr.username = auth_hash["name"]
		usr.email = auth_hash["email"]
		usr.first_name = auth_hash["first_name"]
		usr.last_name = auth_hash["last_name"]
		usr.address = auth_hash["location"]
		usr.image = auth_hash["image"]
		usr.contact = auth_hash["urls"]["public_profile"]	  	
  	usr.save(:validate => false)
  	#authoraization
  	auth.token = credentials['token']
  	auth.secret = credentials['secret']
  	auth.screen_name = auth_hash["name"]
  	auth.save
  	return auth
	end	
end
