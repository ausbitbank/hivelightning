<template>
  <q-page class="flex flex-center">
    <q-card>
      <q-tabs
      v-model="tab"
      class="q-my-md shadow-2"
      inline-label>
        <q-tab name="H2L" icon="bolt" label="Get Lightning" />
        <q-tab name="L2H" icon="bolt" label="Get Hive" />
        <q-tab name="Instructions" icon="info" label="Information" />
      </q-tabs>
      <q-tab-panels v-model="tab" animated>
        <q-tab-panel name="H2L">
          <hivelight
            :prices="prices"></hivelight>
        </q-tab-panel>
        <q-tab-panel name="L2H">
          <lighthive>passing</lighthive>
          <h4>Lightning to Hive</h4>
          <div class="tallypay" data-user="v4vapp"></div>
        </q-tab-panel>
      </q-tab-panels>
    </q-card>
    <q-card>
      <lighthive>passing</lighthive>
    </q-card>
    <q-footer v-if="prices" class="text-center">
      <b>Bitcoin:</b> ${{ tidyNumber(prices.bitcoin.usd.toFixed(2)) }}
      <b>Hive:</b> ${{ prices.hive.usd.toFixed(2) }}
      <b>Hive Dollars:</b> ${{ prices.hive_dollar.usd.toFixed(2) }}
      <q-btn flat dense @click="$q.dark.toggle()" :color="$q.dark.isActive ? 'black' : 'white'" :title="$q.dark.isActive ? 'Change to light mode':'Change to dark mode'" :icon="$q.dark.isActive ? 'dark_mode':'light_mode'" size="sm" />
    </q-footer>
  </q-page>
</template>

<style scoped>
</style>

<script>
import HiveToLightningVue from 'src/components/HiveToLightning.vue'
import LightningToHiveVue from 'src/components/LightningToHive.vue'

export default {
  name: 'PageIndex',
  data () {
    return {
      tab: 'H2L',
      prices: null
    }
  },
  computed: {
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
    this.getPrices()
  }
}
</script>
