import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import dIcon from "discourse-common/helpers/d-icon";
import I18n from "discourse-i18n";

export default class ApaCitationBox extends Component {
  get topic() {
    return this.args.outletArgs?.model;
  }

  // Kullanıcının seçtiği dile göre "tarih yok" ifadesi
  get noDateString() {
    const locale = I18n.currentLocale();
    return locale === "tr_TR" ? "t.y." : "n.d.";
  }

  get authorApaName() {
    const creator = this.topic?.details?.created_by;
    if (!creator) return I18n.t("unknown");
    
    const fullName = creator.name || creator.username;
    const parts = fullName.trim().split(/\s+/);
    
    if (parts.length > 1) {
      const lastName = parts.pop();
      const initials = parts.map(p => p.charAt(0).toUpperCase() + ".").join(" ");
      return `${lastName}, ${initials}`;
    }
    return fullName;
  }

  // Dile duyarlı tarih fonksiyonu
  get publicationDate() {
    if (!this.topic?.created_at) return this.noDateString;
    
    const date = new Date(this.topic.created_at);
    const locale = I18n.currentLocale();
    
    const year = date.getFullYear();
    const day = date.getDate();
    const month = date.toLocaleString(locale, { month: 'long' });

    // APA formatı: İngilizce için (Year, Month Day), Türkçe için (Yıl, Gün Ay)
    return locale === "en" 
      ? `${year}, ${month} ${day}` 
      : `${year}, ${day} ${month}`;
  }

  get topicTitle() {
    // Discourse zaten aktif dile göre başlığı getirir
    return this.topic?.title;
  }

  get topicUrl() {
    return `${window.location.origin}${this.topic?.url}`;
  }

  get siteName() {
    return window.location.hostname;
  }

  get fullCitation() {
    return `${this.authorApaName} (${this.publicationDate}). ${this.topicTitle}. ${this.siteName}. ${this.topicUrl}`;
  }

  @action
  copyToClipboard() {
    navigator.clipboard.writeText(this.fullCitation);
    // İsteğe bağlı: Kopyalandı bildirimi eklenebilir
  }

  <template>
    {{#if this.topic}}
      <div class="apa-citation-container inline-layout">
        <div class="apa-citation-content">
          <span class="apa-full-text">
            <span class="apa-author">{{this.authorApaName}}</span>
            <span class="apa-year">({{this.publicationDate}}).</span>
            <span class="apa-topic-title"><i>{{this.topicTitle}}</i>.</span>
            <span class="apa-site">{{this.siteName}}.</span>
            <a href={{this.topicUrl}} class="apa-url">{{this.topicUrl}}</a>
          </span>
          <button class="btn btn-default apa-copy-btn-compact" type="button" {{on "click" this.copyToClipboard}} title={{I18n.t "copy_to_clipboard"}}>
            {{dIcon "copy"}}
          </button>
        </div>
      </div>
    {{/if}}
  </template>
}