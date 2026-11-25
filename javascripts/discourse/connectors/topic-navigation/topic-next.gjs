import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { settings, themePrefix } from "virtual:theme";
import {
  nextTopicUrl,
  previousTopicUrl,
  setTopicId,
} from "discourse/lib/topic-list-tracker";
import { TOPIC_URL_REGEXP } from "discourse/lib/url";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class TopicNext extends Component {
  @tracked nextUrl;

  constructor() {
    super(...arguments);

    const topic = this.args.outletArgs.topic;
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
      <a class="btn btn-primary topic-next-button" href={{this.nextUrl}}>
        {{dIcon "chevron-right"}}
        <span class={{unless @outletArgs.renderTimeline "sr-only"}}>
          {{i18n (themePrefix "topic_next_label")}}
        </span>
      </a>
    {{/if}}
  </template>
}
