<template>
  <v-row>
    <v-col cols="12">
      <AccountTable
        :items="data"
        :pageOptions.sync="pageOptions"
        :loading="loading"
        @pageOptionsChange="onPageOptionsChange"
        @refresh="onRefresh"
      >
      </AccountTable>
    </v-col>
    <v-col cols="12"> LineChart </v-col>
  </v-row>
</template>

<script lang="ts">
import AccountTable from "@/components/dataTables/AccountTable.vue";
import { Component, Vue } from "vue-property-decorator";
import { IAccountDto } from "@/apis/apiModels";
import { IPageOptions } from "@/models/page";

@Component({ components: { AccountTable } })
export default class HomeView extends Vue {
  data: IAccountDto[] = [];

  pageOptions: IPageOptions = {
    page: 1,
    itemsPerPage: 10,
    sortBy: [],
    sortDesc: [],
    groupBy: [],
    groupDesc: [],
    multiSort: false,
    mustSort: false,
    totalPages: 0,
    totalItems: 0,
  };

  loading = false;

  async created() {
    await this.loadPage();
  }

  async loadPage() {
    try {
      this.loading = true;
      const response = await this.$api.account(
        this.pageOptions.page,
        this.pageOptions.itemsPerPage
      );
      this.pageOptions.totalItems = response.data?.totalItems || 1;
      this.pageOptions.totalPages = response.data?.totalPages || 1;
      this.data = response.data?.items || [];
    } finally {
      this.loading = false;
    }
  }

  async onPageOptionsChange() {
    await this.loadPage();
  }

  async onRefresh() {
    await this.loadPage();
  }
}
</script>
