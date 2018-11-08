class <%= controller_class_name %>Controller < <%= controller_class_name.include?('::') == true ? "#{controller_class_name.split('::').first}::" : ''  %>ApplicationController
  before_action :set_<%= file_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_file_name %> = <%= file_name.camelize %>.order("id desc")
    @<%= plural_file_name %> = @<%= plural_file_name %>.page(params[:page])
  end

  def show
  end

  def new
    @<%= file_name %> = <%= orm_class.build(file_name.camelize) %>
  end

  def edit
  end

  def create
    @<%= file_name %> = <%= orm_class.build(file_name.camelize, "#{file_name}_params") %>

    if @<%= file_name %>.save
      redirect_to(<%= index_helper %>_path, notice: "<%= human_name %> was successfully created.")
    else
      render :new
    end
  end

  def update
    if @<%= file_name %>.update(<%= file_name %>_params)
      redirect_to <%= index_helper %>_path, notice: "<%= human_name %> was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @<%= file_name %>.destroy
    redirect_to <%= index_helper %>_path, notice: "<%= human_name %> was successfully deleted."
  end

  private

    def set_<%= file_name %>
      @<%= file_name %> = <%= orm_class.find(file_name.camelize, "params[:id]") %>
    end

    def <%= file_name %>_params
      params.require(:<%= file_name %>).permit!
    end
end
