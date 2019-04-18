require 'application_system_test_case'

class ActivityTest < ApplicationSystemTestCase
  def setup
    @user = users(:user_with_teammates)
    login_as @user
    @match = matches(:content_match)
  end

  test 'user can upload an activity' do
    Poll.delete_all
    visit new_match_activity_path(@match)
    fill_in 'activity[name]', with: 'Test'
    fill_in 'activity[description]', with: 'Test location'
    fill_in 'activity[pitch_audience]', with: 'Test location'
    fill_in 'activity[abstract_outline]', with: 'Test location'

    fill_in 'add_location_input', with: 'Test location'
    find(:css, "input[id$='add_location_input']").native.send_keys(:enter)
    click_button 'Enviar'
    assert page.has_content?(I18n.t('activities.messages.uploaded'))
    assert page.has_content?('Test')
  end

  test 'user can edit an activity' do
    visit match_team_path(@match, @user.team)
    within('.activities-table') do
      find("a[href='/match/#{@match.id}/activities/rails-as-a-day-to-day/edit']").click
    end
    fill_in 'activity[name]', with: 'Django as a Day to Day'
    click_button 'Enviar'
    assert page.has_content?(I18n.t('activities.messages.updated'))
    assert page.has_content?('Django as a Day to Day')
  end

  test 'user can delete an activity' do
    visit match_team_path(@match, @user.team)
    activity = activities(:ruby_as_day_to_day)
    within('.activities-table') do
      find("a[href='/match/#{@match.id}/activities/#{activity.slug}'][data-method='delete']").click
    end
    page.driver.browser.switch_to.alert.accept
    assert page.has_content?(I18n.t('activities.messages.deleted'))
  end

  test 'user can vote for an activity' do
    visit match_poll_path(@match, Poll.last)
    find("a[href='/match/#{@match.id}/polls/#{Poll.last.id}/activities/poo-java/votes']").click
    assert page.has_content?(I18n.t('votes.voted'))
  end

  test 'user can delete its vote for an activity' do
    visit match_poll_path(@match, Poll.last)
    vote = votes(:java_vote)
    activity = activities(:activity_post)
    find("a[href='/match/#{@match.id}/polls/#{Poll.last.id}/activities/#{activity.slug}/votes/#{vote.id}']").click
    page.driver.browser.switch_to.alert.accept
    assert page.has_content?(I18n.t('votes.unvoted'))
  end
end
