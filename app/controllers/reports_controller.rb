# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]
  before_action :add_new_mentions, :destroy_mentions, only: %i[update]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)
    if @report.save
      if @report.content.include?('http://localhost:3000')
        mentioned_ids = @report.content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq
        mentioned_ids.each do |mentioned_id|
          @mention = Mention.new(mentioning_report_id: @report.id, mentioned_report_id: mentioned_id.to_i)
          @mention.save
        end
      end
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(report_params)
      if @report.content.include?('http://localhost:3000')
        add_new_mentions
        destroy_mentions
      else
        # メンションが含まれない場合は、すべての関連付けを削除
        @report.mentioning_reports.clear
      end

      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

  # 新しい関連付けを追加
  def add_new_mentions
    mentioned_ids = @report.content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq
    mentioned_ids.each do |mentioned_id|
      mentioned_report = Report.find_by!(id: mentioned_id.to_i)
      @report.mentioning_reports << mentioned_report if mentioned_report.present? && @report.mentioning_reports.exclude?(mentioned_report) # rubocopのため後置if
    end
  end

  # 関連付けの削除
  def destroy_mentions
    mentioned_ids = @report.content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq
    @report.mentioning_reports.each do |mentioning_report|
      unless mentioned_ids.include?(mentioning_report.id.to_s)
        @report.mentioning_reports.delete(mentioning_report)
      end
    end
  end
end
