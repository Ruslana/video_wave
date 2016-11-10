class VideoFilesController < ApplicationController
  before_filter :set_resource, only: [:update, :edit, :destroy]

  def index
    @video_files = VideoFile.all
  end

  def new
    @video_file = VideoFile.new
  end

  def update
    @resource.assign_attributes(permitted_params)
    if @resource.save!
      redirect_to video_files_path
    else
      render :edit
    end
  end

  def create
    @video_file = VideoFile.new(permitted_params)
    if @video_file.save!
      redirect_to video_files_path
    else
      render :new
    end
  end

  private

  def set_resource
    @resource = VideoFile.find(params[:id])
  end

  def permitted_params
    params.require(:video_file).permit(:watermark, :file)
  end
end
