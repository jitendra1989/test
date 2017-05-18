class FeesController < ApplicationController
#com
  layout "mindcom"
  before_filter :login_required

  def index
    @subjects = MgFeeCategory.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id]).where(item_category_name: nil)
  end

  def show
    @feeCategory = MgFeeCategory.find(params[:id])
    render :layout => false
  end

  def new
   @feesquery=MgBatch.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id]).pluck(:name,:id, :mg_course_id)
   @subjects=MgFeeCategory.new()
   render :layout => false
  end

  def create
    @selected_batches = params[:selected_batches]
    @feedetails=MgFeeCategory.new(subject_params)
    @feedetails.save
    @particularData=params[:particulars]
    for i in 0...@particularData.size
      @saveParticular=MgParticularType.new()
      @saveParticular.particular_name=@particularData[i]
      @saveParticular.mg_fee_category_id=@feedetails.id
      @saveParticular.is_deleted=0
      @saveParticular.mg_school_id=session[:current_user_school_id]
      @saveParticular.save
    end
    # for i in 0...@selected_batches.size
    #   @feebatchcategorydetails=MgFeeCategoryBatches.new(:mg_fee_id => @feedetails.id, :mg_batch_id => @selected_batches[i]) 
    #   @feebatchcategorydetails.save
    # end
    redirect_to :action => "index"
  end

  

  def financeFee
    if params[:id].nil? 
      @particular_list=MgFeeParticular.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id],:fee_category=>session[:feedetails_id]).paginate(page: params[:page], per_page: 5)
    else
      @particular_list=MgFeeParticular.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id],:fee_category=>params[:id]).paginate(page: params[:page], per_page: 5)
      @fee_category=MgFeeCategory.find(params[:id])
      session[:feedetails_id] = @fee_category.id
    end

  end

  def section_students
    @batchid=params[:batch_value]
    @ids=@batchid.split(",")

    puts "start"
    puts @ids.length
    puts "end"
    @students=Array.new()
    @students.push(@ids)
    
    @studentsList=MgStudent.where(:mg_batch_id=>@ids,:is_deleted=>0,:mg_school_id=>session[:current_user_school_id]).pluck(:first_name,:id)
    


 render :layout=>false
  end
  #$students=Array.new()
  def multiple_students
    @data=params[:studentValues]
    @students=Array.new()
    @students.push(@data)
    @students=MgStudent.where(:id=>@students).pluck(:first_name,:id)
   render :json => {:name => @students}
    #render :layout=>false
  end

  def saveParticularFee
    @selected_batches1 = params[:selected_batches1]
    @params=params[:selectedStudents]

    if params[:fesses2][:value1] == 'demo'  #using student admission number
      for i in 0...@params.size
       puts"inside if save particular"
       @feeParticularObj=MgFeeParticular.new(particular_params) 
       @data=MgStudent.find(@params[i])
       @batchID=@data.mg_batch_id
        @feeParticularObj.mg_batch_id=@batchID
        @feeParticularObj.admission_no= @data.admission_number
        save_account_id(params[:fesses2][:selected_account_id],params[:mg_account_id],@feeParticularObj)
        @feeParticularObj.save
      end
    else
      if params[:fesses2][:value1] == 'All'
        for i in 0...@selected_batches1.size
          @feeparticulars2=MgFeeParticular.new(particular_params)
          @feeparticulars2.mg_batch_id = @selected_batches1[i]
          save_account_id(params[:fesses2][:selected_account_id],params[:mg_account_id],@feeparticulars2)
          @feeparticulars2.save
        end
      end
      if params[:fesses2][:value1] == 'demo2' 
        for i in 0...@selected_batches1.size #using student category
          puts"inside demo2"
          @feeparticulars2=MgFeeParticular.new(particular_params)       
          @feeparticulars2.mg_batch_id = @selected_batches1[i]
          @feeparticulars2.mg_student_category_id=params[:fesses2][:mg_student_category_id]
          save_account_id(params[:fesses2][:selected_account_id],params[:mg_account_id],@feeparticulars2)
          @feeparticulars2.save
        end
      end
    end
    redirect_to :action=>'financeFee',:controller=>'fees',:id=>params[:id]
  end

  def save_account_id(selected_account_id,new_account_id,fees_particular_object)
    if selected_account_id.present?
      if selected_account_id=="central"
        fees_particular_object.is_to_central=1
      else
        fees_particular_object.mg_account_id=selected_account_id
      end
    elsif new_account_id.present?
      if new_account_id=="central"
        fees_particular_object.is_to_central=1
      else
        fees_particular_object.mg_account_id=new_account_id
      end
    end
  end

  def newparticular

    @subjects=MgFeeParticular.new()
    render :layout => false
  end

#
  def fee_discount_index


    if params[:id].nil? 
      @fee_discount_list=MgFeeDiscount.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id]).paginate(page: params[:page], per_page: 5)
    else
      @fee_discount_list=MgFeeDiscount.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id]).paginate(page: params[:page], per_page: 5)
    end

    #@fee_discount_list=MgFeeDiscount.where(:is_deleted=>0)
  end

  def fee_discounts
    #render :layout => false
    @booleanValue=false
    @booleanValueForPost=false
    
    if request.xhr?

      ajaxParamCourseParam=params[:courseParam]
      ajaxParamAdmissionNumber=params[:admissionNumberParam]
      ajaxParamFeeCategoryId=params[:feeCategoryIdParam] 

      if(ajaxParamCourseParam=="courseParam")
        
        
        @batch_list = MgBatch.where(:mg_course_id => params[:courseId],:is_deleted=>0,:mg_school_id=>session[:current_user_school_id])
        logger.info @batch_list.inspect
        @booleanValue=true
        render :json => {:name => @batch_list }
      end

      if(ajaxParamAdmissionNumber=="admissionNumberParam")
        #puts(params[:admissionNumber])
        puts"admissionNumberParam"

        @validAdmissionNumber=MgStudent.where(:admission_number => params[:admissionNumber])
        logger.info @validAdmissionNumber.inspect
        @booleanValue=true
        render :json => { :validAdmissionNumber => @validAdmissionNumber }
      end

      if(ajaxParamFeeCategoryId=="feeCategoryIdParam")
        @batch_details=[]
        @batchCourse=[]
        #@feeCategoryBatchId=MgFeeParticular.select(:mg_batch_id).where(:fee_category => params[:feeCategoryId])
       @feeCategoryBatchId=MgFeeParticular.where(:fee_category => params[:feeCategoryId],:is_deleted => 0,:mg_school_id=>session[:current_user_school_id]).pluck(:mg_batch_id)
        
        #for index in 0 ... @feeCategoryBatchId.size
         # batchId= @feeCategoryBatchId[index].mg_batch_id
          #batch_list=MgBatch.select(:id, :name, :mg_course_id).find_by(:id => batchId,)


          #batchCourse=MgBatch.find_by_sql "SELECT p.id, p.name, c.course_name
          # FROM mg_batches p, mg_courses c WHERE p.mg_course_id = c.id"
          #@batchCourse[index]=batchCourse
          #batchCourse=MgBatch.joins(:mg_courses).where('mg_courses.id' =>batch_list[0].mg_course_id).select('mg_courses.course_name, mg_batches.id, mg_batches.name') 
          #@batchCourse[index]=batchCourse
          #logger.info 'batch_list'
          #logger.info batch_list.inspect
          #@course_name = MgCourse.find(batch_list[2])
         #@course=@course_name.course_name
         #puts @course_name.course_name


         

          #@batch_details[index]=batch_list
          #batch_list=''
          #batchId=''
        #end
        puts @feeCategoryBatchId.inspect
        @batch_details = MgBatch.includes(:mg_course).where(:id=>@feeCategoryBatchId,:is_deleted=>0,:mg_school_id=>session[:current_user_school_id]).order("mg_course_id","name").pluck(:id, :name, :mg_course_id,:course_name)

        logger.info "batchCourse"
        #puts @batchCourse
        
        @booleanValue=true
        puts @batch_details.inspect
        
        render :json => { :batch_details => @batch_details}
        #logger.info @feeCategoryBatchId.inspect 
        #@batchId=MgFeeCategoryBatches.select(:mg_batch_id).where(:mg_fee_id => params[:feeCategoryId])
      end
      

    end # ends of request.xhr?

    if request.post?
        puts"post request"
        #receiver_=params[:fee_discount][:receiver_id]
        @selectedBatchObj=params[:selected_batch]

        #receiver_ids=receiver_.split(",")
        #receiver_ids.each do|c|
        @params=params[:selectedStudents]

        if(params[:fee_discount][:discount_type]=="Student")
        for i in 0...@params.size
     
       
       @data=MgStudent.find(@params[i])
       @batchID=@data.mg_batch_id
       

       @fee_discounts=MgFeeDiscount.new(:discount_type => params[:fee_discount][:discount_type],:name => params[:fee_discount][:name],:mg_receiver_id => @data.id, :mg_batch_id=>@batchID, :mg_fee_category_id => params[:fee_discount][:mg_fee_category_id], :discount=> params[:fee_discount][:discount],:is_percent=> params[:fee_discount][:is_percent], :is_deleted=> params[:fee_discount][:is_deleted], :mg_school_id=> session[:current_user_school_id] )
       @fee_discounts.save
     end

    #@studentObj=MgStudent.where(:admission_number=>params[:fee_discount][:admission_number])
    
              #redirect_to :action=>'fee_discount_index'
        else

            @selectedBatchObj.each do|c|

                if(params[:fee_discount][:discount_type]=="Section")
                  @fee_discounts=MgFeeDiscount.new(:discount_type => params[:fee_discount][:discount_type],:name => params[:fee_discount][:name],:mg_receiver_id => c, :mg_batch_id => c,:mg_fee_category_id => params[:fee_discount][:mg_fee_category_id], :discount=> params[:fee_discount][:discount],:is_percent=> params[:fee_discount][:is_percent], :is_deleted=> params[:fee_discount][:is_deleted], :mg_school_id=> session[:current_user_school_id] )
                  @fee_discounts.save
                  #redirect_to :action=>'fee_discount_index'
                end

                # if(params[:fee_discount][:discount_type]=="Student")
                #   @fee_discounts=MgFeeDiscount.new(:discount_type => params[:fee_discount][:discount_type],:name => params[:fee_discount][:name],:mg_receiver_id => c, :mg_fee_category_id => params[:fee_discount][:mg_fee_category_id], :discount=> params[:fee_discount][:discount],:is_percent=> params[:fee_discount][:is_percent], :is_deleted=> params[:fee_discount][:is_deleted] )
                #   @fee_discounts.save
                #   #redirect_to :action=>'fee_discount_index'
                # end

                if(params[:fee_discount][:discount_type]=="Student Category")
                  @fee_discounts=MgFeeDiscount.new(:discount_type => params[:fee_discount][:discount_type],:name => params[:fee_discount][:name],:mg_receiver_id => params[:fee_discount][:student_category], :mg_batch_id => c,:mg_fee_category_id => params[:fee_discount][:mg_fee_category_id], :discount=> params[:fee_discount][:discount],:is_percent=> params[:fee_discount][:is_percent], :is_deleted=> params[:fee_discount][:is_deleted], :mg_school_id=> session[:current_user_school_id] )
                  @fee_discounts.save
                  #redirect_to :action=>'fee_discount_index'
                end

            end
            @booleanValueForPost=true
        end
            
        redirect_to :action=>'fee_discount_index'
    end

    if request.get?
      if @booleanValue==true
        puts" @booleanValue==true"
      elsif @booleanValueForPost==true
        #redirect_to 'fee_discount_index' 
        puts" @booleanValueForPost==true"
        redirect_to :action=>'fee_discount_index' 
      else  
        puts" inside render :layout => false"
        render :layout => false
      end

    end
    
  end # ends of def fee_discounts

  def edit_fee_discount

    @fee_discount = MgFeeDiscount.find(params[:id])
    render :layout => false
    
  end

  def update_fee_discount
    @fee_discounts = MgFeeDiscount.find(params[:id])

    @fee_discounts.update(:name => params[:fee_discount][:name], :discount=> params[:fee_discount][:discount])

    redirect_to  :back
  end


  def fine_from_index
    @fineparticular=MgFeeFineParticular.where(:is_deleted => 0,:mg_school_id=>session[:current_user_school_id]).paginate(page: params[:page], per_page: 5)
  end
  
def newfineparticular 
  @fineparticular=MgFeeFineParticular.new()
  render :layout=>false
end
def savefineParticularFee
  @selected_batches1 = params[:selected_batches1]
    @params=params[:selectedStudents]
    if params[:fesses2][:value1] == 'demo'  #using student admission number
      for i in 0...@params.size
       puts"inside if save particular"
       @feeParticularObj=MgFeeFineParticular.new(fine_particular_params) 
       @data=MgStudent.find(@params[i])
       @batchID=@data.mg_batch_id
        @feeParticularObj.mg_batch_id=@batchID
        @feeParticularObj.mg_student_id= @data.id
       @current_school_obj = MgSchool.find(session[:current_user_school_id])
       @startDate = Date.strptime(params[:fesses2][:start_date],@current_school_obj.date_format)
        @endDate = Date.strptime(params[:fesses2][:end_date],@current_school_obj.date_format)
        @dueDate = Date.strptime(params[:fesses2][:due_date],@current_school_obj.date_format)
       @feeParticularObj.start_date=@startDate
        @feeParticularObj.end_date=@endDate
        @feeParticularObj.due_date=@dueDate
        if params[:fesses2][:mg_account_id].present?
          if params[:fesses2][:mg_account_id]=="central"
            @feeParticularObj.is_to_central=1
          else
            @feeParticularObj.mg_account_id=params[:fesses2][:mg_account_id]
          end
        end
       @feeParticularObj.save
     end
       

    else
      if params[:fesses2][:value1] == 'All'
        for i in 0...@selected_batches1.size
          @feeparticulars2=MgFeeFineParticular.new(fine_particular_params)
          @feeparticulars2.mg_batch_id = @selected_batches1[i]
          @current_school_obj = MgSchool.find(session[:current_user_school_id])
          @startDate = Date.strptime(params[:fesses2][:start_date],@current_school_obj.date_format)
          @endDate = Date.strptime(params[:fesses2][:end_date],@current_school_obj.date_format)
          @dueDate = Date.strptime(params[:fesses2][:due_date],@current_school_obj.date_format)
          @feeparticulars2.start_date=@startDate
          @feeparticulars2.end_date=@endDate
          @feeparticulars2.due_date=@dueDate
          if params[:fesses2][:mg_account_id].present?
            if params[:fesses2][:mg_account_id]=="central"
              @feeparticulars2.is_to_central=1
            else
              #puts lll
              @feeparticulars2.mg_account_id=params[:fesses2][:mg_account_id]
            end
          end
          @feeparticulars2.save
        end
      end

      if params[:fesses2][:value1] == 'demo2' 
        for i in 0...@selected_batches1.size #using student category
          puts"inside demo2"
          @feeparticulars2=MgFeeFineParticular.new(fine_particular_params)
          @feeparticulars2.mg_batch_id = @selected_batches1[i]
          student_category_id=params[:fesses2][:mg_student_category_id]
          @current_school_obj = MgSchool.find(session[:current_user_school_id])
          @startDate = Date.strptime(params[:fesses2][:start_date],@current_school_obj.date_format)
          @endDate = Date.strptime(params[:fesses2][:end_date],@current_school_obj.date_format)
          @dueDate = Date.strptime(params[:fesses2][:due_date],@current_school_obj.date_format)
          @feeparticulars2.start_date=@startDate
          @feeparticulars2.end_date=@endDate
          @feeparticulars2.due_date=@dueDate
          if params[:fesses2][:mg_account_id].present?
            if params[:fesses2][:mg_account_id]=="central"
              @feeparticulars2.is_to_central=1
            else
              #puts lll
              @feeparticulars2.mg_account_id=params[:fesses2][:mg_account_id]
            end
          end
          @feeparticulars2.save
        end
      end
    end
    redirect_to :action=>'fine_from_index',:controller=>'fees'
  end 

  

  def delete_fee_discount
    @fee_discount=MgFeeDiscount.find_by_id(params[:id])
    #@fee_discount.is_deleted =1
    @fee_discount.update(:is_deleted=>1)
    redirect_to :action=>'fee_discount_index'
  end


   def show_fee_discount
    @fee_discount = MgFeeDiscount.find(params[:id])
    puts"@fee_discount"
    puts @fee_discount.inspect
    @feeCategoryObj=MgFeeCategory.find_by_id(@fee_discount.mg_fee_category_id)
    
    #@student_admission_number=MgStudent.where(@fee_discount.mg_receiver_id)
    if @fee_discount.discount_type=="Student"
      
      @studentObj=MgStudent.find_by_id(@fee_discount.mg_receiver_id)
    end

    if @fee_discount.discount_type=="Section"
      @batchObj=MgBatch.find_by_id(@fee_discount.mg_receiver_id)
    end

    if @fee_discount.discount_type=="Student Category"
      @studentCategoryObj=MgStudentCategory.find_by_id(@fee_discount.mg_receiver_id)
    end

    
    render :layout => false
  end

  def show_fee_fine

    @generate_fine_form=MgFeeFine.find_by_id(params[:id])
    render :layout => false
  end


  def fee_fine_index

    @fee_fine_list=MgFeeFine.where(:is_deleted=>0, :mg_school_id=> session[:current_user_school_id])
    #render :layout => false
  end

  def generate_fine

    if request.post?

      puts "params"
      puts params

      @fee_fine = MgFeeFine.new(fee_fine_params)

      puts "@fee_fine.inspect"
      puts @fee_fine.inspect

      @days_after_due_date_list=params[:days_after_due_date]
      @amount_list=params[:amount]

      for i in 0...@days_after_due_date_list.size
        

        fee_fine_due=@fee_fine.mg_fee_fine_dues.build(:days_after_due_date=>@days_after_due_date_list[i],
                  :amount=>@amount_list[i], :is_percent=>0,:is_deleted=>0, :mg_school_id=> session[:current_user_school_id])

        @fee_fine.save

      end
      # @days_after_due_date_list.each do |days_after_due_date|
      #   puts "days_after_due_date"
      #   puts days_after_due_date
      # end



      #fee_fine_due = @fee_fine.mg_fee_fine_dues.build(fee_fine_due_params)
      #puts"fee_fine_due"
      #puts fee_fine_due.inspect
      #@fee_fine.save
      redirect_to :action=>'fee_fine_index'
    end
    if request.get?
      render :layout => false
    end
  end

  def edit_fee_fine
    @generate_fine_form=MgFeeFine.find_by_id(params[:id])
    render :layout => false
  end

  def update_fee_fine
    @fee_fine=MgFeeFine.find_by_id(params[:id])
    @fee_fine.update(:fine_name=>params[:generate_fine_form][:fine_name], :fine_description=>params[:generate_fine_form][:fine_description])
   
    # redirect_to :action=>'fee_fine_index'
    redirect_to :back
  end

  def delete_fee_fine 

    @fee_fine=MgFeeFine.find_by_id(params[:id])
    #@fee_discount.is_deleted =1
    @fee_fine.update(:is_deleted=>1)
    redirect_to :action=>'fee_fine_index'
  end

  def fee_schedule
    @booleanValue=false
    if request.xhr?
      ajaxParamFeeCategoryId=params[:feeCategoryIdParam] 

      if(ajaxParamFeeCategoryId=="feeCategoryIdParam")

        @batch_details=[]
        @feeCategoryBatchId=MgFeeParticular.select(:mg_batch_id).where(:fee_category => params[:feeCategoryId],:is_deleted=>0,:mg_school_id=>session[:current_user_school_id])
        @batch_details = MgBatch.includes(:mg_course).where(:id=>@feeCategoryBatchId,:is_deleted=>0,:mg_school_id=>session[:current_user_school_id]).order("mg_course_id","name").pluck(:id, :name, :mg_course_id,:course_name)
        @booleanValue=true
        render :json => { :batch_details => @batch_details }
      end

    end # ends of request.xhr?

    if request.post?
        @selected_batch_id_array = params[:selected_batch]
        puts"post request in fee_schedule"
        puts params.inspect

        school_id=session[:current_user_school_id]
        #batchIds=params[:fee_schedule][:batch_ids]

        @selected_batch_id_array .each do|batchId|
          
            #logger.info '@fee_particular_list'
            #logger.info @batch_fee_particular_list.inspect

            #creating collection for each batch start
            @mg_fee_collection=MgFeeCollection.new(:name=>params[:fee_schedule][:name], :mg_fee_category_id=>params[:fee_schedule][:fee_category_id], :mg_batch_id=>batchId, :mg_fine_id=>params[:fee_schedule][:fee_fine_id], :start_date=>params[:fee_schedule][:start_date], :end_date=>params[:fee_schedule][:end_date], :due_date=>params[:fee_schedule][:due_date], :is_deleted=>params[:fee_schedule][:is_deleted], :mg_school_id=> session[:current_user_school_id])
            if params[:dataaa]=="datass" 
               @mg_fee_collection.update(:collection_type=>"inventory")
            end
            if params[:dataaa]=="examination" 
               @mg_fee_collection.update(:collection_type=>"examination")
            end
            if @mg_fee_collection.save
              @current_school_obj = MgSchool.find(school_id)
              @startDate = Date.strptime(params[:fee_schedule][:start_date],@current_school_obj.date_format)
              @endDate = Date.strptime(params[:fee_schedule][:end_date],@current_school_obj.date_format)
              @dueDate = Date.strptime(params[:fee_schedule][:due_date],@current_school_obj.date_format)
              @mg_fee_collection.update(:start_date => @startDate,:end_date => @endDate, :due_date => @dueDate)
            end
            #creating collection for each batch end


            #creating discount for each batch start            
            @batchFeeDiscounList=MgFeeDiscount.select(:discount_type, :name, :mg_receiver_id, :discount).where(:mg_batch_id => batchId,:is_deleted => 0, :mg_school_id=> session[:current_user_school_id])#, :discount_type=>"Section")
            # logger.info '@mgFeeDiscounList'
            # logger.info @mgFeeDiscounList.inspect

             for k in 0 ... @batchFeeDiscounList.size
              puts"@mgFeeDiscounList.size"
              discountType= @batchFeeDiscounList[k].discount_type
              discountName= @batchFeeDiscounList[k].name
              receiverId= @batchFeeDiscounList[k].mg_receiver_id
              discount= @batchFeeDiscounList[k].discount

              @mg_fee_collection_discount=@mg_fee_collection.mg_fee_collection_discounts.build(:mg_discount_type =>discountType ,:mg_discount_name => discountName,:mg_discount_receiver_id => receiverId, :mg_discount => discount ,:is_percent => 0, :is_deleted=> params[:fee_schedule][:is_deleted], :mg_school_id=> session[:current_user_school_id] )
              @mg_fee_collection.save
              
            end
            #creating discount for each batch start            


            #creating particular for each student start
            @batch_student_list=MgStudent.select(:id, :admission_number, :mg_student_catagory_id).where(:mg_batch_id => batchId)
            
            @batch_fee_particular_list=MgFeeParticular.select(:mg_particular_type_id, :description, :amount, :mg_batch_id,:mg_student_category_id).where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id],:fee_category=>params[:fee_schedule][:fee_category_id],:mg_batch_id=>batchId,:admission_no=>nil,:mg_student_category_id => nil)
            for i in 0 ... @batch_student_list.size
              puts"@batch_student_list.size"

              studentId= @batch_student_list[i].id
              studentAdmissionNumber= @batch_student_list[i].admission_number
              studentCategoryId= @batch_student_list[i].mg_student_catagory_id

              @mg_finance_fees=@mg_fee_collection.mg_finance_fees.build(:student_id=>studentId, :is_paid=>0, :is_deleted=> params[:fee_schedule][:is_deleted], :mg_school_id=> session[:current_user_school_id])

              @mg_finance_fees.save

                @student_fee_particular_list=MgFeeParticular.select(:mg_particular_type_id, :description, :amount, :mg_batch_id,:mg_student_category_id).
           where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id],:fee_category=>params[:fee_schedule][:fee_category_id],:admission_no => studentAdmissionNumber)

                @category_fee_particular_list=MgFeeParticular.select(:mg_particular_type_id, :description, :amount, :mg_batch_id,:mg_student_category_id).
           where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id],:fee_category=>params[:fee_schedule][:fee_category_id],:mg_batch_id=>batchId,:mg_student_category_id=>studentCategoryId)

                #@studentFeeDiscounList=MgFeeDiscount.select(:discount_type, :name, :mg_receiver_id, :discount).where(:mg_batch_id => batchId, :discount_type=>"Student",:mg_receiver_id=>studentId)

                #@categoryFeeDiscounList=MgFeeDiscount.select(:discount_type, :name, :mg_receiver_id, :discount).where(:mg_batch_id => batchId, :discount_type=>"Student Category",:mg_receiver_id=>studentCategoryId)

                 @student_fee_particular_list += @category_fee_particular_list+ @batch_fee_particular_list

                    

                # @studentFeeDiscounList += @categoryFeeDiscounList+ @batchFeeDiscounList
                 puts @student_fee_particular_list.inspect
                 #logger.infoadf

                 #puts @studentFeeDiscounList.inspect

              
            for index in 0 ... @student_fee_particular_list.size
                puts "hello particular"
                #mgParticularName= @batch_fee_particular_list[index].name
                
                puts @student_fee_particular_list[index].mg_particular_type_id.inspect
              
                #@particularType=MgParticularType.find_by(:id=>@student_fee_particular_list[index].mg_particular_type_id)
                #@particularType=MgParticularType.where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id]).find(@student_fee_particular_list[index].mg_particular_type_id)
                @particularType=MgParticularType.find(@student_fee_particular_list[index].mg_particular_type_id)
             

                mgParticularName= @particularType.particular_name
                mgParticularDescription= @student_fee_particular_list[index].description
                mgParticularAmount= @student_fee_particular_list[index].amount
                mgBatchId= @student_fee_particular_list[index].mg_batch_id

                mg_student_category_id =@student_fee_particular_list[index].mg_student_category_id
                mg_collection_id = @mg_fee_collection.id

                mg_collection_particular = MgFeeCollectionParticular.where(:mg_student_id=> studentId,:mg_fee_collection_id=>mg_collection_id,:mg_fee_particular_name=>mgParticularName,:is_deleted => 0, :mg_school_id=> session[:current_user_school_id])
                
                puts "Checking for empty"
                puts "mg_collection_particular.inspect"
                puts mg_collection_particular.inspect

                if(mg_collection_particular.empty?)
                  puts "inside Jayanth"
                  @mg_fee_collection_particular=@mg_fee_collection.mg_fee_collection_particulars.build(:mg_fee_particular_name => mgParticularName,:mg_fee_particular_description => mgParticularDescription,:mg_fee_particular_amount => mgParticularAmount, :mg_student_category_id => mg_student_category_id ,:mg_student_admission_number => studentAdmissionNumber, :mg_student_id=> studentId , :is_deleted=> params[:fee_schedule][:is_deleted], :mg_school_id=> session[:current_user_school_id] )
                  @mg_fee_collection.save
                end
                #end
              end #ends of inner for loop
                
             
            end #ends of outer for loop
           #creating particular for each student end
        end  #ends of each loop
        if params[:dataaa]=="datass" 
        
        redirect_to :action=>'inventory_fee_schedule',:controller=>"inventory"
        elsif params[:dataaa]=="examination"
        redirect_to :action=>'examination_fee_schedule',:controller=>"exam_management"

      else
        redirect_to :action=>'fee_schedule_index'
      end
    end #ends of request.post?

    if request.get?
      if @booleanValue==true
        puts" @booleanValue==true"
      else  
        puts" inside render :layout => false"
        render :layout => false
      end
    end

  end


  def show_fee_schedule
    @fee_schedule_show_list=MgFeeCollection.find_by_id(params[:id])
    render :layout => false
  end






  def fee_schedule_index

    #@fee_collection_list=MgFeeCollection.where(:is_deleted=>0)

    @fee_collection_list=MgFeeCollection.where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id],:collection_type=>nil).paginate(page: params[:page], per_page: 5)
    
   

  end

  def edit_fee_schedule
    @fee_schedule=MgFeeCollection.find_by_id(params[:id])
    puts @fee_schedule.inspect
    render :layout => false
  end

  def update_fee_schedule
    school_id=session[:current_user_school_id]
    @fee_schedule=MgFeeCollection.find_by_id(params[:id])
    @timeformat = MgSchool.find(school_id)
   @startDate = Date.strptime(params[:start_date_data],@timeformat.date_format)
    @endDate = Date.strptime(params[:end_date_data],@timeformat.date_format)
    @dueDate = Date.strptime(params[:due_date_data],@timeformat.date_format)
    @fee_schedule.update(:name=>params[:fee_schedule][:name], :start_date=>@startDate, :end_date=>@endDate, :due_date=>@dueDate)
    # redirect_to :action=>'fee_schedule_index'
    redirect_to :back

  end

  def delete_fee_schedule

    @fee_fine_schedule=MgFeeCollection.find_by_id(params[:id])
    #@fee_discount.is_deleted =1
    @fee_fine_schedule.update(:is_deleted=>1)
    redirect_to :action=>'fee_schedule_index'
  end

  def fee_defaulter

    if request.xhr?
      taskRequired=params[:taskRequired]
      school_id=session[:current_user_school_id]
      if(taskRequired=="getBatchList")
        @batch_list = MgBatch.where(:mg_course_id => params[:courseId])
        logger.info @batch_list.inspect
        render :json => {:name => @batch_list }
       
      elsif(taskRequired=="getStudentList")

        studentArray=[]
        collectionId=params[:collectionId]

        defaulter_student_ids = MgFinanceFee.where(:is_paid=>0).pluck(:student_id).uniq

        @student_list = MgStudent.select(:id, :first_name, :middle_name, :last_name, :mg_batch_id).where(:mg_batch_id => params[:batchId],:is_deleted=>0,:mg_school_id=>school_id,:id=>defaulter_student_ids)


        
        @student_list.each do |currStudent|

          #@financeFee = MgFinanceFee.where(:student_id => currStudent.id, :mg_fee_collection_id => collectionId)
         
         #puts @financeFee.inspect
          #if !@financeFee.nil? && @financeFee.size > 0 && !@financeFee[0].is_paid
              student = Hash.new 
              student['id'] = currStudent.id
              student['first_name'] = currStudent.first_name
              student['last_name'] = currStudent.last_name
              studentArray.push(student)
          #end  

        end 


        logger.info @student_list.inspect
        render :json => {:studentList => studentArray }
          
       elsif(taskRequired=="getCollectionList")
        #@fee_collection_list = MgFeeCollection.select(:id, :name).where(:mg_batch_id => params[:batchId])

        currentDate=Date.today
        batchId=params[:batchId]
        sql='select mg_fee_collections.id,mg_fee_collections.name from mg_fee_collections where end_date < CURDATE() AND mg_batch_id='+batchId+' AND is_deleted=0 AND mg_school_id=#{session[:current_user_school_id]}'
        puts(sql)
        @fee_collection_list=MgFeeCollection.find_by_sql(sql)

        #@fee_collection_list = MgFeeCollection.select(:id, :name).all(:conditions =>["end_date <= ?", Date.today])

        logger.info @fee_collection_list.inspect
        render :json => {:fee_collection_list => @fee_collection_list }
      end     
    end

  end #ends of def fee_defaulter


  def fee_collection
    if request.xhr?
      taskRequired=params[:taskRequired]

      if(taskRequired=="getBatchList")
        @batch_list = MgBatch.where(:mg_course_id => params[:courseId],:is_deleted=>0,:mg_school_id=>session[:current_user_school_id])
        logger.info @batch_list.inspect
        render :json => {:name => @batch_list }
       
      elsif(taskRequired=="getStudentList")
        @batchid=params[:batchId]
    sql="select mg_fee_collections.id,mg_fee_collections.name,mg_fee_collections.mg_batch_id from mg_fee_collections where start_date < CURDATE() AND mg_batch_id='#{@batchid}' AND is_deleted=0 AND mg_school_id='#{session[:current_user_school_id]}'"
       #puts @fee_collection_list.mg_batch_id
       # @fee_collection_list = MgFeeCollection.select(:id, :name).where(:mg_batch_id => params[:batchId],:start_date < :end_date)
       @fee_collection_list = MgFeeCollection.find_by_sql(sql)
       @data=@fee_collection_list.as_json
        @batchid=@data[0]
        puts @batchid['id']
        puts @batchid.inspect
       
        @fee_collection_id=@batchid['id']
        @student_list = MgStudent.select(:id, :first_name, :middle_name, :last_name, :mg_batch_id).where(:mg_batch_id =>@batchid['mg_batch_id'])
        logger.info @student_list.inspect
        render :json => {:studentList => @student_list,:collectionID=>@fee_collection_id }
          
       elsif(taskRequired=="getCollectionList")
        @fee_collection_list = MgFeeCollection.select(:id, :name).where(:mg_batch_id => params[:batchId])
        logger.info @fee_collection_list.inspect
        render :json => {:fee_collection_list => @fee_collection_list }
      end     
    end
  end #ends of def fee_collection


  def defaulter_fees_submission

    if request.get?
      @school_id=session[:current_user_school_id]
      
      @studentObj = MgStudent.find(params[:id])
      @admissionNumber=@studentObj.admission_number
      first_name=@studentObj.first_name
      last_name=@studentObj.last_name
      @full_name="#{first_name} #{last_name}"
      @studentbatch=MgBatch.find(@studentObj.mg_batch_id)
      studentcourse=MgCourse.find(@studentbatch.mg_course_id)

      batch_name=@studentbatch.name
      course_name=studentcourse.course_name
      @class_section="#{course_name}-#{batch_name}"
      if !(@studentObj.mg_student_catagory_id.nil?)
        @studentcategory=MgStudentCategory.find(@studentObj.mg_student_catagory_id)
      end

      paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:is_paid=>0).pluck(:mg_fee_collection_id)
      @fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id IN (?)',@studentObj.mg_batch_id, Date.today, paid_finance_fee).order("due_date")
     
      paid_fines =  MgFinanceTransactionDetail.where(:mg_student_id=>@studentObj.id,:mg_collection_id=>nil).pluck(:mg_fee_fine_particular_id)      
     
  if paid_fines.empty?

  @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? ',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? ',@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)

  else
    @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
    @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
      @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)



  end



      # @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?',params[:id],@studentbatch.id, Date.today)
      # .pluck(:amount,:fine_name,:fine_from,:id)
      # @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?',nil,@studentbatch.id, Date.today)
      # .pluck(:amount,:fine_name,:fine_from,:id)


      #---------------Shravan End--------------  


      
      #@studentScoreArray=MgFinanceTransactionDetail.where(:mg_student_id=>params[:id]).pluck(:paid_amount)

      
      
     
      #@checkForFeePaid=MgFinanceFee.where(:student_id=>@studentId,:mg_fee_collection_id=>params[:fee_collection_id] )
      


      # #selectFeeCollectionId=params[:fee_collection_id]
      # #@mgFeeCollectionObj=MgFeeCollection.find_by_id(selectFeeCollectionId)
      # @feeFineDue=MgFeeFineDue.where(:mg_fee_fine_id=>@mgFeeCollectionObj.mg_fine_id).order('days_after_due_date DESC').pluck(:days_after_due_date, :amount, :mg_fee_fine_id)
      

      # @studentId=params[:id]
     
      # @checkForFeePaid=MgFinanceFee.where(:student_id=>@studentId,:mg_fee_collection_id=>params[:fee_collection_id])
      # puts "@checkForFeePaid"
      # puts @checkForFeePaid.inspect


      # @collection_particular_list=MgFeeCollectionParticular.where(:mg_student_id=>params[:id], :mg_fee_collection_id=>selectFeeCollectionId)
     
      # @particular_discount_list=MgFeeCollectionDiscount.select(:mg_discount_name, :mg_discount).where(:mg_fee_collection_id=>selectFeeCollectionId,:mg_discount_type=>"Batch", :mg_discount_receiver_id=>@studentObj.mg_batch_id)
      # @particular_discount_list+=MgFeeCollectionDiscount.select(:mg_discount_name, :mg_discount).where(:mg_fee_collection_id=>selectFeeCollectionId,:mg_discount_type=>"Student", :mg_discount_receiver_id=>@studentObj.id)
      # @particular_discount_list+=MgFeeCollectionDiscount.select(:mg_discount_name, :mg_discount).where(:mg_fee_collection_id=>selectFeeCollectionId,:mg_discount_type=>"Student Category", :mg_discount_receiver_id=>@studentObj.mg_student_catagory_id)
    end

    if request.post?
      @mg_finance_fee_id=MgFinanceFee.where(:student_id=>params[:fees_submission_batch][:student_id], :mg_fee_collection_id=>params[:fees_submission_batch][:fee_collection_id])
      puts"@mg_finance_fee_id"
      puts @mg_finance_fee_id.inspect
      if(@mg_finance_fee_id.size>0)
        mgFinanceFeeId=@mg_finance_fee_id[0].id
      #else
       # mgFinanceFeeId=''
      #end
      # :finance_fee_id=>@mg_finance_fee_id[0].id,
      #logger.info " @mg_finance_fee_id"  
      #logger.info  @mg_finance_fee_id.inspect
      @mg_finance_transaction=MgFinanceTransaction.new(:amount => params[:fees_submission_batch][:fee_amount], :mg_student_id=> params[:fees_submission_batch][:student_id], :finance_fee_id=>mgFinanceFeeId, :transaction_date=> params[:fees_submission_batch][:transaction_date], :is_deleted=> params[:fees_submission_batch][:is_deleted], :mg_school_id=> session[:current_user_school_id], :fine_included=> params[:fees_submission_batch][:fine_included], :fine_amount=> params[:fees_submission_batch][:fine_amount])
       
       if @mg_finance_transaction.save 

        @mg_finance_fee_id.update_all(:transaction_id=>@mg_finance_transaction.id, :is_paid=>1) 

       end  

     end 
      #redirect_to :action=>'fee_collection'  fees_submission_batch/6/28
      redirectURL='/fees/defaulter_fees_submission/'+params[:fees_submission_batch][:student_id]+'/'+params[:fees_submission_batch][:fee_collection_id]

      puts"redirectURL"
      puts redirectURL 
      redirect_to redirectURL
      #render :layout => false
    end
  end
  

  def fees_submission_batch
    @school_id=session[:current_user_school_id]
    
    if request.xhr?
      # ajaxParamDisplayFee=params[:ajaxParamDisplayFee]
      # selectFeeCollectionId=params[:selectFeeCollectionId]
      # @mgFeeCollectionObj=''
      # if ajaxParamDisplayFee=="ajaxParamDisplayFee"
      #     puts" inside ajaxParamDisplayFee"
      #     @mgFeeCollectionObj=MgFeeCollection.find_by_id(selectFeeCollectionId)
      #     #puts @mgFeeCollectionObj.inspect
      # end
    end

    if request.get?
      @studentObj = MgStudent.find(params[:id])

      @admissionNumber=@studentObj.admission_number
      first_name=@studentObj.first_name
      last_name=@studentObj.last_name
      @full_name="#{first_name} #{last_name}"
      @studentbatch=MgBatch.find(@studentObj.mg_batch_id)
      studentcourse=MgCourse.find(@studentbatch.mg_course_id)
      batch_name=@studentbatch.name
      course_name=studentcourse.course_name
      @class_section="#{course_name}-#{batch_name}"
      if !(@studentObj.mg_student_catagory_id.nil?)
        @studentcategory=MgStudentCategory.find(@studentObj.mg_student_catagory_id)
      end
      paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:is_paid=>0,:is_deleted=>0,:mg_school_id=>session[:current_user_school_id]).pluck(:mg_fee_collection_id)
      @fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id IN (?) AND is_deleted=? AND  mg_school_id=?',@studentObj.mg_batch_id, Date.today, paid_finance_fee,0,session[:current_user_school_id]).order("due_date")
      paid_fines =  MgFinanceTransactionDetail.where(:mg_student_id=>@studentObj.id,:is_deleted=>0,:mg_school_id=>session[:current_user_school_id],:mg_collection_id=>nil).pluck(:mg_fee_fine_particular_id)      
     
      if paid_fines.empty?
        @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? AND is_deleted=? AND mg_school_id=?',params[:id],@studentbatch.id, Date.today,0,session[:current_user_school_id]).pluck(:amount,:fine_name,:fine_from,:id)
        @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?  AND is_deleted=? AND  mg_school_id=?',params[:id],@studentbatch.id, Date.today,0,session[:current_user_school_id]).pluck(:amount,:fine_name,:fine_from,:id)
        @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ?  AND is_deleted=? AND  mg_school_id=?',@studentbatch.id, Date.today,0,session[:current_user_school_id]).pluck(:amount,:fine_name,:fine_from,:id)
      else
        @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)  AND is_deleted=? AND  mg_school_id=?',params[:id],@studentbatch.id, Date.today,paid_fines,0,session[:current_user_school_id]).pluck(:amount,:fine_name,:fine_from,:id)
        @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)  AND is_deleted=? AND  mg_school_id=?',params[:id],@studentbatch.id, Date.today,paid_fines,0,session[:current_user_school_id]).pluck(:amount,:fine_name,:fine_from,:id)
        @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)  AND is_deleted=? AND  mg_school_id=?',@studentbatch.id, Date.today,paid_fines,0,session[:current_user_school_id]).pluck(:amount,:fine_name,:fine_from,:id)
      end
    end

    if request.post?
      transaction_title = "Receipt No:"
      student_id = params[:fees_submission_batch][:student_id]
      school_id = params[:fees_submission_batch][:mg_school_id]
      puts "step-1"
      MgFinanceTransaction.transaction do
        payment_type=params[:fees_submission_batch][:fees_payment]
        cheque_numbers=params[:fees_submission_batch][:cheque_number]
        #date_of_cheques=params[:fees_submission_batch][:date_of_cheque]
        bankname_and_branchs=params[:fees_submission_batch][:bankname_and_branch]
        draft_numbers=params[:fees_submission_batch][:draft_number]
        #date_of_drafts=params[:fees_submission_batch][:date_of_draft]
        bank_name_for_cheque=params[:bankname_and_branch_for_cheque]
        @timeformat = MgSchool.find(session[:current_user_school_id])
        if params[:fees_submission_batch][:date_of_cheque].present?
          datecheques = Date.strptime(params[:fees_submission_batch][:date_of_cheque],@timeformat.date_format)
        end
        if params[:fees_submission_batch][:date_of_draft].present?
          datedrafts = Date.strptime(params[:fees_submission_batch][:date_of_draft],@timeformat.date_format)
        end
        if bank_name_for_cheque.present?
          finance_transaction = MgFinanceTransaction.create(:title=>transaction_title,:mg_student_id=>student_id,:transaction_date=>Date.today,:amount=>params[:fees_submission_batch][:fee_amount],:mg_school_id=>school_id,:is_deleted=>0,:payment_mode=>payment_type,:date_of_cheque=>datecheques,:date_of_draft=>datedrafts,:cheque_number=>cheque_numbers,:draft_number=>draft_numbers,:bankname_and_branch=>bank_name_for_cheque) 
        else   
          finance_transaction = MgFinanceTransaction.create(:title=>transaction_title,:mg_student_id=>student_id,:transaction_date=>Date.today,:amount=>params[:fees_submission_batch][:fee_amount],:mg_school_id=>school_id,:is_deleted=>0,:payment_mode=>payment_type,:date_of_cheque=>datecheques,:date_of_draft=>datedrafts,:cheque_number=>cheque_numbers,:draft_number=>draft_numbers,:bankname_and_branch=>bankname_and_branchs) 
        end

         #finance_transaction = MgFinanceTransaction.create(:title=>transaction_title,:mg_student_id=>student_id,:transaction_date=>Date.today,:amount=>params[:fees_submission_batch][:fee_amount],:mg_school_id=>school_id,:is_deleted=>0) 
        puts "step-2"
        unless params[:amount].nil?
          params[:amount].each_with_index do |amt,i|
            puts "step-3"
            if(amt.to_f>0)
              MgFinanceTransactionDetail.create(
                :is_partial_payment=>(amt.to_f!=params[:full_amount][i].to_f),
                :detail_type => 'particular',
                :mg_fee_particular_id=>params[:collection_particular_ids][i],
                :mg_collection_id=>params[:p_fee_collection_ids][i],
                :paid_amount=>amt,
                :mg_transaction_id=>finance_transaction.id,
                :mg_student_id=>student_id,
                :is_deleted=>0,
                :mg_school_id=>school_id
              )
            end#if>0
          end
          #Bindhu Added for Accounts starts
          #puts lll
          collection_particular_ids=params[:collection_particular_ids]
          collection_particular_ids.each_with_index do |collection_particular,i|
            collection=MgFeeCollectionParticular.find(collection_particular)
            particular_type_id=MgParticularType.where(:particular_name=>collection.mg_fee_particular_name)
            to_account=MgFeeParticular.where(:mg_particular_type_id=>particular_type_id[0].id).pluck(:mg_account_id)
            is_to_central=MgFeeParticular.where(:mg_particular_type_id=>particular_type_id[0].id).pluck(:is_to_central)
            from_account_id=""
            amount=params[:amount][i]
            for_module="fees"
            particular_id=collection.id
            transaction_type="receivable"
            amount_transfer_type="credited"
            if to_account.length>0 && to_account.any?
              accont_array=to_account-[nil]
              to_account_id=accont_array[0]
              puts "to_account"
              puts to_account_id
              account_transaction=MgAccountTransaction.add_transaction(from_account_id,to_account_id,amount,for_module,particular_id,transaction_type,amount_transfer_type,session[:current_user_school_id],session[:user_id],session[:user_id])
              account_transaction.save
            end
            if is_to_central.length > 0 && is_to_central.any?
              to_account_id=""
              central_account_transaction=MgCentralAccountTransaction.send_transaction(from_account_id,to_account_id,amount,for_module,particular_id,transaction_type,amount_transfer_type,session[:current_user_school_id],session[:user_id],session[:user_id])
              central_account_transaction.save
            end
          end
          #Bindhu Added for Accounts end
        end#particular details  
        puts "step-4" 
        unless params[:discountamount].nil?
          params[:discountamount].each_with_index do |amt,i|
            collection_id = params[:d_fee_collection_ids][i]
            index = params[:fee_collection_ids].index(collection_id)
            if(amt.to_f>0 && params[:category_fees][index].to_f>0)
              MgFinanceTransactionDetail.create(
                :is_partial_payment=>0,
                :detail_type => 'discount',
                :mg_fee_collection_discount_id=>params[:collection_discount_ids][i],
                :mg_collection_id=>params[:d_fee_collection_ids][i],
                :paid_amount=>amt,
                :mg_transaction_id=>finance_transaction.id,
                :mg_student_id=>student_id,
                :is_deleted=>0,
                :mg_school_id=>school_id
              )
            end#if>0
          end
        end#Discount details 
        puts "step-5" 
        unless params[:latepaymentfines].nil?
          params[:latepaymentfines].each_with_index do |amt,i|
            collection_id = params[:f_fee_collection_ids][i]
            index = params[:fee_collection_ids].index(collection_id)
            if(amt.to_f>0 && params[:category_fees][index].to_f>0)
              MgFinanceTransactionDetail.create(
                :is_partial_payment=>0,
                :detail_type => 'late',
                :late_fee_fine_id=>params[:late_fine_category_ids][i],
                :mg_collection_id=>params[:f_fee_collection_ids][i],
                :paid_amount=>amt,
                :mg_transaction_id=>finance_transaction.id,
                :mg_student_id=>student_id,
                :is_deleted=>0,
                :mg_school_id=>school_id
              )
            end#if>0
          end
        end#late fine details  
        puts "step-6"
        unless params[:fineamount].nil?
          params[:fineamount].each_with_index do |amt,i|
            if(amt.to_f>0)
              MgFinanceTransactionDetail.create(
                :is_partial_payment=>0,
                :detail_type => 'fine',
                :mg_fee_fine_particular_id=>params[:fine_particular_ids][i],
                :paid_amount=>amt,
                :mg_transaction_id=>finance_transaction.id,
                :mg_student_id=>student_id,
                :is_deleted=>0,
                :mg_school_id=>school_id
              )
            end#if>0
          end #do
          #Bindhu Added for Accounts Starts
          fine_particulars=params[:fine_particular_ids]
          fine_particulars.each_with_index do |fine_particular,i|
            particular=MgFeeFineParticular.find(fine_particular)
            from_account_id=""
            amount=params[:fineamount][i]
            for_module="fees"
            particular_id=particular.id
            transaction_type="receivable"
            amount_transfer_type="credited"
            if particular.mg_account_id.present?
              to_account_id=particular.mg_account_id
              account_transaction=MgAccountTransaction.add_transaction(from_account_id,to_account_id,amount,for_module,particular_id,transaction_type,amount_transfer_type,session[:current_user_school_id],session[:user_id],session[:user_id])
              account_transaction.save
            elsif particular.is_to_central.present?
              to_account_id=""
              central_account_transaction=MgCentralAccountTransaction.send_transaction(from_account_id,to_account_id,amount,for_module,particular_id,transaction_type,amount_transfer_type,session[:current_user_school_id],session[:user_id],session[:user_id])
              central_account_transaction.save
            end
          end
          #Bindhu Added for Accounts Ends
        end#fine details  
        puts "step-7"
        if params[:fee_collection_ids].present?
          params[:fee_collection_ids].each do |id|
            total = MgFeeCollectionParticular.where(:mg_fee_collection_id=>id,:mg_student_id=>student_id,:mg_school_id=>school_id).sum(:mg_fee_particular_amount)      
            paid  = MgFinanceTransactionDetail.where('mg_collection_id =? AND mg_student_id=? AND mg_school_id=? AND mg_fee_particular_id  IS NOT NULL',id,student_id,school_id).sum(:paid_amount)
            if(total==paid)
             finance_fee = MgFinanceFee.find_by(:mg_fee_collection_id=>id,:student_id=>student_id,:mg_school_id=>school_id)
             finance_fee.update(:is_paid=>1,:transaction_id=>finance_transaction.id)
            end
          end 
        end
 
        puts "step-8"
        redirect_to :action=>'fee_submission_status',:id=>finance_transaction.id
      end
      puts "step-9"
    end
    puts "step-10"
  end #ends of def fees_submission_batch

#jayanth added
def guardian__student_fee_view

@finance_fee_hash=MgFinanceFee.where(:student_id=>params[:id])
@student=MgStudent.find(params[:id])


#@student_ids=MgFinanceFee.where('mg_student_id= ? AND transaction_id Is Null ',params[:id],)
render :layout=>false
end


def student_fee_submission
  # @school_id=session[:current_user_school_id]
      
  #     @studentObj = MgStudent.find(params[:id])
  #     @admissionNumber=@studentObj.admission_number
  #     first_name=@studentObj.first_name
  #     last_name=@studentObj.last_name
  #     @full_name="#{first_name} #{last_name}"
  #     @studentbatch=MgBatch.find(@studentObj.mg_batch_id)
  #     studentcourse=MgCourse.find(@studentbatch.mg_course_id)

  #     batch_name=@studentbatch.name
  #     course_name=studentcourse.course_name
  #     @class_section="#{course_name}-#{batch_name}"
  #     if !(@studentObj.mg_student_catagory_id.nil?)
  #       @studentcategory=MgStudentCategory.find(@studentObj.mg_student_catagory_id)
  #     end

  #     paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:is_paid=>0).pluck(:mg_fee_collection_id)
  #     @fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id IN (?)',@studentObj.mg_batch_id, Date.today, paid_finance_fee).order("due_date")
     
  #     paid_fines =  MgFinanceTransactionDetail.where(:mg_student_id=>@studentObj.id,:mg_collection_id=>nil).pluck(:mg_fee_fine_particular_id)      
     
  # if paid_fines.empty?

  # @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  # @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? ',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  # @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? ',@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)

  # else
  #   @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
  #   @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
  #     @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)



  # end


  #  @studentObj = MgStudent.find_by_id(params[:id])

  #     selectFeeCollectionId=5
  #     @mgFeeCollectionObj=MgFeeCollection.find_by_id(selectFeeCollectionId)
  #     @feeFineDue=MgFeeFineDue.where(:mg_fee_fine_id=>@mgFeeCollectionObj.mg_fine_id).order('days_after_due_date DESC').pluck(:days_after_due_date, :amount, :mg_fee_fine_id)

  #     @studentId=params[:id]
     
  #     @checkForFeePaid=MgFinanceFee.where(:student_id=>@studentId,:mg_fee_collection_id=>params[:fee_collection_id] )
  #     puts "@checkForFeePaid"
  #     puts @checkForFeePaid.inspect


  #     @collection_particular_list=MgFeeCollectionParticular.where(:mg_student_id=>params[:id], :mg_fee_collection_id=>selectFeeCollectionId)
     
  #     @particular_discount_list=MgFeeCollectionDiscount.select(:mg_discount_name, :mg_discount).where(:mg_fee_collection_id=>selectFeeCollectionId,:mg_discount_type=>"Batch", :mg_discount_receiver_id=>@studentObj.mg_batch_id)
  #     @particular_discount_list+=MgFeeCollectionDiscount.select(:mg_discount_name, :mg_discount).where(:mg_fee_collection_id=>selectFeeCollectionId,:mg_discount_type=>"Student", :mg_discount_receiver_id=>@studentObj.id)
  #     @particular_discount_list+=MgFeeCollectionDiscount.select(:mg_discount_name, :mg_discount).where(:mg_fee_collection_id=>selectFeeCollectionId,:mg_discount_type=>"Student Category", :mg_discount_receiver_id=>@studentObj.mg_student_catagory_id)
  # render :layout=>false
  @studentObj = MgStudent.find(params[:id])
      @admissionNumber=@studentObj.admission_number
      first_name=@studentObj.first_name
      last_name=@studentObj.last_name
      @full_name="#{first_name} #{last_name}"
      @studentbatch=MgBatch.find(@studentObj.mg_batch_id)
      studentcourse=MgCourse.find(@studentbatch.mg_course_id)

      batch_name=@studentbatch.name
      course_name=studentcourse.course_name
      @class_section="#{course_name}-#{batch_name}"
      if !(@studentObj.mg_student_catagory_id.nil?)
        @studentcategory=MgStudentCategory.find(@studentObj.mg_student_catagory_id)
      end


      #paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:is_paid=>1).pluck(:mg_fee_collection_id)
      

      #@fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id NOT IN (?)',@studentObj.mg_batch_id, Date.today, paid_finance_fee).order("due_date")
#jayanth modification is required
      paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:mg_fee_collection_id=>params[:Collectionid]).pluck(:mg_fee_collection_id)
      
# jayanth end modification is required


      #@fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ?',@studentObj.mg_batch_id, Date.today).order("due_date")
      @fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id IN (?)',@studentObj.mg_batch_id, Date.today, paid_finance_fee).order("due_date")
     
      paid_fines =  MgFinanceTransactionDetail.where(:mg_student_id=>@studentObj.id,:mg_collection_id=>nil).pluck(:mg_fee_fine_particular_id)      
     
  if paid_fines.empty?

  @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? ',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? ',@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)

  else
    @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
    @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
      @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
  end

   render :layout=>false
end



def fine_fee_reports
  @school_id=session[:current_user_school_id]

    

      @studentObj = MgStudent.find(params[:id])
      @admissionNumber=@studentObj.admission_number
      first_name=@studentObj.first_name
      last_name=@studentObj.last_name
      @full_name="#{first_name} #{last_name}"
      @studentbatch=MgBatch.find(@studentObj.mg_batch_id)
      studentcourse=MgCourse.find(@studentbatch.mg_course_id)

      batch_name=@studentbatch.name
      course_name=studentcourse.course_name
      @class_section="#{course_name}-#{batch_name}"
      if !(@studentObj.mg_student_catagory_id.nil?)
        @studentcategory=MgStudentCategory.find(@studentObj.mg_student_catagory_id)
      end


      #paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:is_paid=>1).pluck(:mg_fee_collection_id)
      #@fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id NOT IN (?)',@studentObj.mg_batch_id, Date.today, paid_finance_fee).order("due_date")

      paid_finance_fee = MgFinanceFee.where(:student_id =>@studentObj.id,:is_paid=>0).pluck(:mg_fee_collection_id)
      #@fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ?',@studentObj.mg_batch_id, Date.today).order("due_date")
      @fee_collection_hash = MgFeeCollection.where('mg_batch_id = ? AND start_date <= ? AND id IN (?)',@studentObj.mg_batch_id, Date.today, paid_finance_fee).order("due_date")
     
      paid_fines =  MgFinanceTransactionDetail.where(:mg_student_id=>@studentObj.id,:mg_collection_id=>nil).pluck(:mg_fee_fine_particular_id)      
     
  if paid_fines.empty?

  @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ?',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? ',params[:id],@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)
  @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? ',@studentbatch.id, Date.today).pluck(:amount,:fine_name,:fine_from,:id)

  else
    @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
    @fee_fine_particulars_hash=MgFeeFineParticular.where('mg_student_id= ? AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',params[:id],@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)
      @fee_fine_particulars_hash+=MgFeeFineParticular.where('mg_student_id IS NULL AND mg_batch_id= ? AND start_date <= ? and id NOT IN (?)',@studentbatch.id, Date.today,paid_fines).pluck(:amount,:fine_name,:fine_from,:id)



  end
render :layout => false
end


  def fee_submission_status


  end


  def edit

    @fesses = MgFeeCategory.find(params[:id])
    
    @mg_batch_list=MgBatch.where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id]).pluck(:name,:id, :mg_course_id) 

    @mg_fee_category_batch_list=MgFeeCategoryBatches.where(:mg_fee_id=>params[:id]).pluck(:mg_batch_id,:id)
    @dueFine=MgParticularType.where(:mg_fee_category_id=>params[:id])
    

    render :layout => false
  end

  def update_category
    
    @feeCategoryObj = MgFeeCategory.find(params[:id])
                 
          @updateparticulars=params[:particulars]
      @particulartypeId=params[:particularstype]
     
                
                
  for i in 0 ... @updateparticulars.size
  @particulartype=MgParticularType.find_by(:mg_fee_category_id=>params[:id],:id=>@particulartypeId[i])                

  if !(@particulartype.nil?)
  @particulartype.update(:particular_name=>@updateparticulars[i])
else
   @particular=MgParticularType.new()
   @particular.particular_name=@updateparticulars[i]
  # puts @updateparticulars[i].inspect
  @particular.mg_fee_category_id=params[:id]
   @particular.is_deleted=0
   @particular.mg_school_id=session[:current_user_school_id]
   puts @particular.inspect
  @particular.save
#logger.infosd
end


end



    # if @particulartype<0

    # else
    # for i in 0 ... @particulartype.size
    #    @particulartype[i].update(:particular_name=>@updateparticulars[i])
    # end
    #     end           

    #@selectedBatchesList = params[:selected_batches]

    #@mg_batch_list=MgBatch.where(:is_deleted => 0, :mg_school_id=> session[:current_user_school_id]).pluck(:id) 

   # @mg_batch_list.each do |batchId|

         # @categoryBatchObj =   MgFeeCategoryBatches.where(:mg_fee_id =>params[:id],:mg_batch_id => batchId) 

         # if @categoryBatchObj.size<1

         #      @selectedBatchesList.each do |selectedBatchId|

         #             if  batchId.to_s == selectedBatchId

         #                @feebatchcategorydetails=MgFeeCategoryBatches.new(:mg_fee_id => params[:id], :mg_batch_id => selectedBatchId) 
         #                @feebatchcategorydetails.save

         #              break  
         #             end

         #          end

         # else
         #      isDelete = true
         #      @selectedBatchesList.each do |selectedBatchId|

         #          if  batchId.to_s == selectedBatchId
         #             isDelete = false 
         #              break
         #          end  

         #      end  

              # if isDelete
              #     @categoryBatchObj[0].destroy
              # end  
         #end

    #end     

     if @feeCategoryObj.update(subject_params)
       redirect_to :back
     else
       render 'edit'
     end

  end

  def destroy
    @fees=MgFeeCategory.find_by_id(params[:id])
    @fees.is_deleted =1
    @fees.save
    redirect_to fees_path
  end

  def delete_fee_category

    @fees=MgFeeCategory.find_by_id(params[:id])
    @fees.is_deleted =1
    @fees.save
    @particularType=MgParticularType.where(:mg_fee_category_id=>params[:id])
    @particularType.each do |delete|
      delete.is_deleted=1
      delete.save
    end
    redirect_to fees_path

  end


  def show_fee_particular
    @fee_particular = MgFeeParticular.find(params[:id])
    render :layout => false
  end
  def show_fine_fee_particular
    @fine_particular = MgFeeFineParticular.find(params[:id])
    render :layout => false
  end

  def edit_fee_particular
    @fesses2 = MgFeeParticular.find(params[:id])
  #   @batches=MgBatch.where(:is_deleted=>0,:mg_school_id=>session[:current_user_school_id])
  #    @info=Array.new
  #  @batches.each do |b|
  #  @info.push(b.id)
  # end
  @cceID=Array.new
  
    
     @cceID.push(@fesses2.mg_batch_id)




    logger.info @fesses2.inspect
    render :layout => false
  end
def edit_fine_fee_particular
  @fesses2 = MgFeeFineParticular.find(params[:id])
  
  @cceID=Array.new
  
    
     @cceID.push(@fesses2.mg_batch_id)

    render :layout => false
end
  def update_fee_particular
    @feeParticularObj = MgFeeParticular.find(params[:id])

    @feeParticularParams = update_particular_params
    @params=params[:selectedStudents]

    if(params[:fesses2][:value1]=='All')
    @feeParticularParams[:admission_no] = ''
    @feeParticularParams[:mg_student_category_id] =''
    end
#@params=params[:selectedStudents]
 #for i in 0...@params.size
  # puts"inside if save particular"
    #@feeParticularObj=MgFeeParticular.new(particular_params) 
  # @data=MgStudent.find(@params[i])
    #@batchID=@data.mg_batch_id
  # @feeParticularObj.mg_batch_id=@batchID
       #@feeParticularObj.admission_no=params[:fesses2][:admission_no]
       #@batchId=MgStudent.where(:admission_number=>params[:fesses2][:admission_no])
       #@feeParticularObj.mg_batch_id=@batchId[0].mg_batch_id
       #puts @batchId[0].mg_batch_id
  # @feeParticularObj.save
# end

    if(params[:fesses2][:value1]=='demo')
      

    @feeParticularParams[:admission_no] =  params[:fesses2][:admission_no] 
    @feeParticularParams[:mg_student_category_id] =''
    end

    if(params[:fesses2][:value1]=='demo2')         
     @feeParticularParams[:admission_no] = ''  
     @feeParticularParams[:mg_student_category_id] =params[:fesses2][:mg_student_category_id]
    end
         
    @feeParticularObj.update(@feeParticularParams)
    redirect_to :action=>'financeFee',:id=>@feeParticularObj.fee_category
  end

  def destroy_fee_particular
    @feesparticular=MgFeeParticular.find(params[:id])
    @fees.is_deleted =1
    @fees.save
    redirect_to :action=>'financeFee',:id=>@feesparticular.fee_category
  end
  def update_fee_fine_particular
   @feeParticularObj = MgFeeFineParticular.find(params[:id])
   @timeformat = MgSchool.find(session[:current_user_school_id])
    @startDate = Date.strptime(params[:fesses2][:start_date],@timeformat.date_format)
    @endDate = Date.strptime(params[:fesses2][:end_date],@timeformat.date_format)
    @dueDate = Date.strptime(params[:fesses2][:due_date],@timeformat.date_format)

    @feeParticularObj.update(:start_date=>@startDate, :end_date=>@endDate, :due_date=>@dueDate)

    @feefineParticularParams = update_fine_particular_params
    @params=params[:selectedStudents]

    if(params[:fesses2][:value1]=='All')
    #@feefineParticularParams[:admission_no] = ''
    @feefineParticularParams[:mg_student_category_id] =''
    end

    if(params[:fesses2][:value1]=='demo')
      

    #@feefineParticularParams[:admission_no] =  params[:fesses2][:admission_no] 
    @feefineParticularParams[:mg_student_category_id] =''
    end

    if(params[:fesses2][:value1]=='demo2')         
     #@feefineParticularParams[:admission_no] = ''  
     @feefineParticularParams[:mg_student_category_id] =params[:fesses2][:mg_student_category_id]
    end
         
    @feeParticularObj.update(@feefineParticularParams)
    redirect_to '/fees/fine_from_index'
  end
  def destroy_fee_fine_particular
    @fees=MgFeeFineParticular.find_by_id(params[:id])
    @fees.is_deleted =1
    @fees.save
    redirect_to '/fees/fine_from_index'
  end

  def delete_fee_particular
    @fees=MgFeeParticular.find_by_id(params[:id])
    @fees.update(:is_deleted=>1)
    redirect_to :action=>'financeFee',:id=>@fees.fee_category

  end

  def student_number
    render :layout => false
  end

  def student_category
    render :layout=>false
  end
  def fee_recept
    @batch_list=MgBatch.where(:is_deleted=>0, :mg_school_id=>session[:current_user_school_id])
    @course_list=MgCourse.where(:is_deleted=>0, :mg_school_id=>session[:current_user_school_id])
  end
  def fee_report_for_student
    params[:mg_student_id]
    @finance_transaction=MgFinanceTransaction.where(:is_deleted=>0, :mg_school_id=>session[:current_user_school_id], :mg_student_id=>params[:mg_student_id])
    render :layout=>false
    
  end

  def generate_fee_pdf
    

    fee_transaction = MgFinanceTransaction.find(params[:id])

    receipt_no=params[:id]
    @school_id=session[:current_user_school_id]
    @dateFormat = MgSchool.find(@school_id).date_format
      if fee_transaction.transaction_date.present?
        date=fee_transaction.transaction_date.strftime(@dateFormat)
      end

    mg_student_id=fee_transaction.mg_student_id
    student=MgStudent.find(mg_student_id)
    @@photo=student.avatar.url(:medium,:timestamp=>false)
    puts "==========================="
    puts @photo
    batch_name=MgBatch.find(student.mg_batch_id)

    fee_transaction_detail = MgFinanceTransactionDetail.where(:mg_transaction_id=>fee_transaction.id)
    fine_detail = MgFinanceTransactionDetail.where(:mg_transaction_id=>fee_transaction.id,:detail_type=> 'fine')
    
    collection_ids = fee_transaction_detail.where("mg_collection_id is not null").pluck("DISTINCT mg_collection_id")
    
    school=MgSchool.find(session[:current_user_school_id])
@@school_logo=school.logo.url(:medium,:timestamp=>false)
    pdf = Prawn::Document.new(:size=>1) do
    # pdf.table data, 
    
    # :font_size => 7,
    # :row_colors => ["EEEEEE", "FFFFFF"]
# water mark
    # create_stamp("approved this") do
    #         rotate(30, :origin => [-5, -5]) do
    #         stroke_color "FF3333"
    #         stroke_ellipse [0, 0], 100, 50
    #         stroke_color "000000"
    #         fill_color "993456"
    #         font("Times-Roman") do
    #         draw_text "approved this", :at => [-23, -3]
    #         end
    #         fill_color "000000"
    #         end
    #         end
    #         stamp "approved this"
    #         stamp_at "approved this", [200, 400]
    
      repeat [1] do
        # header

        bounding_box [bounds.left, bounds.top],:align => :right, :width  => bounds.width do
            font "Helvetica"
            if File.exists?("#{Rails.root}/public/#{@@school_logo}") 

      image ("#{Rails.root}/public/#{@@school_logo}"),:width=>45
        end
       
            text school.school_name, :align => :center, :size => 18
            stroke_horizontal_rule
        end
        move_down 10
        
# if File.exists?("#{Rails.root}/public/#{@@photo}") 
#         #puts File.exists?
#         puts @@photo.inspect
#          image ("#{Rails.root}/public/#{@@photo}"),:at=>[425,690],:width=>45
#         # image school.logo.url(:medium, timestamp: false), :width => 45
#       else
#       end
        text "Receipt No : #{receipt_no} Payment Date : #{date}"
        move_down 5        
        text "Name: #{student.first_name} #{student.last_name}" 
        text "Admission Number: #{student.admission_number}"
        text "Class & Section: #{batch_name.course_batch_name}"
        
        move_down 5

        #cell size
        widths = [125,125,125,125]
        cell_height = 10
        font_size=8

        table([["Sl No", "Particular", "Amount","Partial Payment"]], :column_widths => widths, :cell_style => { size: font_size }) 
        sl_no=1
        collection_ids.each do |c_id|
          #collection_record = MgFeeCollection.find(c_id)

          particular_list = fee_transaction_detail.where(:detail_type=> 'particular' ,:mg_collection_id =>c_id)
          discount_list   = fee_transaction_detail.where(:detail_type=> 'discount' ,:mg_collection_id =>c_id)
          late_fine_list  = fee_transaction_detail.where(:detail_type=> 'late' ,:mg_collection_id =>c_id)
          collection_id =c_id
          puts "c_id"
          puts c_id
          move_down 5
          text MgFeeCollection.find(c_id).name

          particular_list.each do |particular|
            if particular.is_partial_payment
              partial_payment='Yes'
            else
               partial_payment='No'
            end
            table([[sl_no, MgFeeCollectionParticular.find(particular.mg_fee_particular_id).mg_fee_particular_name , particular.paid_amount, partial_payment]], :column_widths => widths, :cell_style => { size: font_size }) 
            sl_no +=1
          end#particular  
            
          if discount_list.size>0 
          move_down(5) 
           text "Discount", :align => :center
          discount_list.each do |particular|
            if particular.is_partial_payment
              partial_payment=''
            else
               partial_payment=''
            end
             table([[sl_no, particular.collection_discount_name, particular.paid_amount, partial_payment]], :column_widths => widths, :cell_style => { size: font_size }) 
            sl_no +=1
          end
          end#discount  
      
          if late_fine_list.size>0 
          move_down(5) 
          text "Late Fine", :align => :center   
          late_fine_list.each do |particular|
            if particular.is_partial_payment
              partial_payment=""
            else
               partial_payment=""
            end
               table([[sl_no, MgFeeFine.find(particular.late_fee_fine_id).fine_name , particular.paid_amount, partial_payment]], :column_widths => widths, :cell_style => { size: font_size }) 
            sl_no +=1
          end#late  
          end
         end#collection  

         if fine_detail.size>0
          move_down(10) 
         text "Fine"
         fine_detail.each do |particular|
           table([[sl_no, MgFeeFineParticular.find(particular.mg_fee_fine_particular_id).fine_name, particular.paid_amount, ""]], :column_widths => widths, :cell_style => { size: font_size }) 
            sl_no +=1
          end  
         end#fine  
move_down(10)
       widths_for=[70,66,56,56,100,156]

         text "Mode of Payment:#{fee_transaction.payment_mode}"
         if fee_transaction.payment_mode=="by_cash"
         elsif fee_transaction.payment_mode=="by_cheque"
       table([
                       ["Cheque No","#{fee_transaction.cheque_number}", "Date","#{fee_transaction.date_of_cheque}","Bank name And Branch","#{fee_transaction.bankname_and_branch}"]
                      ],:column_widths => widths_for, :cell_style => { size: font_size }) 
     else
      table([
                       ["Draft No","#{fee_transaction.draft_number}", "Date","#{fee_transaction.date_of_draft}","Bank name And Branch","#{fee_transaction.bankname_and_branch}"]
                      ],:column_widths => widths_for, :cell_style => { size: font_size }) 
    end
         move_down(10)
         text "Total amount paid : #{fee_transaction.amount}" ,:align=>:center

       

    
         # footer
        bounding_box [bounds.left, bounds.bottom + 45], :width  => bounds.width do
              font "Helvetica"
              stroke_horizontal_rule
              move_down(5)
              # image "#{Rails.root}/app/assets/images/mindcom-logo.png", :width => 45, :align => :left
              # text " Powered By - ©", :size => 12
              move_down 12
              #draw_text "Terms & Conditions| Privacy Policy| About Us| Contact Us",:at => [70,3]
              draw_text "Powered By - ©", :at => [400,3]
              image "#{Rails.root}/app/assets/images/mindcom-logo.png", :at=>[495,15], :width => 45, :align => :right
          end
       
      end

       


    # start_new_page
    end
    
    send_data pdf.render, :filename => "x.pdf", :type => "application/pdf", :disposition => 'inline'
  end

  #Bindhu Added for account starts
  def account_detail
    @accounts=MgAccount.where(:is_deleted=>0,:mg_school_id=>session[:current_user_school_id]).pluck(:mg_account_name,:id)
    @particular=MgFeeParticular.where(:is_deleted=>0,:mg_school_id=>session[:current_user_school_id],:fee_category=>params[:fee_category],:mg_particular_type_id=>params[:particular_type_id]).pluck(:mg_account_id)
    @is_to_central=MgFeeParticular.where(:is_deleted=>0,:mg_school_id=>session[:current_user_school_id],:fee_category=>params[:fee_category],:mg_particular_type_id=>params[:particular_type_id]).pluck(:is_to_central)
    puts @particular
    puts @is_to_central
    render :layout=>false

  end
  #Bindhu Added for account end


  private

  def subject_params
    params.require(:fesses).permit(:name,:description,:is_deleted, :mg_school_id)
  end
  def particular_params
    params.require(:fesses2).permit(:mg_particular_type_id,:description,:fee_category,:is_deleted, :mg_school_id,:amount,
     :admission_no, :mg_student_category_id)
  end

  def update_particular_params
    params.require(:fesses2).permit(:name,:description,:fee_category,:is_deleted, :mg_school_id,:amount, :admission_no, :mg_student_category_id)
  end

     
   def batch_params
    params.require(:fesses).permit(:mg_batch_id)
  end

  def fee_discount_params
    params.require(:fee_discount).permit(:discount_type, :name,:mg_receiver_id,:mg_fee_category_id,:discount,:is_percent,:is_deleted, :mg_school_id)
  end

  def fee_fine_params
    params.require(:generate_fine_form).permit(:fine_name, :fine_description, :is_deleted, :mg_school_id)
  end

  def fee_fine_due_params
    params.require(:dueFine).permit(:days_after_due_date, :amount, :is_percent,:is_deleted, :mg_school_id)
  end
  def fine_particular_params
    params.require(:fesses2).permit(:fine_name,:description,:fine_from,:is_deleted, :mg_school_id,:amount,
     :admission_no, :mg_student_category_id)
  end
  def update_fine_particular_params
    params.require(:fesses2).permit(:fine_name,:description,:fine_from,:is_deleted, :mg_school_id,:amount,
     :mg_student_category_id)
  end
end
