# frozen_string_literal: true

module PageObjects
  module Components
    class TopicNextButton < PageObjects::Components::Base
      SELECTOR = ".topic-next-button"

      def click
        find(SELECTOR).click
      end

      def has_link?
        has_css?(SELECTOR)
      end

      def has_floating_link?
        has_css?(".mobile-tab-bar-visible .topic-navigation.with-topic-progress > #{SELECTOR}")
      end

      def has_no_link?
        has_no_css?(SELECTOR)
      end
    end
  end
end
