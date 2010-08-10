class <%= controller_class_name %>Controller < ApplicationController
  respond_to :html, :json, :xml

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
    respond_with @<%= plural_table_name %>
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with @<%= singular_table_name %>
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    respond_with @<%= singular_table_name %>
  end

  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    flash[:notice] = '<%= human_name %> was successfully created.' if @<%= orm_instance.save %>
    respond_with @<%= singular_table_name %>
  end

  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    flash[:notice] = '<%= human_name %> was successfully updated.' if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
    respond_with @<%= singular_table_name %>
  end

  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>
    respond_with @<%= singular_table_name %>, :location => <%= index_helper %>_url
  end
end