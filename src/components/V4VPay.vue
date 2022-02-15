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
    <div>
      <canvas id="qr-code"></canvas>
    </div>
    <div class="p-pa-lg">
      <q-btn
        class="glossy"
        rounded
        color="primary"
        label="Send Lightning"
        @click="getInvoice"
        icon="bolt" />
    </div>
  </div>
</template>

<script>
import QRious from 'qrious'

export default {
  name: 'V4VPay',
  data () {
    return {
      tallyResponse: '',
      amounts: ['1.00', '2.00', '5.00', '10.00', '15.00', '20.00'],
      amountSats: '',
      amountUSD: '',
      lightningInvoice: ''
    }
  },
  props: ['prices', 'hiveAccname', 'memo'],
  methods: {
    getInvoice () {
      // validation goes hideSplashscreen
      if (!this.amountSats) { return }
      // and then we call
      const data = {
        out: false,
        amount: parseInt(this.amountSats),
        memo: this.hiveAccname + ' | ' + this.memo + ' #v4vapp'
      }
      const headers = {
        'X-Api-Key': '66090b27d802460a9800d29b5e943e2e'
      }
      const url = 'http://umbrel.local:3007/api/v1/payments'

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
        this.lightningInvoice = response.data.payment_request
        const qrcode = new QRious({
          level: 'H',
          padding: 25,
          size: 300,
          element: document.getElementById('qr-code'),
          value: this.lightningInvoice
        })
        console.log(qrcode)
      })

      // const endpoint = '/v1/fundraiser/'
      // const params = {
      //   fundraiser_id: 'yfu4zg'
      // }
      // const ans = this.tallyApiCall(params, endpoint)
      // console.log(ans)

      // this.$axios.post('https://api.tallyco.in/v1/fundraiser/', {
      //   fundraiser_id: 'yfu4zg'
      // }).then(function (response) {
      //   console.log(response)
      // })
      // this.$axios({
      //   method: 'post',
      //   url: 'https://api.tallyco.in/v1/fundraiser/',
      //   crossdomain: true,
      //   params: {
      //     fundraiser_id: 'yfu4zg'
      //   }
      // }).then((response) => {
      //   console.log(response.data)
      // }).catch((err) => {
      //   console.error(err.message)
      // })
      // const tallyData = {
      //   type: 'fundraiser',
      //   id: 'yfu4zg',
      //   satoshi_amount: parseInt(this.amountSats),
      //   payment_method: 'ln',
      //   message: 'brianoflondon'
      // }
      // const dataToSend = JSON.stringify(tallyData)
      // console.log(tallyData)
      // console.log(dataToSend)
      // this.$axios({
      //   method: 'post',
      //   url: 'https://api.tallyco.in/v1/payment/request/',
      //   data: tallyData
      // }).then((response) => {
      //   console.log(response.data)
      //   console.log(response.data.error)
      // }).catch((error) => { console.error(error) })
      // this.$axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
      // this.$axios.post('http://api.tallyco.in/v1/payment/request/', tallyData)
      //   .then((response) => {
      //     this.tallyResponse = response.data
      //     console.log(this.tallyResponse.error)
      //     console.log(this.tallyResponse.lightning_pay_request)
      //     console.log(this.tallyResponse.lightning_invoice_id)
      //   })
      //   .catch((error) => {
      //     console.log('Call to TallyCoin failed')
      //     console.error(error)
      //   })
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
