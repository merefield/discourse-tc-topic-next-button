import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { array } from "@ember/helper";
import { service } from "@ember/service";
import { settings, themePrefix } from "virtual:theme";
import {
  nextTopicUrl,
  previousTopicUrl,
  setTopicId,
} from "discourse/lib/topic-list-tracker";
import { TOPIC_URL_REGEXP } from "discourse/lib/url";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

class TopicNextLink extends Component {
  @tracked nextUrl;

  constructor() {
    super(...arguments);

    const topic = this.args.topic;
    const categories = settings.topic_next_categories;
    if (
      !categories ||
      categories.split("|").includes(String(topic.category_id))
    ) {
      this.#loadNextUrl(topic.id);
    }
  }

  async #loadNextUrl(topicId) {
    try {
      setTopicId(topicId);
      const previous = previousTopicUrl();
      setTopicId(topicId);
      const [url, previousUrl] = await Promise.all([nextTopicUrl(), previous]);

      // The tracker returns the first list entry in both directions when the topic is absent.
      if (!this.isDestroying && url && url !== previousUrl) {
        this.nextUrl = settings.topic_next_always_go_to_first_post
          ? url.replace(TOPIC_URL_REGEXP, "/t/$1/$2")
          : url;
      }
    } finally {
      if (!this.isDestroying) {
        // Looking up the next URL advances the cursor used by keyboard shortcuts.
        setTopicId(topicId);
      }
    }
  }

  <template>
    {{#if this.nextUrl}}
      <a
        class={{dConcatClass
          "btn btn-primary topic-next-button"
          (unless @compact "--footer")
        }}
        href={{this.nextUrl}}
      >
        <span class={{if @compact "sr-only"}}>
          {{i18n (themePrefix "topic_next_label")}}
        </span>
        {{dIcon "chevron-right"}}
      </a>
    {{/if}}
  </template>
}

export default class TopicNextButton extends Component {
  @service capabilities;

  get shouldRender() {
    const topic = this.args.topic;
    const hasCompactProgress =
      !this.capabilities.viewport.sm &&
      !topic.is_nested_view &&
      topic.posts_count > 1;

    return hasCompactProgress === Boolean(this.args.compact);
  }

  <template>
    {{#if this.shouldRender}}
      {{#each (array @topic) key="id" as |topic|}}
        <TopicNextLink @compact={{@compact}} @topic={{topic}} />
      {{/each}}
    {{/if}}
  </template>
}
