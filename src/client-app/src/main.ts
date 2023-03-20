import Vue from "vue";
import $api from "./apis/apiClient";
import App from "./App.vue";
import vuetify from "./plugins/vuetify";
import router from "./router";
import store from "./store";

Vue.config.productionTip = false;
Vue.prototype.$api = $api

new Vue({
    router,
    store,
    vuetify,
    render: (h) => h(App),
}).$mount("#app");
