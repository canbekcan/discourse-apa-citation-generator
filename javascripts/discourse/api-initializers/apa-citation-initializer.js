import { withPluginApi } from "discourse/lib/plugin-api";
import ApaCitationBox from "../components/apa-citation-box";

export default {
  name: "apa-citation-generator",
  initialize() {
    withPluginApi("1.15.0", (api) => {
      // Ziyaretçilerin içerik başlığının hemen altında atıf bilgilerini görmesi için:
      api.renderInOutlet("topic-above-posts", ApaCitationBox);
    });
  }
};