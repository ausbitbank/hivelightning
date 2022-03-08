<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <router-view v-bind:prices="prices" />
      <q-tabs
        v-model="tab"
        dense
        class="text-grey"
        active-color="primary"
        indicator-color="primary"
        align="justify"
        narrow-indicator
      >
        <q-tab name="h2l" icon="bolt" label="Get Lightning" />
        <q-tab name="l2h" icon="bolt" label="Get Hive" />
        <q-tab name="info" icon="info" label="Info" />
      </q-tabs>
      <q-separator />
      <q-tab-panels v-model="tab" animated>
        <q-tab-panel name="h2l">
          <hivelight
            v-bind:prices="prices"></hivelight>
        </q-tab-panel>
        <q-tab-panel name="l2h">
          <lighthive
          v-bind:prices="prices"></lighthive>
        </q-tab-panel>

        <q-tab-panel name="info">
          <div class="text-h6">Info</div>
          Information about the service will go here.
        </q-tab-panel>
      </q-tab-panels>

    </q-page-container>
    <q-footer v-if="prices" class="text-center">
      <b>Bitcoin:</b> ${{ tidyNumber(prices.bitcoin.usd.toFixed(2)) }}
      <b>Hive:</b> ${{ prices.hive.usd.toFixed(2) }}
      <b>Hive Dollars:</b> ${{ prices.hive_dollar.usd.toFixed(2) }}
      <q-btn flat dense @click="$q.dark.toggle()" :color="$q.dark.isActive ? 'black' : 'white'" :title="$q.dark.isActive ? 'Change to light mode':'Change to dark mode'" :icon="$q.dark.isActive ? 'dark_mode':'light_mode'" size="sm" />
    </q-footer>
  </q-layout>
</template>

<script>
import HiveToLightningVue from 'src/components/HiveToLightning.vue'
import LightningToHiveVue from 'src/components/LightningToHive.vue'

export default {
  name: 'MainLayout',
  data () {
    return {
      prices: null,
      tab: 'l2h'
    }
  },
  methods: {
    getPrices () {
      this.prices = null
      this.$axios.get('https://api.coingecko.com/api/v3/simple/price?ids=hive%2Chive_dollar,bitcoin&vs_currencies=btc,usd&include_market_cap=false&include_24hr_vol=false&include_24hr_change=false&include_last_updated_at=false')
        .then((response) => {
          this.prices = response.data
          if (this.prices.hive_dollar.usd > 1.10) {
            this.prices.hive_dollar.usd = 1.10
          }
        })
        .catch(() => { console.log('Failed to load data from coingecko api') })
    },
    tidyNumber (x) {
      if (x) {
        const parts = x.toString().split('.')
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
        return parts.join('.')
      } else {
        return null
      }
    }
  },
  components: {
    hivelight: HiveToLightningVue,
    lighthive: LightningToHiveVue
  },
  mounted () {
    this.$q.dark.set('auto')
    this.getPrices()
  }

}
</script>
