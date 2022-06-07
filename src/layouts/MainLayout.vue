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
            label="Lightning" />
          <q-route-tab name="gethive" icon="pi-hiveio" to= "/hive" label="Hive" />
          <q-route-tab name="getaddress" icon="qr_code_2" to= "/address" label="Address" />
          <q-route-tab name="info" icon="info" to="/info" label="Info" />
          <q-tab v-if="devSite" name="DEVELOPMENT" label="DEVELOPMENT ONLY DO NOT USE"></q-tab>
        </q-tabs>
      </q-toolbar>
      <div v-if="devSite" align="center" class="text-h6"><a href="https://lnd.v4v.app/hive">USE: lnd.v4v.app INSTEAD</a></div>
    </q-header>
    <q-footer v-if="prices" class="text-center">
      <b>Bitcoin:</b> ${{ tidyNumber(prices.bitcoin.usd.toFixed(2)) }}
      <b>Hive:</b> ${{ prices.hive.usd.toFixed(2) }}
      <b>Hive Dollars:</b> ${{ prices.hive_dollar.usd.toFixed(2) }}
      <q-btn flat dense @click="$q.dark.toggle()" :color="$q.dark.isActive ? 'black' : 'white'" :title="$q.dark.isActive ? 'Change to light mode':'Change to dark mode'" :icon="$q.dark.isActive ? 'dark_mode':'light_mode'" size="sm" />
      <p>
        Larger swaps via Changely <a href="https://hive.ausbit.dev/exchange?from=hive&to=btc" target="_blank">Hive to BTC</a>
        or <a href="https://hive.ausbit.dev/exchange?from=btc&to=hive" target="_blank">BTC to Hive</a>.</p>
    </q-footer>
    <q-page-container>
      <router-view
        v-bind:prices="prices"
        :serviceStatus="serviceStatus"
        :sendHiveTo="sendHiveTo"
      />
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
      apiURLs: [],
      devSite: false
    }
  },
  methods: {
    async getPrices () {
      this.prices = null
      this.$axios.get('https://api.coingecko.com/api/v3/simple/price?ids=hive%2Chive_dollar,bitcoin&vs_currencies=btc,usd')
        .then((response) => {
          this.prices = response.data
          if (this.prices.hive_dollar.usd > 1.10) {
            this.prices.hive_dollar.usd = 1.10
          }
        })
        .catch(() => { console.error('Failed to load data from coingecko api') })
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
      this.apiURLs.forEach((url) => {
        console.log('testing ', url)
        this.$axios({
          method: 'GET',
          url: url + '/v1'
        }).then((response) => {
          this.serviceStatus.apiUrl = url
          console.log('Using: ' + this.serviceStatus.apiUrl)
        }).catch((err) => {
          console.log('Failure: ' + url)
          console.log(err)
        })
      })
    },
    async getServiceStatus (account) {
      this.$hive.api.getAccountsAsync([account])
        .then((response) => {
          this.serviceStatus = JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig
          this.serviceStatus.conv_fee_sats = parseFloat(this.serviceStatus.conv_fee_sats)
          this.serviceStatus.minimum_invoice_payment_sats = parseFloat(this.serviceStatus.minimum_invoice_payment_sats)
          this.serviceStatus.maximum_invoice_payment_sats = parseFloat(this.serviceStatus.maximum_invoice_payment_sats)
          this.serviceStatus.overChargeSats = this.serviceStatus.conv_fee_sats * 0.00000001
          this.serviceStatus.conv_fee_percent = parseFloat(this.serviceStatus.conv_fee_percent)
          if (this.serviceStatus.v4v_api_iri) {
            this.apiURLs.unshift(this.serviceStatus.v4v_api_iri)
          }
          this.validateApiUrl()
        }).catch(() => { this.$q.notify('Failed to load service status from Hive account ' + account) })
    },
    setSendHiveTo () {
      // Send To Hive is the Account to which this instance is linked.
      if (window.location.hostname === 'localhost' || window.location.hostname.includes('dev.')) {
        this.sendHiveTo = 'hivehydra'
        this.devSite = true
      } else {
        this.sendHiveTo = 'v4vapp'
      }
      console.log('Master account: ' + this.sendHiveTo)
    }
  },
  components: {
    // hivelight: HiveToLightningVue,
    // lighthive: LightningToHiveVue
  },
  beforeCreate () {
  },
  beforeMount () {
    this.setSendHiveTo()
    this.getPrices()
    this.getServiceStatus(this.sendHiveTo)
  },
  mounted () {
    this.$q.dark.set('auto')
    console.log(window.location)
  }

}
</script>
