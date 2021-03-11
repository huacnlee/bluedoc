# frozen_string_literal: true

class Admin::DocsController < Admin::ApplicationController
  before_action :set_doc, only: [:show, :edit, :update, :destroy, :restore]

  def index
    @docs = Doc.unscoped.includes(:repository).order("id desc")
    if params[:repository_id]
      @docs = @docs.where(repository_id: params[:repository_id])
    end
    if params[:q]
      q = "%#{params[:q]}%"
      @docs = @docs.where("title ilike ? or slug ilike ?", q, q)
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
      redirect_to admin_docs_path, notice: t(".Doc was successfully created")
    else
      render :new
    end
  end

  def update
    if @doc.update(doc_params)
      redirect_to admin_docs_path, notice: t(".Doc was successfully updated")
    else
      render :edit
    end
  end

  def destroy
    if params[:permanent]
      @doc.versions.unscoped.delete_all
      @doc.comments.unscoped.delete_all
      @doc.permanent_destroy
    else
      @doc.destroy
    end

    redirect_to admin_docs_path(repository_id: @doc.repository_id, q: @doc.slug), notice: t(".Doc was successfully deleted")
  end

  # PRO-begin
  def restore
    @doc.restore
    redirect_to admin_docs_path(repository_id: @doc.repository_id, q: @doc.slug), notice: t(".Doc was successfully restored")
  end
  # PRO-end

  private
    def set_doc
      @doc = Doc.unscoped.find(params[:id])
    end

    def doc_params
      params.require(:doc).permit!
    end
end
