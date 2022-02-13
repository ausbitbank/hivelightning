<template>
  <q-page class="flex flex-center">
    <q-card flat class="text-center p-pa-md">
      <div class="tallypay" data-user="v4vapp"></div>
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
a, a:visited, a:hover, a:active {
  color: inherit;
}
</style>
<script>
import invoice from 'bolt11'
import { keychain } from '@hiveio/keychain'
import hive from '@hiveio/hive-js'
export default {
  name: 'PageIndex',
  data () {
    return {
      invoice: '',
      decodedInvoice: null,
      prices: null,
      overChargeSats: 1000 * 0.00000001,
      overChargeMultiplier: 1.05, // 15% overcharge, change is returned
      to: 'v4vapp',
      serviceStatus: null
    }
  },
  computed: {
    invoiceValid: function () {
      if (this.invoice.startsWith('lnbc')) {
        return true
      } else {
        return false
      }
    },
    costHive: function () {
      if (this.prices && this.decodedInvoice) {
        const hiveBtc = this.prices.hive.btc
        const sats = this.decodedInvoice.satoshis * 0.00000001
        const cost = ((sats + this.overChargeSats) / hiveBtc) * this.overChargeMultiplier
        return (cost).toFixed(1)
      } else { return null }
    },
    costHbd: function () {
      if (this.prices && this.decodedInvoice) {
        const hbdUsd = this.prices.hive_dollar.usd
        const sats = this.decodedInvoice.satoshis * 0.00000001
        const cost = (((sats + this.overChargeSats) * this.prices.bitcoin.usd) / hbdUsd) * this.overChargeMultiplier
        return (cost).toFixed(1)
      } else { return null }
    },
    costUsd: function () {
      if (this.prices && this.decodedInvoice) {
        const sats = this.decodedInvoice.satoshis * 0.00000001
        return (sats * this.prices.bitcoin.usd).toFixed(2)
      } else { return null }
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
    checkInvoice () {
      if (this.invoice.startsWith('lightning:')) { this.invoice = this.invoice.slice(10) }
      if (this.invoiceValid) {
        console.info(invoice.decode(this.invoice))
        this.decodedInvoice = invoice.decode(this.invoice)
        const dddd = Date.now() / 1000
        const expiredSeconds = dddd - this.decodedInvoice.timeExpireDate
        const expiredMinutes = parseInt(expiredSeconds % 3600)
        if (dddd > this.decodedInvoice.timeExpireDate) {
          this.$q.notify('This invoice expired  ' + expiredMinutes + ' minutes ago')
          this.decodedInvoice = null
        }
        if (this.decodedInvoice.satoshis < this.minimum_invoice_payment_sats) {
          const mess = ('This invoice too small ' + this.decodedInvoice.satoshis + ' is less than minimum: ' + this.minimum_invoice_payment_sats)
          this.decodedInvoice = null
          this.$q.notify(mess)
        } else if (this.decodedInvoice.satoshis > this.maximum_invoice_payment_sats) {
          const mess = ('This invoice too large ' + this.decodedInvoice.satoshis + ' is greater than maximum: ' + this.maximum_invoice_payment_sats)
          this.decodedInvoice = null
          this.$q.notify(mess)
        }
      } else {
        this.decodedInvoice = null
        this.$q.notify('Not a valid Lightning Invoice')
      }
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
    async sendKeychain (amount, token) {
      const user = ''
      const { success, msg, cancel, notInstalled, notActive } = await keychain(window, 'requestTransfer', user, this.to, parseFloat(amount).toFixed(3), this.invoice + ' lnd.v4v.app', token)
      if (success) { this.$q.notify('Payment sent!'); this.invoice = '' }
      if (cancel) { this.$q.notify('Cancelled by user') }
      if (!cancel) { if (notActive) { this.$q.notify('Please allow keychain to access this website') } else if (notInstalled) { this.$q.notify('Keychain not available') } else { console.info(msg) } }
    },
    sendHivesigner (amount, token) {
      const dest = 'https://hivesigner.com/sign/transfer?to=' + this.to + '&from=&amount=' + amount + '%20' + token + '&memo=' + this.invoice + '%20lnd.v4v.app'
      window.open(dest, '_blank')
      this.invoice = ''
    },
    getServiceStatus (account) {
      hive.api.getAccountsAsync([account])
        .then((response) => {
          this.serviceStatus = JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig
          this.conv_fee_sats = parseFloat(JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig.conv_fee_sats)
          this.minimum_invoice_payment_sats = parseFloat(JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig.minimum_invoice_payment_sats)
          this.maximum_invoice_payment_sats = parseFloat(JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig.maximum_invoice_payment_sats)
          this.overChargeSats = this.conv_fee_sats * 0.00000001
        })
        .catch(() => { this.$q.notify('Failed to load service status from Hive account ' + this.account) })
    },
    getHiveLink (authperm) { return 'https://hivel.ink/' + authperm }
  },
  mounted () {
    this.getServiceStatus(this.to)
    this.$q.dark.set('auto')
    this.getPrices()
    if (this.$route.query.invoice) { this.invoice = this.$route.query.invoice; this.checkInvoice() }
  }
}
</script>
