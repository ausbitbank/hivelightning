<template>
  <q-page class="flex flex-center">
    <q-card flat class="text-center q-pa-md">
      <q-img :src="$q.dark.isActive ? 'hivelightning-dark.png' : 'hivelightning-light.png'" style="margin:auto" />
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
        >
          <q-btn icon="photo_camera" dense flat @click="turnCameraOn()" title="Take a photo of a lightning invoice QR code using your camera" v-if="$q.platform.is.mobile"/>
        </q-input>
      </div>
      <q-dialog v-model="camDialog">
        <q-card flat bordered>
          <qrcode-stream  :camera="camera" @decode="onDecode" />
        </q-card>
      </q-dialog>
      <div class="text-title text-center">
        Using exchange run by <b>@{{ to }}</b>
        <div v-if="serviceStatus" class="text-caption">Exchange Status:
          <span v-if="serviceStatus.closed_for_maintenance === false"><q-icon name="circle" color="green" title="Exchange Online" /> Online</span>
          <span v-else-if="serviceStatus.closed_for_maintenance === true"><q-icon name="circle" color="red" title="Exchange Offline for maintenance" /> Offline for maintenance</span>
          <q-btn icon="info" color="blue" flat dense size="sm" title="Show full exchange settings">
            <q-popup-proxy>
              <q-card flat class="text-center q-pa-sm">
                <div class="text-title text-bold">Exchange Settings for {{ to }}</div>
                <div v-for="line in Object.keys(serviceStatus)" :key="line">
                  <span v-if="line === 'dynamic_fees_url'">{{ line}} : <a :href="getHiveLink(serviceStatus[line])" target="_blank">{{ serviceStatus[line] }}</a></span>
                  <span v-else>{{ line}} : {{ serviceStatus[line] }}</span>
                </div>
              </q-card>
            </q-popup-proxy>
          </q-btn>
          <div v-if="serviceStatus && serviceStatus['dynamic_fees_url']"><a :href="getHiveLink(serviceStatus['dynamic_fees_url'])" target="_blank"><q-icon name="open_in_new" /> Fee Details</a></div>
        </div>
      </div>
      <q-card v-if="invoiceValid && decodedInvoice && serviceStatus" class="shadow-1 q-pa-sm">
        Valid invoice for <b>{{ tidyNumber(decodedInvoice.satoshis) }}</b> satoshis (<b>${{ tidyNumber(costUsd) }}</b> USD)<br />
        <q-btn no-caps glossy :disable="serviceStatus.closed_for_maintenance">
          <span v-if="decodedInvoice.satoshis === 1033">0.001 </span><span v-else>{{ tidyNumber(costHive) }}</span> HIVE <q-icon name="img:hive.svg" title="Hive" size="md" class="q-ml-sm" />
          <q-popup-proxy>
            <q-card>
              <q-list dense class="text-bold" v-if="decodedInvoice.satoshis === 1033"> <!-- temporary hivefest giveaway promo -->
                <q-item clickable @click="sendKeychain(0.001,'HIVE')">
                  <q-item-section avatar>
                    <q-icon name="img:hivekeychain.png" title="Pay with Hive Keychain" />
                  </q-item-section>
                  <q-item-section>
                    Hive Keychain
                  </q-item-section>
                </q-item>
                <q-item clickable @click="sendHivesigner(0.001,'HIVE')">
                  <q-item-section avatar>
                    <q-icon name="img:hivesigner.png" title="Pay with Hive Signer" />
                  </q-item-section>
                  <q-item-section>
                    Hive Signer
                  </q-item-section>
                </q-item>
              </q-list>
              <q-list dense class="text-bold" v-else>
                <q-item clickable @click="sendKeychain(costHive,'HIVE')">
                  <q-item-section avatar>
                    <q-icon name="img:hivekeychain.png" title="Pay with Hive Keychain" />
                  </q-item-section>
                  <q-item-section>
                    Hive Keychain
                  </q-item-section>
                </q-item>
                <q-item clickable @click="sendHivesigner(costHive,'HIVE')">
                  <q-item-section avatar>
                    <q-icon name="img:hivesigner.png" title="Pay with Hive Signer" />
                  </q-item-section>
                  <q-item-section>
                    Hive Signer
                  </q-item-section>
                </q-item>
              </q-list>
            </q-card>
          </q-popup-proxy>
        </q-btn>
        <q-btn no-caps glossy :disable="serviceStatus.closed_for_maintenance">
          {{ tidyNumber(costHbd) }} HBD <q-icon name="img:hbd.svg" title="Hive Dollars" size="md" class="q-ml-sm" />
          <q-popup-proxy>
            <q-card>
              <q-list dense class="text-bold">
                <q-item clickable @click="sendKeychain(costHbd,'HBD')">
                  <q-item-section avatar>
                    <q-icon name="img:hivekeychain.png" title="Pay with Hive Keychain" />
                  </q-item-section>
                  <q-item-section>
                    Hive Keychain
                  </q-item-section>
                </q-item>
                <q-item clickable @click="sendHivesigner(costHbd,'HBD')">
                  <q-item-section avatar>
                    <q-icon name="img:hivesigner.png" title="Pay with Hive Signer" />
                  </q-item-section>
                  <q-item-section>
                    Hive Signer
                  </q-item-section>
                </q-item>
              </q-list>
            </q-card>
          </q-popup-proxy>
        </q-btn>
      </q-card>
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
import { QrcodeStream } from 'vue-qrcode-reader'
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
      serviceStatus: null,
      camera: 'auto',
      camDialog: false
    }
  },
  components: { QrcodeStream },
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
    async onDecode (content) {
      this.invoice = content.toLowerCase()
      this.turnCameraOff()
      this.checkInvoice()
    },
    turnCameraOn () { this.camera = 'auto'; this.camDialog = true },
    turnCameraOff () { this.camera = 'off'; this.camDialog = false },
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
