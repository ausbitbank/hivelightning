<template>
  <q-card flat class="text-center q-pa-md">
    <div class="text-h6 q-pb-lg">Hive to Lightning</div>
    <div class="text-title text-center">
      Convert <i class="pi pi-hiveio" style="font-size: 1.3em"></i> Hive or HBD to <q-icon style="font-size: 1.3em" name="bolt" /> Lightning
    </div>
    <q-card v-if="decodedInvoice && serviceStatus" class="shadow-1 q-pa-sm">
      <div class="q-pa-sm">Valid invoice <b>{{ tidyNumber(decodedInvoice.satoshis) }}</b> sats (<b>${{ tidyNumber(costUsd) }}</b>)<br />
      Expires in {{ expiresIn }}</div>
      <q-btn no-caps glossy :disable="serviceStatus.closed_get_lnd">
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
      <q-btn no-caps glossy :disable="serviceStatus.closed_get_lnd">
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
    <!-- Lightning invoice Text Box -->
    <div class="q-pa-md" style="max-width: 90%; margin:auto">
      <div class="q-pa-sm" v-if="this.lnurlMessage">
        {{ this.lnurlMessage }}
      </div>
      <div class="q-pa-sm" v-if="this.lnurlImage">
        <img :src=this.lnurlImage />
      </div>
      <q-input
        v-model="invoice"
        label="Lightning invoice"
        filled
        class="text-centre"
        debounce="1000"
        @keyup="handleKeyup"
        @paste.prevent="pasteCheckInvoice"
        @keyup.esc="clearInvoice"
        @keyup.enter="checkInvoice"
        :style="invoiceStyles"
        >
          <q-btn
            icon-right="photo_camera"
            class="vertical-middle"
            dense
            flat
            @click="turnCameraOn()"
            title="Take a photo of a lightning invoice QR code using your camera" />
            <!-- v-if="$q.platform.is.mobile" /> -->
      </q-input>
    </div>
    <q-dialog v-model="camDialog">
      <q-card flat bordered>
        <qrcodestream
          :camera="camera"
          @decode="onDecode" />
      </q-card>
    </q-dialog>
    <!-- End of Lightning invoice Text Box -->
    <div
      v-if="invoiceError.length"
      class="text-title text-centre invoice-error error">
      {{ invoiceError }}</div>
    <!-- SwapStatusVue component -->
    <swapstatus v-if="serviceStatus"
      :sendHiveTo="sendHiveTo"
      :serviceStatus="serviceStatus"
      :swapStatus="serviceStatus.closed_get_lnd"
    ></swapstatus>
    <q-card v-if="decodedInvoice && serviceStatus" class="shadow-1 q-pa-sm">
      <div class="q-pa-sm">Valid invoice <b>{{ tidyNumber(decodedInvoice.satoshis) }}</b> sats (<b>${{ tidyNumber(costUsd) }}</b>)<br />
      Expires in {{ expiresIn }}</div>
      <q-btn no-caps glossy :disable="serviceStatus.closed_get_lnd">
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
      <q-btn no-caps glossy :disable="serviceStatus.closed_get_lnd">
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
import SwapStatusVue from 'src/components/SwapStatus.vue'
import { QrcodeStream } from 'vue-qrcode-reader'
// import { bech32 } from 'bech32'

export default {
  name: 'GetLightning',
  components: {
    swapstatus: SwapStatusVue,
    qrcodestream: QrcodeStream
  },
  data () {
    return {
      invoice: '',
      decodedInvoice: null,
      expiredMinutes: null,
      invoiceError: '',
      overChargeMultiplier: 1.10, // 10% overcharge, change is returned
      camera: 'auto',
      camDialog: false,
      // lAddPattern: /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
      lAddPattern: /\S+@\S+/,
      lnurlMessage: null,
      lnurlImage: null
    }
  },
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
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
        const cost = (0.1 + (sats + this.serviceStatus.overChargeSats) / hiveBtc) * this.overChargeMultiplier
        return (cost).toFixed(1)
      } else { return null }
    },
    costHbd: function () {
      if (this.prices && this.decodedInvoice) {
        const hbdUsd = this.prices.hive_dollar.usd
        const sats = this.decodedInvoice.satoshis * 0.00000001
        const cost = (0.1 + ((sats + this.serviceStatus.overChargeSats) * this.prices.bitcoin.usd) / hbdUsd) * this.overChargeMultiplier
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
    onDecode (content) {
      this.invoice = content.toLowerCase()
      this.turnCameraOff()
      this.checkInvoice()
    },
    turnCameraOn () { this.camera = 'auto'; this.camDialog = true },
    turnCameraOff () { this.camera = 'off'; this.camDialog = false },
    clearInvoice (errorMessage) {
      this.invoice = ''
      if (errorMessage) {
        this.invoiceError = errorMessage
      } else {
        this.invoiceError = ''
      }
      this.decodedInvoice = null
      this.lnurlImage = null
      this.lnurlMessage = null
    },
    handleKeyup (e) {
      if (this.invoice.length === 0) {
        this.clearInvoice()
      } else {
        console.log('key up')
      }
    },
    pasteCheckInvoice (evt) {
      this.invoice = evt.clipboardData.getData('text/plain')
      this.checkInvoice()
    },
    checkInvoice () {
      this.invoice = this.invoice.toLowerCase()
      if (this.invoice.startsWith('lightning:')) {
        this.invoice = this.invoice.slice(10)
      }
      if (this.invoice.startsWith('lnurl')) {
        console.log(`LNURL invoice: ${this.invoice}`)
        this.decodeLnUrlPay().then(
          console.log('Working on decoding LNURL'))
        return
      }
      if (this.invoice.startsWith('lnbc')) {
        console.log('Checking invoice: ')
        try {
          this.decodedInvoice = invoice.decode(this.invoice)
        } catch (err) {
          console.log(err)
          this.clearInvoice('Not a valid invoice')
          return
        }
        if (this.decodedInvoice.payeeNodeKey === '0266ad2656c7a19a219d37e82b280046660f4d7f3ae0c00b64a1629de4ea567668') {
          // This is my NODE can't self pay
          this.invoiceError = 'This Invoice points to V4VApp: invalid invoice'
          this.decodedInvoice = null
          return
        }
        const dddd = Date.now() / 1000
        const expiredSeconds = dddd - this.decodedInvoice.timeExpireDate
        this.expiredMinutes = parseInt(expiredSeconds / 60)
        if (dddd > this.decodedInvoice.timeExpireDate) {
          this.invoiceError = ('This invoice expired  ' + this.expiredMinutes + ' minutes ago')
          // this.$q.notify('This invoice expired  ' + expiredMinutes + ' minutes ago')
          this.decodedInvoice = null
        } else if (this.decodedInvoice.satoshis === null) {
          this.invoiceError = ('This invoice has no value, we can not handle this yet')
          this.decodedInvoice = null
          // this.$q.notify(this.invoiceError)
        } else if (this.decodedInvoice.satoshis < this.serviceStatus.minimum_invoice_payment_sats) {
          this.invoiceError = ('This invoice too small ' + this.decodedInvoice.satoshis + ' is less than minimum: ' + this.serviceStatus.minimum_invoice_payment_sats)
          this.decodedInvoice = null
          // this.$q.notify(this.invoiceError)
        } else if (this.decodedInvoice.satoshis > this.serviceStatus.maximum_invoice_payment_sats) {
          this.invoiceError = ('This invoice too large ' + this.decodedInvoice.satoshis + ' is greater than maximum: ' + this.serviceStatus.maximum_invoice_payment_sats)
          this.decodedInvoice = null
          // this.$q.notify(this.invoiceError)
        } else {
          this.invoiceError = ''
          console.log('No LND Invoice errors')
        }
        return
      }
      console.log('Testing for lightning address')
      if (this.lAddPattern.test(this.invoice)) {
        console.log(`LNURL Lightning Address: ${this.invoice}`)
        this.decodeLnUrlPay().then(
          console.log('Working on decoding LNURL')
        )
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
      console.log(amount, token)
      const user = null
      const { success, msg, cancel, notInstalled, notActive } = await keychain(window, 'requestTransfer', user, this.sendHiveTo, parseFloat(amount).toFixed(3), this.invoice + ' lnd.v4v.app', token)
      if (success) {
        this.$q.notify('Payment sent!')
        this.clearInvoice()
      }
      if (cancel) { this.$q.notify('Cancelled by user') }
      if (!cancel) { if (notActive) { this.$q.notify('Please allow keychain to access this website') } else if (notInstalled) { this.$q.notify('Keychain not available') } else { console.info(msg) } }
    },
    sendHivesigner (amount, token) {
      const dest = 'https://hivesigner.com/sign/transfer?to=' + this.sendHiveTo + '&from=&amount=' + amount + '%20' + token + '&memo=' + this.invoice + '%20lnd.v4v.app'
      window.open(dest, '_blank')
      this.invoice = ''
    },
    setValidInvoice () {
      this.invoiceError = ''
      this.decodedInvoice = 'Sending sats to Lightning Address'
    },
    async decodeLnUrlPay () {
      console.log(this.invoice)
      this.lnurlImage = null
      const apiUrl = this.serviceStatus.apiUrl
      let url = apiUrl + '/v1/lnurlp/proxy/'
      console.log('url is ' + url)
      try {
        const result = await this.$axios.post(url, { anything: this.invoice })
        this.setValidInvoice()
        const amount = await this.queryAmount(result.data.metadata, result.data.minSendable, result.data.maxSendable)
        let comment = ''
        if (result.data.commentAllowed) {
          comment = await this.queryComment(result.data.commentAllowed)
        }
        const callbackUrl = await this.addAmountComment(result.data.callback, amount, comment)
        console.log(callbackUrl)
        url = apiUrl + '/v1/lnurlp/proxy/callback/'
        const callBackResult = await this.$axios.get(url, { params: { callbackUrl: callbackUrl } })
        this.invoice = callBackResult.data.pr
        this.decodedInvoice = invoice.decode(this.invoice)
        this.invoiceError = ''
        if (this.decodedInvoice.payeeNodeKey === '0266ad2656c7a19a219d37e82b280046660f4d7f3ae0c00b64a1629de4ea567668') {
          // This is my NODE can't self pay
          this.clearInvoice('This Invoice points back to V4VApp: invalid invoice')
          return
        }
      } catch (err) {
        console.log(err)
        this.clearInvoice('Unable to decode LNURL or Sending cancelled')
      }
    },
    async queryAmount (metadata, minSendable, maxSendable) {
      minSendable = minSendable / 1000
      maxSendable = maxSendable / 1000
      if (minSendable < this.serviceStatus.minimum_invoice_payment_sats) {
        minSendable = this.serviceStatus.minimum_invoice_payment_sats
      }
      if (maxSendable > this.serviceStatus.maximum_invoice_payment_sats) {
        maxSendable = this.serviceStatus.maximum_invoice_payment_sats
      }
      let parsedArray = null
      this.lnurlMessage = 'Sending sats to Lightning Address.'
      try {
        parsedArray = JSON.parse(metadata)
        this.lnurlMessage = await this.parseLnurlMessage(parsedArray)
      } catch (error) {
      }
      const amount = prompt(
        `${this.lnurlMessage}\nChoose an amount between ${this.tidyNumber(minSendable)} sats and ${this.tidyNumber(maxSendable)} sats`,
        minSendable * 5
      )
      if (amount === null) {
        console.log('cancelled')
        this.clearInvoice('Cancelled')
        throw new Error('User Cancelled')
      }
      return amount * 1000
    },
    async queryComment (commentAllowed) {
      const comment = prompt('Send a message with your sats')
      return comment
    },
    async parseLnurlMessage (arr) {
      const lnurlDetails = await this.arrayToObject(arr)
      this.lnurlMessage = ''
      if (lnurlDetails['text/long-desc']) {
        this.lnurlMessage = lnurlDetails['text/long-desc']
      } else if (lnurlDetails['text/plain']) {
        this.lnurlMessage = lnurlDetails['text/plain']
      }
      // At some point we could deal with the image here.
      if (lnurlDetails['image/png;base64']) {
        this.lnurlImage = 'data:image/png;base64,' + lnurlDetails['image/png;base64']
      }
      return this.lnurlMessage
    },
    async arrayToObject (arr) {
      const res = {}
      for (const pair of arr) {
        const [key, value] = pair
        res[key] = value
      }
      return res
    },
    async addAmountComment (url, amount, comment) {
      const firstSeparator = url.includes('?') ? '&' : '?'
      const encComment = encodeURIComponent(comment)
      const ans = `${url}${firstSeparator}amount=${amount.toString()}&comment=${encComment}`
      console.log('answer with a comment')
      console.log(ans)
      return ans
    },
    bytesToString (bytes) {
      return String.fromCharCode.apply(null, bytes)
    },
    detectQueryString (url) {
      // regex pattern for detecting querystring
      const pattern = /\?.+=.*/g
      return pattern.test(url)
    }
  },
  mounted () {
    if (this.$route.query.invoice) { this.invoice = this.$route.query.invoice; this.checkInvoice() }
  }
}
</script>
