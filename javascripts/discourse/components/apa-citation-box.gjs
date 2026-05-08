import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import dIcon from "discourse-common/helpers/d-icon";
import I18n from "discourse-i18n";

export default class ApaCitationBox extends Component {
  get topic() {
    return this.args.outletArgs?.model;
  }

  get safeLocale() {
    const locale = I18n.currentLocale() || "en";
    return locale.replace(/_/g, "-");
  }

  get isTurkish() {
    return this.safeLocale.toLowerCase().startsWith("tr");
  }

  get noDateString() {
    return this.isTurkish ? "t.y." : "n.d.";
  }

  get copyTitle() {
    return this.isTurkish ? "Kopyala" : "Copy";
  }

  get siteName() {
    // Template içinde window kullanılamadığı için bilgiyi JS tarafında çekiyoruz
    return window.location.hostname;
  }

  get authorApaName() {
    try {
      const creator = this.topic?.details?.created_by;
      if (!creator) return this.isTurkish ? "Bilinmeyen Yazar" : "Unknown Author";
      
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
      const monthIndex = date.getMonth(); 
      
      const monthsEn = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      const monthsTr = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];

      const monthName = this.isTurkish ? monthsTr[monthIndex] : monthsEn[monthIndex];

      return this.isTurkish 
        ? `${year}, ${day} ${monthName}` 
        : `${year}, ${monthName} ${day}`;
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
    return `${this.authorApaName} (${this.publicationDate}). ${this.topicTitle}. ${this.siteName}. ${this.topicUrl}`;
  }

  @action
  copyToClipboard() {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(this.fullCitation);
    }
  }

  <template>
    {{#if this.topic}}
      <div class="apa-citation-container-v2">
        <div class="apa-citation-wrapper">
          <div class="apa-citation-text">
            <span class="apa-author">{{this.authorApaName}}</span>
            <span class="apa-year">({{this.publicationDate}}).</span>
            <span class="apa-topic-title"><i>{{this.topicTitle}}</i>.</span>
            {{! window object'i yerine safe getter olan this.siteName'i cagiriyoruz }}
            <span class="apa-site">{{this.siteName}}.</span>
            <a href={{this.topicUrl}} class="apa-url">{{this.topicUrl}}</a>
          </div>
          <button class="btn btn-default apa-copy-icon-only" type="button" {{on "click" this.copyToClipboard}} title={{this.copyTitle}}>
            {{dIcon "copy"}}
          </button>
        </div>
      </div>
    {{/if}}
  </template>
}