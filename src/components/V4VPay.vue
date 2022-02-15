<template>
  <div>
    <div class="q-pa-md q-gutter-sm">
      <q-btn
        color="primary"
        class="btn-fixed-width"
        :name="index"
        :label="n"
        v-for="(n, index) in amounts"
        :key="index"
        @click="buttonClick(index)" />
    </div>
    <!-- Ammount Inputs -->
    <div class="row">
      <div class="col-6">
        <div class="q-pa-sm q-gutter-sm">
          <q-input
            v-model="amountSats"
            @keyup="recalcUSD"
            label="Amount (sats)"
          >
            <template v-slot:prepend>
              <q-icon name="currency_bitcoin" />
            </template>
          </q-input>
        </div>
      </div>
      <div class="col-6">
        <div class="q-pa-sm q-gutter-sm">
          <q-input
            v-model="amountUSD"
            @keyup="recalcSATS"
            label="Amount (USD)"
          >
            <template v-slot:prepend>
              <q-icon name="monetization_on" />
            </template>
          </q-input>
        </div>
      </div>
    </div>
    <q-dialog v-model="qrpopup">
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Send Lightning</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section>
          <div>
            <div id="qr-code" ref="qrcode" @click="copySelect"></div>
            <div>Click image to copy invoice code</div>
            <q-input
              type="textarea"
              id="copy-text"
              :value="lightningInvoice"
              autogrow
              autofocus
              @click="copySelect"
              ref="copyText" />
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
    <div class="p-pa-lg">
      <q-btn
        class="glossy"
        rounded
        color="primary"
        label="Send Lightning"
        @click="openDialog"
        icon="bolt" />
    </div>
  </div>
</template>

<script>

import QRCode from 'qr-code-styling'
import { copyToClipboard } from 'quasar'

export default {
  name: 'V4VPay',
  data () {
    return {
      tallyResponse: '',
      amounts: ['0.50', '1.00', '2.00', '5.00', '10.00', '15.00', '20.00'],
      amountSats: '',
      amountUSD: '',
      lightningInvoice: '',
      qrpopup: false,
      qrCode: null
    }
  },
  props: ['prices', 'hiveAccname', 'memo'],
  methods: {
    openDialog () {
      this.qrpopup = true
      const testing = false
      const success = this.getInvoice(testing)
      if (success) {
        console.log(this.qrCode)
      } else {
        this.$q.notify('Problem creating invoice, try later.')
      }
      console.log(success)
    },
    copySelect (ev) {
      copyToClipboard(this.lightningInvoice)
        .then(() => {
          this.$q.notify('Copied!')
        })
        .catch(() => {
          console.error('Error while copying')
        })
    },
    getInvoice (testing) {
      // validation goes hideSplashscreen
      if (!this.amountSats | !this.hiveAccname) { return false }
      // and then we call
      const data = {
        out: false,
        amount: parseInt(this.amountSats),
        memo: this.hiveAccname + ' | ' + this.memo + ' #v4vapp'
      }
      const headers = {
        'X-Api-Key': '66090b27d802460a9800d29b5e943e2e'
      }
      let url = ''
      if (testing) {
        url = 'https://reqbin.com/echo/post/json'
      } else {
        url = 'http://umbrel.local:3007/api/v1/payments'
      }
      this.$axios({
        method: 'POST',
        url: url,
        headers: headers,
        data: data
      }).then(response => {
        console.log(data)
        console.log('Payment Hash:    ' + response.data.payment_hash)
        console.log('Payment Request: ' + response.data.payment_request)
        console.log(response)
        if (response.data.payment_request) {
          this.lightningInvoice = response.data.payment_request
        } else {
          console.log('TESTING' + this.lightningInvoice)
          this.lightningInvoice = 'lnbc22570n1p3qh2l6pp5yud8hhcz4xtng4ekxqx05dkmk464gtpjld7kyyl97d2rhlg5cztsdz6vfexjctwdanxcmmwv3hkugruyrcfl9997z0eff0sn722tuyljjjlp8axsncflf5y7z06dp8sn7ngggprwc68vctswqcqzpgxqzjcsp5wfmx6rhkllzzh328uhdh3vg0d7julhra4qd54va4r9ca5jfqtq7s9qyyssqzgd0v7ddtx8plymtwt0u52kpevwj85t2uc253npng6h5n4gv5f8p5480nfdsgek22mffwksc7d6p95rjhxg4l2td0zhrkhhejccaucqq6wx6gq'
        }
        this.qrCode = new QRCode({
          width: 300,
          height: 300,
          margin: 1,
          type: 'svg',
          data: this.lightningInvoice,
          image: 'https://images.hive.blog/u/' + this.hiveAccname + '/avatar',
          dotsOptions: {
            color: 'active',
            type: 'rounded'
          },
          backgroundOptions: {
            color: '#e9ebee'
          },
          imageOptions: {
            crossOrigin: 'anonymous',
            margin: 0
          }
        })
        console.log(this.qrCode)
        this.qrCode.append(this.$refs.qrcode)
        return true
      }).catch(err => {
        console.error(err)
        this.$q.notify('Failed to generate new invoice. Lighting is acting up!')
        return false
      })
    },
    buttonClick (index) {
      this.amountUSD = this.amounts[index]
      this.recalcSATS()
      console.log(this.amounts[index])
      this.amountSats = ((this.amountUSD / this.prices.bitcoin.usd) * 1e8).toFixed(0)
    },
    recalcUSD () {
      console.log(this.amountSats)
      this.amountUSD = ((this.amountSats / 1e8) * this.prices.bitcoin.usd).toFixed(2)
    },
    recalcSATS () {
      this.amountSats = ((this.amountUSD / this.prices.bitcoin.usd) * 1e8).toFixed(0)
    }
  },
  components: {
  }
}
</script>
