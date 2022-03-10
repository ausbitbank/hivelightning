<template>
  <div>
    <!-- Amounts keyboard -->
    <div class="q-pa-md q-gutter-sm">
      <q-btn
        color="primary"
        class="btn-fixed-width"
        :name="index"
        :label="n"
        v-for="(n, index) in amountLabels"
        :key="index"
        @click="buttonClick(index)" />
    </div>
    <!-- Ammount Inputs -->
    <div class="row">
      <div class="col-6">
        <div class="q-pa-sm q-gutter-sm">
          <q-input
            v-model="amountSats"
            @input="recalcUSD"
            @keyup="recalcUSD"
            label="Amount (sats)"
            :rules="[ amountSats => minInv <= amountSats && amountSats <= maxInv || errorMessage ]"
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
            readonly
            v-model="amountUSD"
            @input="recalcSATS"
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
    <!-- Popup with QR Code -->
    <q-dialog
      v-model="qrpopup"
      @before-hide="clearData">
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Send Lightning</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section class="row items-center">
          <q-space />
          <div class="container image" id="qr-code" ref="qrcode" @click="copySelect" style="width: 300px">
            <q-img
              class="overlay"
              v-if="paid"
              src="icons8-check-circle.svg"
              style="height: 300px; max-width: 300px"
            />
            <q-linear-progress size="5px" :value="progress1" color="accent" style="width: 300px">
            </q-linear-progress>
          </div>
          <q-space />
        </q-card-section>
        <q-card-section>
          <div class="text-center text-bold">Click image to copy invoice code</div>
          <div class="text-center text-bold">Sending {{ amountSats }} sats</div>
          <br/>
          <div @click="copySelect" class="text-small text-body2 overflow" width="100%">{{ lightningInvoice }}</div>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-- Hive Buttons -->
    <div class="p-pa-sm">
      <div class="row" v-if="prices && serviceStatus">
        <div class="col-6">
          <div class="q-pa-sm q-gutter-sm">
            <q-btn
              class="glossy q-pa-none"
              rounded
              color="primary"
              ref="hive_button"
              :label="hiveLabel"
              @click="newInvoiceDialog('HIVE')"
              @mouseenter="recalcHive"
              icon="bolt" />
          </div>
        </div>
        <div class="col-6">
          <div class="q-pa-sm q-gutter-sm">
            <q-btn
              class="glossy q-pa-none"
              rounded
              color="secondary"
              ref="hbd_button"
              :label="hbdLabel"
              @click="newInvoiceDialog('HBD')"
              @mouseenter="recalcHive"
              icon="bolt" />
          </div>
        </div>
        <div ref="testing"></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* * {box-sizing: border-box;} */
.overflow {
  overflow-wrap: break-word;
}

.container {
  position: relative;
  width: 100%;
  max-width: 300px;
}

.image {
  align-self: center;
  display: block;
  width: 100%;
  height: auto;
}

.overlay {
  position: absolute;
  bottom: 0;
  border: 10px solid black;
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

// const headers = {
//   'X-Api-Key': '66090b27d802460a9800d29b5e943e2e'
// }
const headers = {
  'X-Api-Key': ''
}

export default {
  name: 'V4VPay',
  data () {
    return {
      testing: false,
      tallyResponse: '',
      amounts: ['1500', '3000', '5000', '7500', '15000', '30000', '50000', '100000'],
      amountLabels: ['1500', '3000', '5000', '7500', '15000', '30000', '50000', '100000'],
      amountSats: '',
      amountSatsFees: '',
      amountUSD: '',
      amountUSDFees: '',
      amountHIVE: '',
      amountHBD: '',
      hiveLabel: 'Hive',
      hbdLabel: 'HBD',
      lightningInvoice: '',
      paymentHash: '',
      qrpopup: false,
      localHiveAccname: '',
      qrCode: new QRCode(),
      progress1: 100,
      progressLabel1: '',
      paid: false
    }
  },
  props: ['prices', 'hiveAccname', 'memo', 'serviceStatus', 'sendHiveTo'],
  computed: {
    minInv: function () { return this.serviceStatus.minimum_invoice_payment_sats },
    maxInv: function () { return this.serviceStatus.maximum_invoice_payment_sats },
    errorMessage: function () {
      return 'Between ' + this.tidyNumber(this.minInv) + ' and ' + this.tidyNumber(this.maxInv) + ' sats'
    }
  },
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
    newInvoiceDialog (currency) {
      if ((this.amountSats < this.serviceStatus.minimum_invoice_payment_sats) ||
      (this.amountSats >= this.serviceStatus.maximum_invoice_payment_sats)) {
        this.$q.notify('Sats must be between 1,000 and 100,000 per swap')
        return
      }
      this.qrpopup = true
      this.localHiveAccname = this.hiveAccname
      if (this.testing) {
        this.localHiveAccname = 'brianoflondon'
        this.amountSats = 1333
      }
      const fetchInvoice = this.getInvoiceAsync(currency)
      Promise.all([fetchInvoice]).then((values, err) => {
        this.getQRCode()
        this.qrCode.append(this.$refs.qrcode)
        this.showCountdown()
      }).catch(err => {
        console.error(err)
        this.$q.notify(err)
      })
      // console.log('Finished!')
    },
    showCountdown () {
      // we simulate some progress here...
      let timeLimit = 10
      if (this.testing) {
        timeLimit = 100000
      } else {
        timeLimit = 300000 // Microsecond time limit
      }
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
        if (n % 10 === 0) { // frequency to check API for invoice paid
          paid = this.checkInvoiceAsync(this.paymentHash)
          Promise.all([paid]).then((values, err) => {
            this.paid = values[0]
          }).catch(err => {
            console.error(err)
          })
        }
        // if we are done, we're gonna close it
        if (this.paid | !this.qrpopup | elapsedTime > timeLimit) {
          // console.log('Ending the loop')
          clearInterval(interval)
          setTimeout(() => {
            this.qrpopup = false
          }, 3000) // Close down time after success
        }
      }, 200) // update time for progress
    },
    clearData () {
      this.lightningInvoice = ''
      this.paymentHash = ''
      this.localHiveAccname = ''
      this.qrCode = new QRCode()
      this.amountSats = ''
      this.amountUSD = ''
      this.paid = false
      this.recalcUSD()
      this.recalcHive()
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
        let url = ''
        url = this.serviceStatus.apiUrl + '/v1/new_invoice'
        this.$axios({
          method: 'POST',
          url: url,
          headers: headers,
          data: data,
          testing: this.testing
        }).then((response, err) => {
          // console.log(data)
          // console.log('Payment Hash:    ' + response.data.payment_hash)
          // console.log('Payment Request: ' + response.data.payment_request)
          // console.log(response)
          if (response.data.payment_request) {
            this.lightningInvoice = response.data.payment_request
            this.paymentHash = response.data.payment_hash
          } else {
            // console.log('TESTING' + this.lightningInvoice)
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
      this.amountSats = this.amounts[index]
      this.recalcSATS()
      this.recalcUSD()
    },
    recalcUSD () {
      if (this.prices) {
        this.amountUSD = ((this.amountSats / 1e8) * this.prices.bitcoin.usd).toFixed(2)
        this.amountUSDFees = ((this.amountSatsFees / 1e8) * this.prices.bitcoin.usd).toFixed(2)
        this.recalcHive()
      } else {
        setTimeout(() => {
          console.log('Waiting for prices...')
          this.recalcUSD()
        }, 1000)
      }
    },
    recalcSATS () {
      this.amountSatsFees = ((this.amountSats - this.serviceStatus.conv_fee_sats) * (1 - this.serviceStatus.conv_fee_percent)).toFixed(0)
      this.recalcUSD()
    },
    recalcHive () {
      this.amountHIVE = (this.amountUSDFees / this.prices.hive.usd).toFixed(2)
      this.amountHBD = (this.amountUSDFees / this.prices.hive_dollar.usd).toFixed(2)
      if (!isNaN(this.amountHBD) | this.amountHBD <= 0) {
        this.hiveLabel = this.amountHIVE + ' Hive'
        this.hbdLabel = this.amountHBD + ' HBD'
      } else {
        this.hiveLabel = 'Hive'
        this.hbdLabel = 'HBD'
      }
    },
    recalcButtons () {
      this.amountLabels = this.amounts.map(this.buttonText)
    },
    buttonText (sats) {
      return this.tidyNumber(sats)
    },
    satsToDollars (sats) {
      const satsFees = ((sats - this.serviceStatus.conv_fee_sats) * (1 - this.serviceStatus.conv_fee_percent)).toFixed(0)
      if (this.prices) {
        return (satsFees / 1e8 * this.prices.bitcoin.usd).toFixed(2)
      } else {
        return 1
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
    checkInvoiceAsync (paymentHash) {
      const url = this.serviceStatus.apiUrl + '/v1/check_invoice/' + paymentHash
      return new Promise((resolve, reject) => {
        this.$axios({
          method: 'GET',
          url: url,
          headers: headers,
          params: { testing: this.testing }
        }).then((response, err) => {
          // console.log(response)
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
  },
  mounted () {
    // this.recalcUSD()
    if (this.$route.params.inputSats) {
      this.amountSats = this.$route.params.inputSats
    }
    this.recalcButtons()
    this.recalcUSD()
  },
  beforeUpdate () {
    this.recalcButtons()
    this.recalcUSD()
  },
  updated () {
    this.recalcUSD()
  }
}
</script>
