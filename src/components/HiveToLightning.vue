<template>
  <q-card flat class="text-center q-pa-md">
    <q-img :src="$q.dark.isActive ? 'hivelightning-dark.png' : 'hivelightning-light.png'" style="margin:auto" />
    <div class="text-title text-center">
      Convert <i class="pi pi-hiveio"></i> Hive or HBD to <i class="bolt"></i> Lightning
    </div>
    <q-card v-if="decodedInvoice && serviceStatus" class="shadow-1 q-pa-sm">
      <div class="q-pa-sm">Valid invoice <b>{{ tidyNumber(decodedInvoice.satoshis) }}</b> sats (<b>${{ tidyNumber(costUsd) }}</b>)<br />
      Expires in {{ expiresIn }}</div>
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
    <div class="q-pa-md" style="max-width: 90%; margin:auto">
      <q-input
        v-model="invoice"
        label="Lightning network invoice"
        filled
        autogrow
        class="text-centre"
        @keyup="handleKeyup"
        @paste.prevent="pasteCheckInvoice"
        @keyup.esc="clearInvoice"
        @keyup.enter="checkInvoice"
        :style="invoiceStyles"
      />
    </div>
    <div
      v-if="invoiceError.length"
      class="text-title text-centre invoice-error error">
      {{ invoiceError }}</div>
    <div class="text-title text-center">
      <i class="pi pi-hiveio"></i>
      Using exchange run by <b>@{{ to }}</b>
      <div q-pa-sm v-if="serviceStatus" class="text-caption">Exchange Status:
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
    <q-card v-if="decodedInvoice && serviceStatus" class="shadow-1 q-pa-sm">
      <div class="q-pa-sm">Valid invoice <b>{{ tidyNumber(decodedInvoice.satoshis) }}</b> sats (<b>${{ tidyNumber(costUsd) }}</b>)<br />
      Expires in {{ expiresIn }}</div>
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
</template>

<style scoped>
  a, a:visited, a:hover, a:active {
    color: inherit;
  }
  .body--dark .error {
    background: darkred;
  }
  .body--light .error {
    background: pink;
  }
  .invoice-error {
    border: 1px solid grey;
  }
</style>

<script>
import invoice from 'bolt11'
import { keychain } from '@hiveio/keychain'
export default {
  name: 'HiveToLightning',
  data () {
    return {
      invoice: '',
      decodedInvoice: null,
      expiredMinutes: null,
      invoiceError: '',
      overChargeSats: 1000 * 0.00000001,
      overChargeMultiplier: 1.05, // 15% overcharge, change is returned
      to: 'v4vapp',
      serviceStatus: null
    }
  },
  props: ['prices'],
  directives: {
    autofocus: {
      inserted (el) {
        el.focus()
        console.log('input inserted')
      }
    }
  },
  computed: {
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
    },
    expiresIn: function () {
      const mins = -this.expiredMinutes
      if (mins > 60) {
        return Math.floor(mins / 60) + ' h ' + Math.floor(mins % 60) + ' m'
      }
      return (mins + ' mins')
    },
    invoiceValid: function () {
      if (this.invoice.length === 0) {
        return true
      }
      if (this.invoiceError === '' && this.decodedInvoice) {
        console.log('is the invoice valid? YES')
        return true
      } else {
        console.log('is the invoice valid? NO')
        return false
      }
    },
    invoiceStyles () {
      let ansStyle = ''
      if (this.invoice.length > 0) {
        if (this.invoiceValid) {
          if (this.$q.dark.isActive) {
            ansStyle = {
              background: 'darkgreen'
            }
          } else {
            ansStyle = {
              background: 'lightgreen'
            }
          }
        } else {
          if (this.$q.dark.isActive) {
            ansStyle = {
              background: 'darkred'
            }
          } else {
            ansStyle = {
              background: 'pink'
            }
          }
        }
      } else {
        ansStyle = {
          background: 'none',
          color: 'black'
        }
      }
      return ansStyle
    }
  },
  methods: {
    clearInvoice () {
      this.invoice = ''
      this.invoiceError = ''
      this.decodedInvoice = null
    },
    handleKeyup (e) {
      if (this.invoice.length === 0) {
        this.invoiceError = ''
        this.decodedInvoice = null
      } else {
        this.checkInvoice()
      }
      console.log(e)
    },
    pasteCheckInvoice (evt) {
      console.log(evt.clipboardData.getData('text/plain'))
      this.invoice = evt.clipboardData.getData('text/plain')
      this.checkInvoice()
    },
    checkInvoice () {
      this.invoice = this.invoice.toLowerCase()
      if (this.invoice.startsWith('lightning:')) {
        this.invoice = this.invoice.slice(10)
      }
      if (this.invoice.startsWith('lnbc')) {
        console.log('Checking invoice: ')
        try {
          this.decodedInvoice = invoice.decode(this.invoice)
        } catch (err) {
          console.log(err)
          this.invoiceError = 'Not a valid invoice'
          this.decodedInvoice = null
          return
        }
        if (this.decodedInvoice.payeeNodeKey === '0396693dee59afd67f178af392990d907d3a9679fa7ce00e806b8e373ff6b70bd8') {
          // This is my NODE can't self pay
          this.invoiceError = 'This Invoice points to V4VApp: invalid invoice'
          this.decodedInvoice = null
          return
        }
        console.log(this.decodedInvoice)
        const dddd = Date.now() / 1000
        const expiredSeconds = dddd - this.decodedInvoice.timeExpireDate
        this.expiredMinutes = parseInt(expiredSeconds / 60)

        if (dddd > this.decodedInvoice.timeExpireDate) {
          this.invoiceError = ('This invoice expired  ' + this.expiredMinutes + ' minutes ago')
          // this.$q.notify('This invoice expired  ' + expiredMinutes + ' minutes ago')
          this.decodedInvoice = null
        } else if (this.decodedInvoice.satoshis < this.minimum_invoice_payment_sats) {
          this.invoiceError = ('This invoice too small ' + this.decodedInvoice.satoshis + ' is less than minimum: ' + this.minimum_invoice_payment_sats)
          this.decodedInvoice = null
          // this.$q.notify(this.invoiceError)
        } else if (this.decodedInvoice.satoshis > this.maximum_invoice_payment_sats) {
          this.invoiceError = ('This invoice too large ' + this.decodedInvoice.satoshis + ' is greater than maximum: ' + this.maximum_invoice_payment_sats)
          this.decodedInvoice = null
          // this.$q.notify(this.invoiceError)
        } else {
          this.invoiceError = ''
          console.log('No errors')
        }
      } else {
        this.invoiceError = ('Not a valid Lightning Invoice')
        this.decodedInvoice = null
        // this.$q.notify(this.invoiceError)
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
      this.$hive.api.getAccountsAsync([account])
        .then((response) => {
          this.serviceStatus = JSON.parse(response[0].posting_json_metadata).v4vapp_hiveconfig
          this.conv_fee_sats = parseFloat(this.serviceStatus.conv_fee_sats)
          this.minimum_invoice_payment_sats = parseFloat(this.serviceStatus.minimum_invoice_payment_sats)
          this.maximum_invoice_payment_sats = parseFloat(this.serviceStatus.maximum_invoice_payment_sats)
          this.overChargeSats = this.conv_fee_sats * 0.00000001
        })
        .catch(() => { this.$q.notify('Failed to load service status from Hive account ' + this.account) })
    },
    getHiveLink (authperm) { return 'https://hivel.ink/' + authperm }
  },
  mounted () {
    this.getServiceStatus(this.to)
    if (this.$route.query.invoice) { this.invoice = this.$route.query.invoice; this.checkInvoice() }
  }
}
</script>
