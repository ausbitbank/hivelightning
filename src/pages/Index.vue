<template>
  <q-page class="flex flex-center">
    <q-card flat class="text-center">
      <div class="text-title text-center">
        Pay a lightning network invoice with Hive or HBD
      </div>

      <div class="q-pa-md" style="max-width: 90%; margin:auto">
        <q-input
          v-model="invoice"
          label="Lightning network invoice"
          filled
          autogrow
          class="text-center" @enter="checkInvoice()" @change="checkInvoice()"
        />
      </div>
      <q-card v-if="invoiceValid && decodedInvoice" class="shadow-1 q-pa-sm">
        Valid invoice for <b>{{ decodedInvoice.satoshis }}</b> satoshis (<b>${{ costUsd }}</b> USD)<br />
        <q-btn no-caps lossy @click="sendKeychain(costHive,'HIVE')">{{ costHive }} HIVE <q-icon name="img:hive.svg" title="Hive" size="md" class="q-ml-sm" /></q-btn>
        <q-btn no-caps glossy @click="sendKeychain(costHbd,'HBD')">{{ costHbd }} HBD <q-icon name="img:hbd.svg" title="Hive Dollars" size="md" class="q-ml-sm" /></q-btn>
      </q-card>
    </q-card>
    <q-footer v-if="prices" class="text-center">
      <b>Bitcoin:</b> ${{ tidyNumber(prices.bitcoin.usd) }}
      <b>Hive:</b> ${{ prices.hive.usd }}
      <b>Hive Dollars:</b> ${{ prices.hive_dollar.usd }}
    </q-footer>
  </q-page>
</template>

<script>
import invoice from 'bolt11'
import { keychain } from '@hiveio/keychain'
export default {
  name: 'PageIndex',
  data () {
    return {
      invoice: '',
      decodedInvoice: null,
      prices: null,
      overChargeSats: 50 * 0.00000001,
      overChargeMultiplier: 1.15 // 15% overcharge, change is returned
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
        return (cost).toFixed(3)
      } else { return null }
    },
    costHbd: function () {
      if (this.prices && this.decodedInvoice) {
        const hbdBtc = this.prices.hive_dollar.btc
        const sats = this.decodedInvoice.satoshis * 0.00000001
        const cost = ((sats + this.overChargeSats) / hbdBtc) * this.overChargeMultiplier
        return (cost).toFixed(3)
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
        .then((response) => { this.prices = response.data })
        .catch(() => { console.log('Failed to load data from coingecko api') })
    },
    checkInvoice () {
      if (this.invoice.startsWith('lightning:')) { this.invoice = this.invoice.slice(10) }
      if (this.invoiceValid) {
        console.info(invoice.decode(this.invoice))
        this.decodedInvoice = invoice.decode(this.invoice)
      } else {
        this.decodedInvoice = null
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
      const to = 'hivehydra'
      const user = ''
      const { success, msg, cancel, notInstalled, notActive } = await keychain(window, 'requestTransfer', user, to, amount, this.invoice, token)
      if (success) { this.$q.notify('Payment sent!') }
      if (cancel) { this.$q.notify('Cancelled by user') }
      if (!cancel) { if (notActive) { this.$q.notify('Please allow keychain to access this website') } else if (notInstalled) { this.$q.notify('Keychain not available') } else { console.info(msg) } }
    }
  },
  mounted () {
    this.getPrices()
  }
}
</script>
