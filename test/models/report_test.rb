# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @report = reports(:one)
    @report2 = reports(:two)
    @user = users(:alice)
  end

  test '#editable?' do
    assert @report.editable?(@user)
  end

  test '#created_on' do
    assert_equal Time.current.to_date, @report.created_on
  end

  test '#save_mentions' do
    no_mention_report = @user.reports.create!(user: users(:alice), title: 'あいさつ', content: 'こんにちは')
    assert_equal [], no_mention_report.mentioning_reports

    mention_report = @user.reports.create!(user: users(:alice), title: 'URL添付', content: " http://localhost:3000/reports/#{@report.id}")
    assert_equal [@report], mention_report.mentioning_reports

    no_mention_report.update!(content: "http://localhost:3000/reports/#{@report.id}")
    assert_equal [@report], no_mention_report.mentioning_reports

    mention_report.destroy
    assert_equal [], no_mention_report.mentioned_reports
  end
end
