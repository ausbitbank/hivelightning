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
            <div class="container image" id="qr-code" ref="qrcode" @click="copySelect">
              <q-img
                class="overlay"
                v-if="paid"
                src="icons8-check-circle.svg"
                style="height: 300px; max-width: 300px"
              />
            </div>
          <div>Click image to copy invoice code</div>
          <q-input
            type="textarea"
            id="copy-text"
            :value="lightningInvoice"
            autogrow
            autofocus
            @click="copySelect"
            ref="copyText" />
        </q-card-section>
        <q-card-section>
          <q-linear-progress size="25px" :value="progress1" color="accent">
          </q-linear-progress>
        </q-card-section>
      </q-card>
    </q-dialog>
    <div class="p-pa-sm">
      <div class="row">
        <div class="col-6">
          <div class="q-pa-sm q-gutter-sm">
            <q-btn
              class="glossy q-pa-none"
              rounded
              color="primary"
              label="Get Hive"
              @click="newInvoiceDialog('HIVE')"
              icon="bolt" />
          </div>
        </div>
        <div class="col-6">
          <div class="q-pa-sm q-gutter-sm">
            <q-btn
              class="glossy q-pa-none"
              rounded
              color="secondary"
              label="Get HBD"
              @click="newInvoiceDialog('HBD')"
              icon="bolt" />
          </div>
        </div>
        <div ref="testing"></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
* {box-sizing: border-box;}

.container {
  position: relative;
  width: 100%;
  max-width: 300px;
}

.image {
  display: block;
  width: 100%;
  height: auto;
}

.overlay {
  position: absolute;
  bottom: 0;
  background: rgb(0, 0, 0);
  background: rgba(0, 0, 0, 0.5); /* Black see-through */
  color: #f1f1f1;
  width: 100%;
  transition: 1s ease;
  opacity:1;
}

.container:hover .overlay {
  opacity: 1;
}

</style>

<script>

import QRCode from 'qr-code-styling'
import { copyToClipboard } from 'quasar'
const umbrelUrl = 'http://umbrel.local:3007/api/v1/payments'
const headers = {
  'X-Api-Key': '66090b27d802460a9800d29b5e943e2e'
}

export default {
  name: 'V4VPay',
  data () {
    return {
      testing: false,
      tallyResponse: '',
      amounts: ['0.50', '1.00', '2.00', '5.00', '10.00', '15.00', '20.00'],
      amountSats: '',
      amountUSD: '',
      lightningInvoice: '',
      paymentHash: '',
      qrpopup: false,
      localHiveAccname: '',
      qrCode: new QRCode(),
      progress1: 0,
      progressLabel1: '',
      paid: false
    }
  },
  props: ['prices', 'hiveAccname', 'memo'],
  methods: {
    copySelect (ev) {
      copyToClipboard(this.lightningInvoice)
        .then(() => {
          this.$q.notify('Copied!')
        })
        .catch(() => {
          console.error('Error while copying')
        })
    },
    newInvoiceDialog () {
      this.qrpopup = true
      console.log('in my test')
      console.log('lightning invoice ' + this.lightningInvoice)
      this.localHiveAccname = this.hiveAccname
      if (this.testing) {
        this.localHiveAccname = 'brianoflondon'
        this.amountSats = 1333
      }
      // const goodbye = new Promise((resolve, reject) => {
      //   setTimeout(resolve, 10, 'goodbye')
      // })
      const fetchInvoice = this.getInvoiceAsync('HIVE')
      Promise.all([fetchInvoice]).then((values, err) => {
        console.log('promises finished')
        console.log(values)
        this.getQRCode()
        this.qrCode.append(this.$refs.qrcode)
        this.showCountdown()
      }).catch(err => {
        console.error(err)
        this.$q.notify(err)
      })
      console.log('Finished!')
    },
    showCountdown () {
      // we simulate some progress here...
      const timeLimit = 300000 // Microsecond time limit
      let percentage = 0
      let elapsedTime = 100
      const start = Date.now()
      let n = 0
      let paid = false
      const interval = setInterval(() => {
        // percentage = Math.min(100, percentage + Math.floor(Math.random() * 45))
        elapsedTime = Math.floor(Date.now() - start)
        percentage = elapsedTime / timeLimit
        // console.log(elapsedTime)
        // console.log(percentage)
        this.progress1 = percentage
        n += 1
        if (n % 250 === 0) {
          console.log('------------------>' + elapsedTime)
          paid = this.checkInvoiceAsync(this.paymentHash)
          Promise.all([paid]).then((values, err) => {
            console.log(values)
            this.paid = values[0]
          }).catch(err => {
            console.error(err)
          })
        }
        // if we are done, we're gonna close it
        if (this.paid | !this.qrpopup | elapsedTime > timeLimit) {
          console.log('Ending the loop')
          clearInterval(interval)
          setTimeout(() => {
            this.qrpopup = false
            this.lightningInvoice = ''
            this.paymentHash = ''
            this.localHiveAccname = ''
            this.qrCode = new QRCode()
            this.amountSats = ''
            this.paid = false
          }, 1500)
        }
      }, 100)
    },
    getInvoiceAsync (currency) {
      this.lightningInvoice = ''
      return new Promise((resolve, reject) => {
        if (!this.amountSats | !this.localHiveAccname) {
          reject('Hive Account name or sending value not set')
          this.qrpopup = false
          throw new Error('Hive Account name or sending value not set')
        }
        let memo = this.localHiveAccname + ' | ' + this.memo + ' #v4vapp'
        if (currency === 'HBD') {
          memo += ' HBD'
        }
        const data = {
          out: false,
          amount: parseInt(this.amountSats),
          memo: memo
        }
        // const headers = {
        //   'X-Api-Key': '66090b27d802460a9800d29b5e943e2e'
        // }
        let url = ''
        if (this.testing) {
          url = 'https://reqbin.com/echo/post/json'
        } else {
          url = umbrelUrl
        }
        this.$axios({
          method: 'POST',
          url: url,
          headers: headers,
          data: data
        }).then((response, err) => {
          console.log(data)
          console.log('Payment Hash:    ' + response.data.payment_hash)
          console.log('Payment Request: ' + response.data.payment_request)
          console.log(response)
          if (response.data.payment_request) {
            this.lightningInvoice = response.data.payment_request
            this.paymentHash = response.data.payment_hash
          } else {
            console.log('TESTING' + this.lightningInvoice)
            this.paymentHash = '752889a6db7ee84646a511f65fb01d0f174c42b83891ecc3e26c262f33029949'
            this.lightningInvoice = 'lnbc22570n1p3qh2l6pp5yud8hhcz4xtng4ekxqx05dkmk464gtpjld7kyyl97d2rhlg5cztsdz6vfexjctwdanxcmmwv3hkugruyrcfl9997z0eff0sn722tuyljjjlp8axsncflf5y7z06dp8sn7ngggprwc68vctswqcqzpgxqzjcsp5wfmx6rhkllzzh328uhdh3vg0d7julhra4qd54va4r9ca5jfqtq7s9qyyssqzgd0v7ddtx8plymtwt0u52kpevwj85t2uc253npng6h5n4gv5f8p5480nfdsgek22mffwksc7d6p95rjhxg4l2td0zhrkhhejccaucqq6wx6gq'
          }
          resolve(response)
        }).catch(err => {
          console.error(err)
          this.qrpopup = false
          this.$q.notify('Problems fetching new Lightning Invoice: ' + err.message)
        })
      })
    },
    getQRCode () {
      // sets the QR code based on current status
      this.qrCode = new QRCode({
        width: 300,
        height: 300,
        margin: 1,
        type: 'svg',
        data: this.lightningInvoice,
        image: 'https://images.hive.blog/u/' + this.localHiveAccname + '/avatar',
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
    },
    checkInvoiceAsync (paymentHash) {
      const url = umbrelUrl + '/' + paymentHash
      return new Promise((resolve, reject) => {
        this.$axios({
          method: 'GET',
          url: url,
          headers: headers
        }).then((response, err) => {
          console.log(response)
          if (response.data.paid) {
            console.log('it was paid!!!!')
            this.paid = true
            resolve(true)
          }
          resolve(false)
        }).catch(err => {
          console.error(err)
          reject(err)
        })
      })
    }
  },
  components: {
  }
}
</script>
