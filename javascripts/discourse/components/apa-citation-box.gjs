import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import dIcon from "discourse-common/helpers/d-icon";
import I18n from "discourse-i18n";

export default class ApaCitationBox extends Component {
  get topic() {
    return this.args.outletArgs?.model;
  }

  // Güvenli Dil Kontrolü
  get isTurkish() {
    const locale = I18n.currentLocale() || "en";
    return locale.toLowerCase().startsWith("tr");
  }

  get noDateString() {
    return this.isTurkish ? "t.y." : "n.d.";
  }

  get copyTitle() {
    return this.isTurkish ? "Kopyala" : "Copy";
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

  // DOM'daki 'data-time' verisini kullanarak sonsuz döngüyü önleyen güvenli tarih fonksiyonu
  get publicationDate() {
    const createdAt = this.topic?.created_at;
    if (!createdAt) return this.noDateString;
    
    try {
      const date = new Date(createdAt);
      const year = date.getFullYear();
      const day = date.getDate();
      const monthIndex = date.getMonth(); // 0 ile 11 arası ay indeksi
      
      // Sitenizi çökerterek sonsuz döngüye sokan tarayıcı Intl API'sini devreden çıkardık.
      // Bunun yerine doğrudan hatasız bir statik sözlük kullanıyoruz.
      const monthsEn = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      const monthsTr = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];

      const monthName = this.isTurkish ? monthsTr[monthIndex] : monthsEn[monthIndex];

      // APA Formatı: TR için (Yıl, Gün Ay), EN için (Year, Month Day)
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
      <div class="apa-citation-container-v2">
        <div class="apa-citation-wrapper">
          <div class="apa-citation-text">
            <span class="apa-author">{{this.authorApaName}}</span>
            <span class="apa-year">({{this.publicationDate}}).</span>
            <span class="apa-topic-title"><i>{{this.topicTitle}}</i>.</span>
            <span class="apa-site">{{window.location.hostname}}.</span>
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