module Test
  extend ActiveSupport::Concern

	class A
    def create_cv(picture_url, summary)
    	cv = Cv.create(:user_id => self.id, :picture_filename => picture_url, :summary => summary)
    end
  end
    

end