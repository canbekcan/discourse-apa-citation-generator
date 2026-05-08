import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import dIcon from "discourse-common/helpers/d-icon";
import I18n from "discourse-i18n";

export default class ApaCitationBox extends Component {
  get topic() {
    return this.args.outletArgs?.model;
  }

  // Güvenli Dil Tespiti
  get currentLocale() {
    return I18n.currentLocale() || "en";
  }

  get noDateString() {
    return this.currentLocale === "tr" ? "t.y." : "n.d.";
  }

  // Template içindeki çökmeyi önleyen buton hover metni
  get copyTitle() {
    return this.currentLocale === "tr" ? "Kopyala" : "Copy";
  }

  get authorApaName() {
    try {
      const creator = this.topic?.details?.created_by;
      if (!creator) return this.currentLocale === "tr" ? "Bilinmeyen Yazar" : "Unknown Author";
      
      const fullName = creator.name || creator.username || "";
      const parts = fullName.trim().split(/\s+/);
      
      if (parts.length > 1) {
        const lastName = parts.pop();
        const initials = parts.map(p => p.charAt(0).toUpperCase() + ".").join(" ");
        return `${lastName}, ${initials}`;
      }
      return fullName;
    } catch (e) {
      return "";
    }
  }

  get publicationDate() {
    const createdAt = this.topic?.created_at;
    if (!createdAt) return this.noDateString;
    
    try {
      const date = new Date(createdAt);
      const year = date.getFullYear();
      const day = date.getDate();
      
      let month = "";
      try {
         // Intl motoru dil değişim anında hata verirse diye try-catch içinde tutuyoruz
         month = new Intl.DateTimeFormat(this.currentLocale, { month: 'long' }).format(date);
      } catch(err) {
         month = date.toLocaleString('en', { month: 'long' });
      }

      return this.currentLocale === "en" 
        ? `${year}, ${month} ${day}` 
        : `${year}, ${day} ${month}`;
    } catch (e) {
      return this.noDateString;
    }
  }

  get topicTitle() {
    return this.topic?.title || "";
  }

  get topicUrl() {
    if (!this.topic?.url) return window.location.href;
    return `${window.location.origin}${this.topic.url}`;
  }

  get fullCitation() {
    return `${this.authorApaName} (${this.publicationDate}). ${this.topicTitle}. ${window.location.hostname}. ${this.topicUrl}`;
  }

  @action
  copyToClipboard() {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(this.fullCitation);
    }
  }

  <template>
    {{#if this.topic}}
      <div class="apa-citation-container inline-layout">
        <div class="apa-citation-content">
          <span class="apa-full-text">
            <span class="apa-author">{{this.authorApaName}}</span>
            <span class="apa-year">({{this.publicationDate}}).</span>
            <span class="apa-topic-title"><i>{{this.topicTitle}}</i>.</span>
            <span class="apa-site">{{window.location.hostname}}.</span>
            <a href={{this.topicUrl}} class="apa-url">{{this.topicUrl}}</a>
          </span>
          <button class="btn btn-default apa-copy-btn-compact" type="button" {{on "click" this.copyToClipboard}} title={{this.copyTitle}}>
            {{dIcon "copy"}}
          </button>
        </div>
      </div>
    {{/if}}
  </template>
}