import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import dIcon from "discourse-common/helpers/d-icon";

export default class ApaCitationBox extends Component {
  get topic() {
    // outletArgs üzerinden o anki Topic modeline erişim sağlanır.
    return this.args.outletArgs?.model;
  }

  get authorApaName() {
    const creator = this.topic?.details?.created_by;
    if (!creator) return "Yazar Bilinmiyor";
    
    // Yazarın Discourse profilindeki "Ad Soyad" (name) alanını önceliklendiriyoruz.
    // Yoksa kullanıcı adını (username) baz alır.
    const fullName = creator.name || creator.username;
    const parts = fullName.trim().split(" ");
    
    if (parts.length > 1) {
      const lastName = parts.pop();
      const initials = parts.map(p => p.charAt(0).toUpperCase() + ".").join(" ");
      return `${lastName}, ${initials}`;
    }
    return fullName;
  }

  get publicationYear() {
    if (!this.topic?.created_at) return new Date().getFullYear();
    return new Date(this.topic.created_at).getFullYear();
  }

  get topicTitle() {
    return this.topic?.title;
  }

  get topicUrl() {
    return `${window.location.origin}/t/${this.topic?.slug}/${this.topic?.id}`;
  }

  get siteName() {
    return window.location.hostname;
  }

  get fullCitation() {
    return `${this.authorApaName} (${this.publicationYear}). ${this.topicTitle}. ${this.siteName}. ${this.topicUrl}`;
  }

  @action
  copyToClipboard() {
    navigator.clipboard.writeText(this.fullCitation).then(() => {
      // Modern tarayıcılarda panoya kopyalama işlemi başarılı.
      // Dilerseniz buraya bir Toast/Alert bildirimi entegre edebilirsiniz.
    });
  }

  <template>
    {{#if this.topic}}
      <div class="apa-citation-container">
        <div class="apa-citation-header">
          <span class="apa-title">{{dIcon "graduation-cap"}} Bu İçeriğe Atıf Yapın (APA Formatı)</span>
          <button class="btn btn-default apa-copy-btn" type="button" {{on "click" this.copyToClipboard}}>
            {{dIcon "copy"}} Kopyala
          </button>
        </div>
        <div class="apa-citation-content">
          <span class="apa-author">{{this.authorApaName}}</span>
          <span class="apa-year">({{this.publicationYear}}).</span>
          <span class="apa-topic-title"><i>{{this.topicTitle}}</i>.</span>
          <span class="apa-site">{{this.siteName}}.</span>
          <a href={{this.topicUrl}} class="apa-url">{{this.topicUrl}}</a>
        </div>
      </div>
    {{/if}}
  </template>
}