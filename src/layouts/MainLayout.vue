<template>
  <q-layout view="lHh Lpr lFf">
    <q-header bordered>
      <q-toolbar>
        <q-img :src="$q.dark.isActive ? 'hivelightning-dark.png' : 'hivelightning-light.png'"
          style="max-height: 50px; max-width: 100px" />
        <q-tabs
          dense
          active-bg-color="amber-10"
          align="justify"
          narrow-indicator
        >
          <q-route-tab
            name="getlightning"
            icon="bolt"
            to="/lnd"
            label="Get Lightning" />
          <q-route-tab name="gethive" icon="bolt" to= "/hive" label="Get Hive" />
          <q-route-tab name="info" icon="info" to="/info" label="Info" />
        </q-tabs>
      </q-toolbar>
    </q-header>
    <q-footer v-if="prices" class="text-center">
      <b>Bitcoin:</b> ${{ tidyNumber(prices.bitcoin.usd.toFixed(2)) }}
      <b>Hive:</b> ${{ prices.hive.usd.toFixed(2) }}
      <b>Hive Dollars:</b> ${{ prices.hive_dollar.usd.toFixed(2) }}
      <q-btn flat dense @click="$q.dark.toggle()" :color="$q.dark.isActive ? 'black' : 'white'" :title="$q.dark.isActive ? 'Change to light mode':'Change to dark mode'" :icon="$q.dark.isActive ? 'dark_mode':'light_mode'" size="sm" />
    </q-footer>
    <q-page-container>
      <router-view
        v-bind:prices="prices"
        :serviceStatus="serviceStatus"
        :sendHiveTo="sendHiveTo" />
    </q-page-container>
  </q-layout>
</template>

<script>
// import HiveToLightningVue from 'src/components/HiveToLightning.vue'
// import LightningToHiveVue from 'src/components/LightningToHive.vue'

export default {
  name: 'MainLayout',
  data () {
    return {
      prices: null,
      sendHiveTo: 'v4vapp',
      serviceStatus: null
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
    },
    getServiceStatus (account) {
      console.log('getting service status for ', account)
      this.$hive.api.getAccountsAsync([account])
        .then((response) => {
          this.serviceStatus = JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig
          this.conv_fee_sats = parseFloat(this.serviceStatus.conv_fee_sats)
          this.minimum_invoice_payment_sats = parseFloat(this.serviceStatus.minimum_invoice_payment_sats)
          this.maximum_invoice_payment_sats = parseFloat(this.serviceStatus.maximum_invoice_payment_sats)
          this.overChargeSats = this.conv_fee_sats * 0.00000001
        })
        .catch(() => { this.$q.notify('Failed to load service status from Hive account ' + this.account) })
    }
  },
  components: {
    // hivelight: HiveToLightningVue,
    // lighthive: LightningToHiveVue
  },
  mounted () {
    this.$q.dark.set('auto')
    this.getPrices()
    this.getServiceStatus(this.sendHiveTo)
  }

}
</script>
