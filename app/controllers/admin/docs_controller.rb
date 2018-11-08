class Admin::DocsController < Admin::ApplicationController
  before_action :set_doc, only: [:show, :edit, :update, :destroy]

  def index
    @docs = Doc.includes(:repository).order("id desc")
    if params[:repository_id]
      @docs = @docs.where(repository_id: params[:repository_id])
    end
    @docs = @docs.page(params[:page])
  end

  def show
  end

  def new
    @doc = Doc.new
  end

  def edit
  end

  def create
    @doc = Doc.new(doc_params)

    if @doc.save
      redirect_to(admin_docs_path, notice: "Doc was successfully created.")
    else
      render :new
    end
  end

  def update
    if @doc.update(doc_params)
      redirect_to admin_docs_path, notice: "Doc was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @doc.destroy
    redirect_to admin_docs_path, notice: "Doc was successfully deleted."
  end

  private

    def set_doc
      @doc = Doc.find(params[:id])
    end

    def doc_params
      params.require(:doc).permit!
    end
end
