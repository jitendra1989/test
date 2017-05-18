class GuardiansController < ApplicationController
#com
    before_filter :login_required
	layout "mindcom"

	def search_guardian_data

	   # @guardianList = MgGuardian.where("first_name LIKE :fname OR last_name LIKE :lname",{:fname => "%#{params[:searchData]}%",:lname => "%#{params[:searchData]}%"})

   	#   respond_to do |format|
    #     format.json  { render :json => @guardianList }
    #   end

        if params[:student].nil?
    	@guardians = MgGuardian.where("first_name LIKE :fname",{:fname => "%"}).paginate(page: params[:page], per_page: 10)
    else
		@guardians = MgGuardian.where("first_name LIKE :fname",{:fname => "#{params[:student][:searchData]}%"}).paginate(page: params[:page], per_page: 10)
    end
		
	end

	def student_guardian_create
		puts "It comming here"

	#	"relation":relation,"mg_student_id":CurrentStudentID,"mg_guardians_id":currentGuardianID

		relation = params[:relation]
		student_id = params[:mg_student_id]
		guardians_id = params[:mg_guardians_id]

		# puts relation
		# puts student_id
		# puts guardians_id

		@studentGuardianDetails = MgStudentGuardian.new()

		@studentGuardianDetails.mg_student_id=student_id

    	@studentGuardianDetails.mg_guardians_id=guardians_id

      @studentGuardianDetails.is_deleted=0

    	@studentGuardianDetails.relation=relation
    	@studentGuardianDetails.mg_school_id=session[:current_user_school_id]

    	@studentGuardianDetails.save

    	respond_to do |format|
		    format.json  { render :json => @studentGuardianDetails }
		end




	end

	def guardian_list_searched

		first_name = params[:first_name]
		last_name = params[:last_name]
		puts "Method is coming"
		puts first_name
		puts last_name
		puts "Method is coming"
		# SELECT * FROM final_sms_application_development.mg_guardians WHERE first_name LIKE '%y%' AND last_name LIKE '%y%'


		@sql = "SELECT id , first_name , last_name, occupation FROM mg_guardians WHERE first_name LIKE '%#{first_name}%' AND last_name LIKE '%#{last_name}%'"
		 
		 record = MgGuardian.find_by_sql(@sql);
		#@query=@sql.as_json
		 guardianData = record.as_json
    	logger.info(guardianData.inspect)

    	respond_to do |format|
		    format.json  { render :json => guardianData }
		end
    	#render :layout => false

   
   #Sessio
	end


	def new
		logger.info "in guardian new"

		@guardian = MgGuardian.new
    @dbdatas = MgCommonCustomField.where(model_name: "guardian",mg_school_id: session[:current_user_school_id],is_deleted: 0)
    @last_student=MgStudent.find(params[:id])
    #@last_studentId=@last_student.id

    @last_studentId=params[:id]
    @current_student_id=params[:id]

    # if MgGuardian.count.zero? # empty array
  #         @strVal='1'
  #     else
   #      @lastrecord = MgGuardian.last
   #      @lastadmissionId= @lastrecord.id.to_i
   #      @nextAdmissionNumber = @lastadmissionId + 1;
   #      @strVal = @nextAdmissionNumber.to_s
  #     end

    #render 'index'

	end

	def new_guardian
	
		@guardian = MgGuardian.new
		@dbdatas = MgCommonCustomField.where(model_name: "guardian",is_deleted:0,mg_school_id:session[:current_user_school_id])
		@last_studentId=params[:id]
    @student=MgStudent.find(@last_studentId)

	  if MgUser.where(:mg_school_id=>session[:current_user_school_id],:user_type=>"guardian").count.zero? # empty array
      @strVal='1'
    else
      @lastrecord = MgUser.where(:mg_school_id=>session[:current_user_school_id],:user_type=>"guardian").last
      n=@lastrecord.user_name.length
      @lastadmissionId= @lastrecord.user_name.slice(1,n)
      puts "Last Admission Id"
      puts @lastadmissionId
      @nextAdmissionNumber = @lastadmissionId.to_i + 1;
      puts "Next Admission Id"
      puts @nextAdmissionNumber
      @strVal = @nextAdmissionNumber.to_s
    end #end for if
		render :layout => false
	end

	def create
    require 'mime/types'
  begin
     MgUser.transaction do
      @school_sub_domain=MgSchool.find(session[:current_user_school_id])

      if MgUser.where(:mg_school_id=>session[:current_user_school_id],:user_type=>"guardian").count.zero? # empty array
        @strVal='1'
      else
       @lastrecord = MgUser.where(:mg_school_id=>session[:current_user_school_id],:user_type=>"guardian").last
        n=@lastrecord.user_name.length
        m=@school_sub_domain.subdomain.length
        @lastadmissionId= @lastrecord.user_name.slice(m+1, n)
        puts "Last Admission Id"
        puts @lastadmissionId
        @nextAdmissionNumber = @lastadmissionId.to_i + 1;
        puts "Next Admission Id"
        puts @nextAdmissionNumber
        @strVal = @nextAdmissionNumber.to_s
      end #end for if

      @user = MgUser.new(user_params)
      @user.user_name="#{@school_sub_domain.subdomain}#{"G"}#{@strVal}"
      @is_user_save=@user.save
      
      if @is_user_save
        puts "User Saved"
       #For Guardian
       guardian = @user.mg_guardians.build(guardian_params)
       guardian.save
       #for address
       address = @user.mg_addresses.build(permanent_address_params)
       address.save
       #For Phone
       phone = @user.mg_phones.build(phone_params)
       phone.save
       workPhone = @user.mg_phones.build(workPhone_params)
       workPhone.save
       #For Email
       email = @user.mg_emails.build(email_params)
       email.save
       #For user role
       @user_role = @user.mg_user_roles.build(:mg_role_id => 4)
       @user_role.save  

       #for Student Guardian
       @guardian=MgGuardian.find_by(mg_user_id:@user.id)
       already_present_guardian=MgStudentGuardian.where(:mg_student_id=>@guardian.mg_student_id,:is_deleted=>0,:mg_school_id=>session[:current_user_school_id]).count
       puts "already_present_guardian"
       puts already_present_guardian
       @studentGuardianDetails=MgStudentGuardian.new() 
       @studentGuardianDetails.mg_student_id=@guardian.mg_student_id
       @studentGuardianDetails.mg_guardians_id=@guardian.id
       @studentGuardianDetails.relation=@guardian.relation
       @studentGuardianDetails.mg_school_id=session[:current_user_school_id]
       @studentGuardianDetails.is_deleted=0
       if (already_present_guardian > 0)
        puts "Inside ifffffff"
        # @studentGuardianDetails.has_login_access=0
       else
         puts "Inside else"
        @studentGuardianDetails.has_login_access=1
       end
       @studentGuardianDetails.save

       @timeformat = MgSchool.find(session[:current_user_school_id])
       if params[:mg_guardian][:dob].present?
        @dateOfBirth = Date.strptime(params[:mg_guardian][:dob],@timeformat.date_format)
        @guardian.update(:dob => @dateOfBirth)
       end #end for guardian date of birth

       #Start for custom fields
        @custFieldNameIds = params[:custom_data]
       
       if  @custFieldNameIds.nil?
       else
        for j in 0...@custFieldNameIds.size
          @custFieldValObj = params[:"custom_field_#{@custFieldNameIds[j]}"]
          @custFieldVal = nil
          if !@custFieldValObj.nil? && @custFieldValObj.size>0
            @custFieldVal =@custFieldValObj[0];
            for index in 1...@custFieldValObj.size 
              @custFieldVal << ','+@custFieldValObj[index]
            end 
          end  #End for if
          @savedetails=MgCustomFieldsData.new(save_params) 
          @savedetails.value=@custFieldVal
          @savedetails.mg_custom_field_id=@custFieldNameIds[j]
          @savedetails.mg_user_id = @user.id
          @savedetails.is_deleted = 0
          @savedetails.save 
        end #end for
       end #End for Custom Fields
        redirect_to '/students'
      else
        redirect_to 'new'
      end #end for if user save

     end #end for transaction
     rescue
    flash[:error]="Error occured, please contact administrator"
    puts "====================================================="
    puts @guardian.mg_student_id
    redirect_to :action=>'new', :id=>@guardian.mg_student_id
   end
  end

	def index
		@guardians=MgGuardian.where(:is_deleted => '0',:mg_school_id=>session[:current_user_school_id]).all.paginate(page: params[:page], per_page: 10)
	end

	def edit
		@guardian=MgGuardian.find(params[:id])
    @student=MgStudent.find(@guardian.mg_student_id)

		@dbdatas = MgCommonCustomField.where(model_name: "guardian",mg_school_id:session[:current_user_school_id],is_deleted:0)

    @customData = MgCustomFieldsData.where(mg_user_id:@guardian.mg_user_id,mg_school_id:session[:current_user_school_id],is_deleted:0)

     logger.info(@customData.inspect)
     logger.info("=======================================")

		@Permanent=MgAddress.find_by(:mg_user_id=>@guardian.mg_user_id)
		
    @phone=MgPhone.find_by(:mg_user_id=>@guardian.mg_user_id , :phone_type => 'phone')
		@mobile=MgPhone.find_by(:mg_user_id=>@guardian.mg_user_id, :phone_type => 'mobile')
		@email=MgEmail.find_by(:mg_user_id=>@guardian.mg_user_id)

		render :layout => false
	end

	def update
begin
MgGuardian.transaction do
		@guardian=MgGuardian.find(params[:id])
		@guardian.update(guardian_edit_params)

    #update first name and last name in user table
      @guardian.mg_user.update(:first_name => params[:guardian][:first_name], 
                             :last_name => params[:guardian][:last_name])
    #end here

		@Permanent=MgAddress.find_by(:mg_user_id=>@guardian.mg_user_id)
		@Permanent.update(permanent_address_params)

		@phone=MgPhone.find_by(:mg_user_id=>@guardian.mg_user_id, :phone_type => 'phone')
    if @phone.present?
 		 @phone.update(phone_params)
    else
      @phone=MgPhone.new(phone_params)
      @phone.mg_user_id=@guardian.mg_user_id
      @phone.save

    end
    @mobile=MgPhone.find_by(:mg_user_id=>@guardian.mg_user_id, :phone_type => 'mobile')
    if @mobile.present?
      @mobile.update(workPhone_params)
    else
      @mobile=MgPhone.new(workPhone_params)
      @mobile.mg_user_id=@guardian.mg_user_id
      @mobile.save

    end
   
     # workPhone_params
     # phone_params



		    			 @timeformat = MgSchool.find(session[:current_user_school_id])
			    	puts "Shail timeformat step --1 "

			    	puts @timeformat.inspect
			    	puts "Shail timeformat step --2 "
			    	puts params[:guardian][:dob]

			    	puts "Shail timeformat step --3 "
            if(params[:guardian][:dob].present?)
    					@dateOfBirth = Date.strptime(params[:guardian][:dob],@timeformat.date_format)
    					@guardian.update(:dob => @dateOfBirth)
            end



		
		        @custFieldNameIds = params[:custom_data]
if  @custFieldNameIds.nil?
	
	else
     
     	for j in 0...@custFieldNameIds.size

      
		      @custFieldValObj = params[:"custom_field_#{@custFieldNameIds[j]}"]

		if !@custFieldValObj.nil?&& @custFieldValObj.size>0 
		   @custFieldVal =@custFieldValObj[0];
		          for index in 1...@custFieldValObj.size 
		          	@custFieldVal << ','+@custFieldValObj[index]

		         end 
       end


          
          @id=@custFieldNameIds[j]

          #@userName =  params[:employee][:employee_number ]
          puts "@id"
          puts @id
          puts "@id"


          @userObj = MgUser.where(:id=>@guardian.mg_user_id)

          puts "@userObj"
          puts @userObj.inspect
          puts "@userObj"

          
          puts @userObj[0][:id]
          @userObjId = @userObj[0].id
          puts @userObjId


           @details = MgCustomFieldsData.where(:mg_custom_field_id=>@id,:mg_user_id=>@userObjId)

           puts "printing details"
           puts @details.inspect
         if @details.size<1
           @savedetails=MgCustomFieldsData.new(save_params1) 
            @savedetails.value=@custFieldVal
             @savedetails.mg_custom_field_id=@id
             @savedetails.mg_user_id = @userObjId
             @savedetails.is_deleted = 0
           @savedetails.save
      	else
          @data = @custFieldVal
          @details[0].update(value: @data,is_deleted:0)
 
 		end
           #@data = @fields[j]
           #@data = @custFieldVal
          #@details.update(value: @data)
    end
 end
		@email=MgEmail.find_by(:mg_user_id=>@guardian.mg_user_id)
		@email.update(email_params)

		redirect_to :back 
  end
  rescue
  flash[:error]="Error occured, please contact administrator"
    redirect_to :back
    
end
end

	def delete
		@guardian=MgGuardian.find(params[:id])
    @guardian.update(:is_deleted=>'1')
    
    student_guardian=MgStudentGuardian.where(:mg_guardians_id=>params[:id])
  	student_guardian[0].update(:is_deleted=>'1')

    @user_id_of_guardian=MgGuardian.where(:id=>params[:id]).pluck(:mg_user_id)
    @user_delete=MgUser.where(:id=>@user_id_of_guardian[0])
    @user_delete[0].update(:is_deleted=>'1')


  		redirect_to '/guardians'
	end

	def address_update_by_guardian
		@guardian=MgGuardian.find(params[:id])
		@Permanent=MgAddress.find_by(:mg_user_id=>@guardian.mg_user_id)

		@Permanent.update(permanent_address_params)

		redirect_to '/dashboards/guardian_profile/'
		puts "Update method calling bty guardian"
		
	end
	def guardian_profile_contact_edit
		# id=session[:user_id]
		@guardian=MgGuardian.find(params[:id])

	    @phone = MgPhone.find_by(:mg_user_id => @guardian.mg_user_id, :phone_type => 'phone')
	    @mobile = MgPhone.find_by(:mg_user_id => @guardian.mg_user_id, :phone_type => 'mobile')

	    @email = MgEmail.find_by(:mg_user_id => @guardian.mg_user_id, :email_type => 'home')

	    @phone.update(phone_params)
	    @mobile.update(workPhone_params)
	    @email.update(email_params)

		redirect_to '/dashboards/guardian_profile/'
		puts "Update method calling bty guardian step --2 "
		
	end

	def destroy

		@guardian=MgGuardian.find(params[:id])
  		@guardian.update(:is_deleted=>'1')

  		@user = MgUser.find_by(:id=>@guardian.mg_user_id)
		@user.update(:is_deleted=>'1')

  		@Permanent=MgAddress.find_by(:mg_user_id=>@guardian.mg_user_id)
		@Permanent.update(:is_deleted=>'1')

		@phone=MgPhone.find_by(:mg_user_id=>@guardian.mg_user_id)
		@phone.update(:is_deleted=>'1')

		@mobile=MgPhone.find_by(:mg_user_id=>@guardian.mg_user_id)
		@mobile.update(:is_deleted=>'1')

		@email=MgEmail.find_by(:mg_user_id=>@guardian.mg_user_id)
		@email.update(:is_deleted=>'1')
 
  		redirect_to :action =>'index'
	end

	def show
		 @guardian=MgGuardian.find(params[:id])
		     @employeeUserId= @guardian.mg_user_id
              @address=MgAddress.where(mg_user_id: @employeeUserId)
              # @contact=MgPhone.where(mg_user_id: @employeeUserId)
              @phone_number=MgPhone.where(mg_user_id: @employeeUserId,phone_type: "phone")
              @mobile_number=MgPhone.where(mg_user_id: @employeeUserId,phone_type: "mobile")
              # puts "@contact==="
              # puts @employeeUserId
              # puts @contact
              @email=MgEmail.where(mg_user_id: @employeeUserId)
              @dbdatas = MgCommonCustomField.where(model_name: "guardian",is_deleted:0,mg_school_id:session[:current_user_school_id])
         @customData = MgCustomFieldsData.where(mg_user_id:@guardian.mg_user_id,is_deleted:0,mg_school_id:session[:current_user_school_id])
	end


 #==========below part updated on 15th jan=================================
    def pdf_gen
@@temp=1
      @guardiandatas=MgGuardian.find(params[:id])
      school=MgSchool.find(session[:current_user_school_id])
      @@school_logo=school.logo.url(:medium, timestamp: false)
      @last_guardian = @guardiandatas.id
      @@guardian_photo= @guardiandatas.photo.url(:medium, timestamp: false)
      puts "before mg_user_id"
      @guardianUserId= @guardiandatas.mg_user_id
      @customData = MgCustomFieldsData.where(mg_user_id:@guardianUserId,is_deleted:0,mg_school_id:session[:current_user_school_id])
     
      @guardian_details="select first_name,middle_name, last_name,DATE_FORMAT(dob,'%d/%m/%Y') 'date of birth', income, relation, occupation,education from mg_guardians  where id=#{@guardiandatas.id}"
      @guardian_detail=MgGuardian.find_by_sql(@guardian_details)
      std_all_dada=@guardian_detail.as_json 

##========Custom field=====================================================
      @@dbdatas = MgCommonCustomField.where(model_name: "guardian",is_deleted:0,mg_school_id:session[:current_user_school_id])
         @@customData = MgCustomFieldsData.where(mg_user_id:@guardianUserId,is_deleted:0,mg_school_id:session[:current_user_school_id])
#customfield========================================================================
 
##=========Custom field====================================================

      @get_gar_paddress="select  address_line1, address_line2,street , city, state , pin_code, landmark, country from mg_addresses where mg_user_id=#{@guardianUserId}"
            @gar_p=MgAddress.find_by_sql(@get_gar_paddress)
      std_p=@gar_p.as_json 
     
      #GUARDIAN MOBILE NUMBER
      @gua_h_phone="SELECT phone_number, notification ,subscription from mg_phones where mg_user_id=#{@guardianUserId} and phone_type='mobile'"
      @gu_h_phone=MgPhone.find_by_sql(@gua_h_phone)
      std_h_phone=@gu_h_phone.as_json
      # logger.info "inside phone"
      # logger.info std_h_phone

      #GUARDIAN HOME PHONE NUMBER
      @gua_p_phone="SELECT phone_number from mg_phones where mg_user_id=#{@guardianUserId} and phone_type='phone'"
      @gu_p_phone=MgPhone.find_by_sql(@gua_p_phone)
      std_p_phone=@gu_p_phone.as_json
      puts"phone==============================================================================="
      
      @gua_email="SELECT mg_email_id, notification ,subscription from mg_emails where mg_user_id=#{@guardianUserId}"
      @gua_email=MgEmail.find_by_sql(@gua_email)
      guardian_email=@gua_email.as_json
      

puts  "email doneeeeeeeeeeeeeeeeeeeeeeee"
      pdf = Prawn::Document.new do

            
        #this code for stamp
        #here this code should be first line of the code
             # create_stamp("approved this") do
             #        rotate(30, :origin => [-5, -5]) do
             #        stroke_color "FF3333"
             #        stroke_ellipse [0, 0], 100, 50
             #        stroke_color "000000"
             #        fill_color "993456"
             #        font("Times-Roman") do
             #        draw_text "approved this", :at => [-23, -3]
             #        end
             #        fill_color "000000"
             #        end
             #        end
             #        stamp "approved this"
             #        stamp_at "approved this", [200, 400]


                      # 2.times do
                      #     start_new_page
                      # end

                  repeat :all do

                # header
                        bounding_box [bounds.left, bounds.top],:align => :right, :width  => bounds.width do
                            font "Helvetica"
                            if File.exists?("#{Rails.root}/public/#{@@school_logo}") 
                                   image( "#{Rails.root}/public/#{@@school_logo}",:width =>  45)
                                  # image ("#{Rails.root}/public/#{@@school_logo}"),:at=>[425,690],:width=>45
                                  # image "#{Rails.root}/public/#{@@school_logo}", :width => 45, :align => :left
                            end
                            move_up 15
                            text school.school_name, :align => :center, :size => 18
                            stroke_horizontal_rule
                        end
        move_down 10

        # footer
                        bounding_box [bounds.left, bounds.bottom + 45], :width  => bounds.width do
                            font "Helvetica"
                            stroke_horizontal_rule
                            move_down(5)
                            # text " Powered By - ©", :size => 12
                            move_down 12
                            draw_text "Terms & Conditions| Privacy Policy| About Us| Contact Us",:at => [70,3]
                            draw_text "Powered By - ©", :at => [400,3]
                            image "#{Rails.root}/app/assets/images/mindcom-logo.png", :at=>[495,15], :width => 45, :align => :right
                        end
                  end
               

                    bounding_box([bounds.left, bounds.top - 60], :width  => bounds.width, :height => bounds.height - 100) do

                    move_down 120
                    if  File.exists?("#{Rails.root}/public/#{@@guardian_photo}")
                            # image "#{Rails.root}/public/#{@@emp_photo}", :align => :right, :width =>45
                            image("#{Rails.root}/public/#{@@guardian_photo}", :at => [450,600], :width =>  65)
                    else

                    end
                    
      text "General "
                    data =  Array.new
                    widths = Array.new(30, 50)
                    cell_height = 15
                    count=0
                    
                    $rowdata=Array.new
                    
                    std_all_dada[0].each_with_index { |(key, value), index|
                    if index % 2==0
                      $rowdata=Array.new
                    end
                    
                    if(key != 'id')
                    if( key =='date of birth')
                      str="Date of Birth"
                    else
                        str=key.tr('_', ' ') 
                        str=str.titleize
                    end 
                                
                    inner_table = make_table([ ["#{str}","#{value}"] ],:column_widths => 135)
                              
                                # display +=["#{value}"]
                                end
                    $rowdata +=[inner_table]
                    if index % 2==1
                    table([$rowdata],:column_widths => 270)  
                     
                    end 

                    }

                    move_down 25


      text "Address"
                    data =  Array.new
                    widths = Array.new(30, 50)
                    cell_height = 15
                    count=0
                    
                    $rowdata=Array.new
      
                    std_p[0].each_with_index { |(key, value), index|
                    if index % 2==0
                      $rowdata=Array.new
                    end
                    
                    str=key.tr('_', ' ') 
                    str=str.titleize
                    inner_table = make_table([ ["#{str}","#{value}"] ],:column_widths => 135)
                              
                                # display +=["#{value}"]
                               
                    $rowdata +=[inner_table]
                    if index % 2==1
                    table([$rowdata],:column_widths => 270)  
                     
                    end 
                    }
                    move_down 25

      
      text "Contact Details "

      @@phone_notification="No"
      @@phone_subscription="No"
      @@email_notification="No"
      @@email_subscription="No"

                    data =  Array.new
                    widths = Array.new(30, 50)
                    cell_height = 15
                    count=0
                    if std_p_phone[0].present?
                      std_p_phone[0].each_with_index { |(key, value), index|
                             if(key=='phone_number')
                           $phone2 = value
                            end
                          }                    
                    end
                    
                    $rowdata=Array.new
                    if std_h_phone[0].present?
                      std_h_phone[0].each_with_index { |(key, value), index|
                            if(key=='phone_number')
                            $phone1 = value
                            end
                          }

       

                    table([
                        [ "Phone Number","#{$phone2}","Mobile Number","+91-#{$phone1}"]
                        ],:column_widths => 135) 
#================================phone notification & subscription==================================

                        #if (!(std_h_phone[0].notification == ""))
                                std_h_phone[0].each_with_index { |(key, value), index|
                                    if(key=='notification')
                                    #$phone1 = value
                                                if value==true
                                                @@phone_notification="Yes"
                                                end
                                    end
                                  }
                        #end

                        #if std_h_phone[0].subscription.present?
                                  std_h_phone[0].each_with_index { |(key, value), index|
                                    if(key=='subscription')
                                    #$phone1 = value
                                                if value==true
                                                @@phone_subscription="Yes"
                                                end
                                    end
                                  }
                        #end

                          table([
                        [ "Notification","#{@@phone_notification}","Subscription","#{@@phone_subscription}"]
                        ],:column_widths => 135) 


#================================phone notification & subscription==================================


                    guardian_email[0].each_with_index { |(key, value), index|
                            if(key!='id')
                            $email_id = value
                            end
                          }

                    table([
                        [ "Email Id","#{$email_id}"]
                        ],:column_widths => 135) 

#================================email notification & subscription==================================
                        #if guardian_email[0].notification.present?
                                guardian_email[0].each_with_index { |(key, value), index|
                                  if(key=='notification')
                                  #$phone1 = value
                                              if value==true
                                              @@email_notification="Yes"
                                              end
                                  end
                                }
                        #end

                        #if guardian_email[0].subscription.present?
                                  guardian_email[0].each_with_index { |(key, value), index|
                                    if(key=='subscription')
                                    #$phone1 = value
                                                if value==true
                                                @@email_subscription="Yes"
                                                end
                                    end
                                  }
                        #end
                          table([
                        [ "Notification","#{@@email_notification}","Subscription","#{@@email_subscription}"]
                        ],:column_widths => 135) 

#================================email notification & subscription==================================

                  end
                    move_down 25

                    if @@customData.size>0
                 text "Custom Fields"
                
                
                 @@dbdatas.each do |dbdata| 
               
             @@customData.each do |custDatas|

            if dbdata.id.to_s==custDatas.mg_custom_field_id


              custom_data=Array.new
            


             


             

               @@customData.each do |custData| 

               if custData.mg_custom_field_id == dbdata.id.to_s
                  @custValue = custData.value
               
               end
             end
              
             
      table([
                      [ dbdata.name ,@custValue]
                        
                        ],:column_widths => 135) 
       
                
        

              
    end

 end               
                end

                      
                    







    

end


end
#=====================================Custom fields=====================================================

# end

#           end
end
              

         # Sends the PDF as inline document with name x.pdf
            send_data pdf.render,   :info => {
                      :Title => "My title",
                      :Author => "John Doe",
                      :Subject => "My Subject",
                      :Keywords => "test metadata ruby pdf dry",
                      :Creator => "ACME Soft App",
                      :Producer => "Prawn",
                      :CreationDate => Time.now
                      }, :filename => "x.pdf", :type => "application/pdf", :disposition => 'inline'
  end

    
    #==========above part updated on 15th jan=================================



#Added by bindhu
def student_guardian_show
  guardians=MgStudentGuardian.where(:mg_student_id=>params[:id],:mg_school_id=>session[:current_user_school_id],:is_deleted=>0).order(:mg_guardians_id)
  # @student_id=params[:id]
  @student=MgStudent.find(params[:id])
  @student_guardian=Array.new
  guardians.each do |guardian|
    @student_guardian << MgGuardian.find(guardian.mg_guardians_id)
  end
  if request.xhr?
    render :layout => false
  end
end

def login_access
  puts "params"
  puts params[:student_guardian][:student_id]
  puts params[:guardian_id]
  guardians_id=MgStudentGuardian.where(:mg_student_id=>params[:student_guardian][:student_id])
  
  guardians_id.each do |guardian|
     # guardian_details=MgGuardian.find(guardian.mg_guardians_id)
     if(guardian.mg_guardians_id.to_i==params[:guardian_id].to_i)
      guardian.update(:has_login_access=>1)
      @guardian=MgGuardian.find(guardian.mg_guardians_id)
     else
      guardian.update(:has_login_access=>0)
     end
  end
  flash[:notice]="Login access changed."
  redirect_to :action=>"student_guardian_show",:id=>params[:student_guardian][:student_id]
  
end
#Bindhu work Finish

	def custom_index
		#render :layout => false

	end

	def custom_create

		@customfields = MgCommonCustomField.new(post_params)
	      
	    @customfields.save
	    redirect_to :action=>'custom_new'

    end

	def custom_new
		@dbdatas = MgCommonCustomField.where(:model_name=> "guardian", :is_deleted=> 0,:mg_school_id=>session[:current_user_school_id])
		# logger.info "@dbdatas"
		# logger.info @dbdatas.inspect
	end	


	def custom_fields_edit
		@guardian_custom_field = MgCommonCustomField.find(params[:id])
  		render :layout => false
	end

	def custom_fields_update
	  @customfields = MgCommonCustomField.find(params[:id])
	  @customfields.update(custom_field_params)
	  
	  redirect_to :action=>'custom_new'
	end

	def custum_fields_delete
    @customfields=MgCommonCustomField.find_by_id(params[:id])
    @customfields.is_deleted =1
    @customfields.save
    redirect_to :action=>'custom_new'
  end

  	private

	  def guardian_params
	    logger.info "guardian_params"
	    params.require(:mg_guardian).permit(:first_name,:middle_name,
	    	:last_name,:relation,:dob,:occupation,:income,  :education, :mg_country_id, :mg_student_id, :is_deleted,:mg_school_id,:photo)
	  end

	  def guardian_edit_params
	    logger.info "guardian_params"
	    params.require(:guardian).permit(:first_name,:middle_name,
	    	:last_name,:relation,:dob,:occupation,:income,  :education, :mg_country_id, :mg_student_id, :is_deleted, :mg_school_id,:photo)
	  end

	  def permanent_address_params
	     logger.info "address_params"
	     params.require(:Permanent).permit( :address_line1,:address_line2,:city,:state,:pin_code,:country,:address_type, :is_deleted,:landmark , :street,:mg_school_id)
	  end

	  def user_params
	    logger.info "user_params"
	    params.require(:mg_guardian).permit(:user_name,:first_name,:last_name,:email, :password, :mg_school_id, :is_deleted,:user_type) #
	  end

	  def phone_params
	    logger.info "phone_params"
	    params.require(:phone).permit(:phone_number,:phone_type,:notification,:subscription, :is_deleted, :mg_school_id)
	  end

	  def workPhone_params
	    logger.info "workPhone_params"
	    params.require(:mobile).permit(:phone_number,:phone_type,:notification,:subscription, :is_deleted, :mg_school_id)
	  end

	  def email_params
	    logger.info "email_params"
	    params.require(:email).permit(:mg_email_id,:email_type,:is_deleted,:notification,:subscription, :is_deleted, :mg_school_id)
	  end

	  def workEmail_params
	    logger.info "workEmail_params"
	    params.require(:workEmail).permit(:mg_email_id,:email_type, :is_deleted, :mg_school_id)
	  end
def post_params
        params.require(:demo).permit(:mg_school_id,:model_name,:name,:text_data,:data_type, :is_deleted)
      end

      
  def save_params
   #params.require(:save).permit(:School_id,:custom_field_id,:one['value'],:two['value'],:three['value'],:four['value'])
      params.require(:mg_guardian).permit(:mg_school_id)

     end
      def save_params1
   #params.require(:save).permit(:School_id,:custom_field_id,:one['value'],:two['value'],:three['value'],:four['value'])
      params.require(:guardian).permit(:mg_school_id)

     end

    def custom_field_params
        params.require(:guardian_custom_field).permit(:mg_school_id,:model_name,:name,:text_data,:data_type, :is_deleted)
    end


end
