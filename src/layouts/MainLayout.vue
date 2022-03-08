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
      sendHiveTo: '',
      serviceStatus: null,
      apiURLs: ['']
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
          console.log('Prices fetched from coingecko')
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
    validateApiUrl () {
      // let success = ''
      console.log(this.apiURLs)
      this.apiURLs.forEach((url) => {
        console.log('Checking: ' + url)
        this.$axios({
          method: 'GET',
          url: url + '/v1'
        }).then((response) => {
          this.serviceStatus.apiUrl = url
          console.log('response: ' + response)
          console.log('final api: ' + this.serviceStatus.apiUrl)
        }).catch((err) => {
          console.log('Failure: ' + url)
          console.log(err)
        })
      })
    },
    getServiceStatus (account) {
      this.$hive.api.getAccountsAsync([account])
        .then((response) => {
          this.serviceStatus = JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig
          this.serviceStatus.conv_fee_sats = parseFloat(this.serviceStatus.conv_fee_sats)
          this.serviceStatus.minimum_invoice_payment_sats = parseFloat(this.serviceStatus.minimum_invoice_payment_sats)
          this.serviceStatus.maximum_invoice_payment_sats = parseFloat(this.serviceStatus.maximum_invoice_payment_sats)
          this.serviceStatus.overChargeSats = this.serviceStatus.conv_fee_sats * 0.00000001
          this.serviceStatus.conv_fee_percent = parseFloat(this.serviceStatus.conv_fee_percent)
          console.log(this.serviceStatus)
          console.log(this.serviceStatus.v4v_api_iri)
          if (this.serviceStatus.v4v_api_iri) {
            console.log(this.apiURLs)
            this.apiURLs.unshift(this.serviceStatus.v4v_api_iri)
            console.log('URL list: ' + this.apiURLs)
          }
          this.validateApiUrl()
          console.log(this.serviceStatus)
        }).catch(() => { this.$q.notify('Failed to load service status from Hive account ' + account) })
    },
    setSendHiveTo () {
      console.log('Write function to set the right sendTo address')
      this.sendHiveTo = 'v4vapp'
    }
  },
  components: {
    // hivelight: HiveToLightningVue,
    // lighthive: LightningToHiveVue
  },
  beforeMount () {
    this.setSendHiveTo()
    this.getPrices()
    this.getServiceStatus(this.sendHiveTo)
  },
  mounted () {
    this.$q.dark.set('auto')
  }

}
</script>
