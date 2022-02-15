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
    <q-dialog v-model="icon">
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Close icon</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section>
          <div>
            <div id="qr-code2" ref="qrcode2"> </div>
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
    <div>
      <canvas id="qr-code"></canvas>
      <div id="qr-code2" ref="qrcode2"> </div>
    </div>
  </div>
</template>

<script>

import QRCode from 'qr-code-styling'

export default {
  name: 'V4VPay',
  data () {
    return {
      tallyResponse: '',
      amounts: ['1.00', '2.00', '5.00', '10.00', '15.00', '20.00'],
      amountSats: '',
      amountUSD: '',
      lightningInvoice: '',
      icon: false,
      qrCode: new QRCode()
    }
  },
  props: ['prices', 'hiveAccname', 'memo'],
  methods: {
    openDialog () {
      this.icon = true
      this.getInvoice()
    },
    getInvoice () {
      // validation goes hideSplashscreen
      // if (!this.amountSats) { return }
      // and then we call
      this.lightningInvoice = 'lnbc10100n1p3qkmp2pp5mwaerj86c80088fm9a7lr32gvfxdff4n428c8jrhcjnndu20l2qsdzgvfexjctwdanxcmmwv3hkugruyphx7argd9hxwgrzw46zqum0d4jjpuyl5j3jqgmkx3mxzurscqzpgxqzjcsp546e9yawd2jgkntqkud099q3nlcx2m6879jnms26d73pz8qg53nrq9qyyssqpc4rqt00fjr3y4ed36ndgk76zwe2jfcrl3eql00w2ljtw2crev393jherxkw23t7ddrdypfuesp9yzxj2u5acrv568af6knsyldnvncpf3f55y'
      this.qrCode = new QRCode({
        width: 300,
        height: 300,
        type: 'svg',
        data: this.lightningInvoice,
        image: 'https://images.hive.blog/u/' + 'brianoflondon' + '/avatar',
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
      this.qrCode.append(this.$refs.qrcode2)

      // bypass all this for testing
      // const data = {
      //   out: false,
      //   amount: parseInt(this.amountSats),
      //   memo: this.hiveAccname + ' | ' + this.memo + ' #v4vapp'
      // }
      // const headers = {
      //   'X-Api-Key': '66090b27d802460a9800d29b5e943e2e'
      // }
      // const url = 'http://umbrel.local:3007/api/v1/payments'
      // this.$axios({
      //   method: 'POST',
      //   url: url,
      //   headers: headers,
      //   data: data
      // }).then(response => {
      //   console.log(data)
      //   console.log('Payment Hash:    ' + response.data.payment_hash)
      //   console.log('Payment Request: ' + response.data.payment_request)
      //   console.log(response)
      //   this.lightningInvoice = response.data.payment_request
      //   const qrcode = new QRious({
      //     level: 'H',
      //     padding: 25,
      //     size: 300,
      //     element: document.getElementById('qr-code'),
      //     value: this.lightningInvoice
      //   })
      //   console.log(qrcode)
      // })
    },
    alert () {
      this.$q.dialog({
        title: 'Alert',
        message: 'Some message'
      }).onOk(() => {
        // console.log('OK')
      }).onCancel(() => {
        // console.log('Cancel')
      }).onDismiss(() => {
        // console.log('I am triggered on both OK and Cancel')
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
