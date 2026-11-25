# frozen_string_literal: true

require_relative "page_objects/components/topic_next_button"

RSpec.describe "Navigate to the next topic" do
  fab!(:user)
  fab!(:category)
  fab!(:next_topic) { Fabricate(:new_reply_topic, category:, current_user: user) }
  fab!(:first_topic) { Fabricate(:topic_with_op, category:) }

  let!(:theme) { upload_theme_component }
  let(:category_page) { PageObjects::Pages::Category.new }
  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:topic_list) { PageObjects::Components::TopicList.new }
  let(:next_button) { PageObjects::Components::TopicNextButton.new }

  before do
    first_topic.update!(bumped_at: 1.minute.ago)
    next_topic.update!(bumped_at: 1.hour.ago)
    sign_in(user)
  end

  it "opens the first post of the next topic and hides the link at the end of the list" do
    category_page.visit(category)
    topic_list.visit_topic(first_topic)

    next_button.click

    expect(page).to have_current_path(next_topic.relative_url)
    expect(topic_page).to have_topic_title(next_topic.title)
    expect(next_button).to have_no_next_topic_link
  end

  it "opens the next unread post from compact navigation when configured", mobile: true do
    SiteSetting.mobile_footer_navigation = true
    Fabricate(:post, topic: first_topic)
    theme.update_setting(:topic_next_always_go_to_first_post, false)
    theme.save!

    category_page.visit(category)
    topic_list.visit_topic(first_topic)

    expect(next_button).to have_floating_link
    next_button.click

    expect(page).to have_current_path(next_topic.relative_url(2))
    expect(topic_page).to have_topic_title(next_topic.title)
  end

  it "shows the link only in the selected categories" do
    another_category = Fabricate(:category)
    another_topic = Fabricate(:topic_with_op, category: another_category)
    Fabricate(:topic_with_op, category: another_category, bumped_at: 1.hour.ago)

    theme.update_setting(:topic_next_categories, category.id.to_s)
    theme.save!

    category_page.visit(category)
    topic_list.visit_topic(first_topic)
    expect(next_button).to have_next_topic_link

    category_page.visit(another_category)
    topic_list.visit_topic(another_topic)
    expect(topic_page).to have_topic_title(another_topic.title)
    expect(next_button).to have_no_next_topic_link
  end

  it "hides the link when opening a topic directly" do
    topic_page.visit_topic(first_topic)

    expect(topic_page).to have_topic_title(first_topic.title)
    expect(next_button).to have_no_next_topic_link
  end
end
