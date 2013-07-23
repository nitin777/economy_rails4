class FrontsController < ApplicationController
	require 'builder'
  before_filter :require_user, :only => [:change_password, :cv_xml, :invite, :feedbacks]
  before_filter :set_header_menu_active
  
  #dashboard
  def dashboard
  	if current_user
  		#fetch linkedin data
  		unless is_admin?
  			@linkedin_data = generate_linkedin_profile_data(current_user, params[:refresh])
  			@user = User.find(current_user.id)
  		end	
  	end	
  end

	#forgot password
  def forgot_password
		@user = User.new
		if params[:user]
			if user = authenticate_email(params[:user][:email])
				new_pass = SecureRandom.hex(5)
				user.password = user.password_confirmation = new_pass
				user.save
				body = render_to_string(:partial => "common/forgot_password_mail", :locals => { :username => user.username, :new_pass => new_pass }, :formats => [:html])
				body = body.html_safe
				UserMailer.forgot_password_confirmation(user.email, new_pass, body).deliver
				@user_session = UserSession.find
				if @user_session
					@user_session.destroy
				end
				session[:user_id] = nil
				flash[:notice] = t("general.password_has_been_sent_to_your_email_address")
				redirect_to root_path 
			else
				flash[:forgot_pass_error] = t("general.no_user_exists_for_provided_email_address")
				redirect_to :action => "forgot_password"
			end
		end	
  end

	#change password
  def change_password
  	@o_single = User.find(current_user.id)
  	if params[:user]
		  @o_single.password = params[:user][:password]
		  @o_single.password_confirmation = params[:user][:password_confirmation]
		  @o_single.password_required = true
	    respond_to do |format|
	      if @o_single.update_attributes(user_params)
	        format.html { redirect_to users_url, notice: t("general.successfully_updated") }
	        format.json { head :no_content }
	      else
	        format.html { render action: 'change_password' }
	        format.json { render json: @o_single.errors, status: :unprocessable_entity }
	      end
	    end
	  end  
  end
  
  #subscribe user through linkedin
  def subscribe
  end
 
 	#authenticate user though linkedin network
  def auth_linkedin_login
		auth_hash = request.env['omniauth.auth']
		auth_response = Authorization.find_or_create_linkedin_user(auth_hash)
		# Create the session
		user = auth_response.user
		session[:user_id] = user.id
		session[:user_role] = USER
		user_session = UserSession.create(user)
		user_session.save
		flash.keep[:notice] = t("general.login_successful")
		redirect_to session[:tracking_pixel] ? leave_feedback_path : dashboard_path
  end
  
	#footer and other static pages
  def other
  	@o_single = StaticPage.where(page_route: params[:fp]).first
  end
  
  #download cv data as xml
  def cv_xml
		cv_data = current_user.prepare_xml_data
		 send_data cv_data.to_xml(:root => 'cv', :skip_types => true, :compact => true), 
											 :type => "text/xml", 
											 :charset => "UTF-8", 
											 :disposition => "attachment", 
											 :filename => "#{current_user.user_name}.xml"
  end
  
  #verify is email already invited
  def is_email_invited
  	render json: invite_email_exists?(params[:email]) 
  end
  
  #invite user and send cv as html
  def invite
		@user = User.new
		if params[:user]
			is_invited = invite_email_exists?(params[:user][:email])
			if is_invited[:result] == false
				#user role invite create 
	    	invited_user = User.create(:username => params[:user][:email],
	    									:email => params[:user][:email],
	    									:register_token => SecureRandom.hex(15),
	    									:is_provider => true)
	    	invited_user.save(:validate => false)								
				invited_user.role = Role.find_by_role_type("User")
				invite = Invite.create(:inviting_user_id => current_user.id, :invited_user_id => invited_user.id, :tracking_pixel => SecureRandom.hex(15), :is_original => true)
			else
				invited_user = User.find_by_email(params[:user][:email])
				invite = Invite.find_by_inviting_user_id_and_invited_user_id(current_user.id, invited_user.id)
				if invite
					invite.created_at = Time.now
				else
					invite = Invite.create(:inviting_user_id => current_user.id, :invited_user_id => invited_user.id, :tracking_pixel => SecureRandom.hex(15), :is_original => true)
				end	
			end
			
			#options
			opts = {:username => current_user.name, :invited_user => invited_user.name, :contact => current_user.mobile}
			
			#subject
			subject = "#{t('general.online_cv_from')} #{current_user.name}"
			
			#attachment
			user_cv_data = current_user.prepare_xml_data
			 
			user_cv = render_to_string(:partial => "common/user_cv", :locals => { :user => current_user, :user_cv_data => user_cv_data, :invite => invite }, :formats => [:html])
			
			user_cv_file = "#{Rails.public_path}/uploads/cv/CV_#{current_user.first_name}-#{current_user.last_name}.html"
			
			File.open(user_cv_file, 'w') {|f| f.write(user_cv) }
			
			#send mail
			UserMailer.invite_user_confirmation(invited_user.email, subject, current_user, opts).deliver
			
			flash.discard[:notice] = t("general.invitation_has_been_sent", email: invited_user.email)
		end	
  end
  
  #give feedback on CV
  def feedback
  	@invite = Invite.find_by_tracking_pixel(params[:tracking_pixel])
  	if @invite
  		@invite.is_read = true
  		@invite.save
  		ReadLog.find_or_create_by_inviting_user_id_and_invited_user_id(@invite.inviting_user_id, @invite.invited_user_id)
  		session[:tracking_pixel] = params[:tracking_pixel]
  		redirect_to leave_feedback_path if current_user
  	end
  end
  
  def leave_feedback
  	@invite = Invite.find_by_tracking_pixel(session[:tracking_pixel])
  	if current_user
	  	if params[:invite]
	  		if @invite
	  			@invite.feedback = params[:invite][:feedback]
	  			@invite.feedback_date = Time.now
	  			@invite.save
	  			flash.discard[:notice] = t("general.feedback_has_been_sent", email: @invite.inviting.name)
	  		end
	  	else
	  		invite = Invite.find_by_tracking_pixel(session[:tracking_pixel])
	  		unless current_user.id == invite.invited_user_id
	  			invite_create = Invite.create(:inviting_user_id => invite.inviting_user_id, :invited_user_id => current_user.id, :tracking_pixel => SecureRandom.hex(15), :is_read => true)
	  			session[:tracking_pixel] = invite_create.tracking_pixel
	  			redirect_to leave_feedback_path
	  			return 
	  		end		
			end
		end	
  end
  
  #show all feedbacks of user
  def feedbacks
  	@feedbacks = current_user.invitings.where(:is_read => true).paginate(:per_page => 10, :page => params[:page])
  	user_inviting = current_user.invitings.where(:is_read => true).select("count(id) as id, feedback_date").group("feedback_date")

    #User CV saw line chart
  	result_data = user_saw_cv_data(user_inviting)
  	create_saw_cv_chart(result_data)
  end  

	private
 	
  #fetch user inviting data and set into chart format 
  def user_saw_cv_data(user_inviting)
  	usr_inv = {}
  	user_inviting.each do |i|
  		usr_inv[i.feedback_date.to_s] = i.id
  	end
  	
  	result_arr = []
  	for i in 0..30
  		data_arr = []
    	tmp_date = Date.today - i.days
    	
    	data_arr << Date.parse(tmp_date.to_s).strftime('%b %e')
    	if usr_inv[tmp_date.to_s]
    		data_arr << usr_inv[tmp_date.to_s]
    	else
    		data_arr << 0
    	end
    	result_arr << data_arr 
    end
    return result_arr 
  end   	
 	
  #load user cv saw chart
  def create_saw_cv_chart(data)
		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Date' )
		data_table.new_column('number', 'CV Read')
		data_table.add_rows(data)
		vaxes = [{format: "#", viewWindow: {min: 0}}]	
		option = { width: "1000", height: 200, areaOpacity: 0, vAxes: vaxes, title: "", isStacked: true }
		@user_cv_chart = GoogleVisualr::Interactive::LineChart.new(data_table, option)
	end
	
 	#fetch all linkeding profile data
  def generate_linkedin_profile_data(current_selected_user, refresh)

    if !current_selected_user.has_cv? or refresh
  		#authorization
    	linkedin_auth = Authorization.find_by_provider_and_user_id(:linkedin, current_selected_user.id)   
	    if linkedin_auth.present?
	    	begin
		    	#destoy data if refresh
		    	if refresh and current_selected_user.cv
		    		Cv.destroy(current_selected_user.cv.id)
		  		end		    		
		      token = linkedin_auth.token
		      secret = linkedin_auth.secret
		      client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET)
		      client.authorize_from_access(token, secret)
		      user = client.profile(:fields => %w(positions skills languages:(language,proficiency) educations date-of-birth phone-numbers summary picture-url headline))

		      #cv
		      current_user.create_cv(user.picture_url, user.summary)
		      #positions
		      current_user.create_positions(user.positions) unless user.positions.all.nil? 
		      #skills
		      current_user.create_skills(user.skills) unless user.skills.nil?
		      #language
		      current_user.create_languages(user.languages) unless user.languages.nil?
					#educations        
		      current_user.create_educations(user.educations) unless user.educations.all.nil?
		      #personal details
					current_user.personal_details(user.date_of_birth, user.headline, user.phone_numbers)
					
					flash.discard[:notice] = t("general.successfully_imported_profile")
        rescue Exception => e
          flash.discard[:error_profile] = t("general.error_linkedin_profile")
        end					
	  	end
		end
  end

	#date format set for experience start and end date
	def check_date_positions(position)
    if position.start_date.present? && position.start_date.month.present?
      start_date = "#{position.start_date.year}-#{position.start_date.month}-01"
      if position.is_current
        end_date = Date.today.to_s
      else
        end_date = "#{position.end_date.year}-#{position.end_date.month}-01"
      end
      return [start_date, end_date]
    end
	end
	
  def set_header_menu_active
    @dashboard = true
  end 

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end   
  
end
