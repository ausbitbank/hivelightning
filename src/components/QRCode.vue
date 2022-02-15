<template>
  <q-page>

     <q-input v-model="qrLink" label="Input value to generate" />
     <br/>
     <q-btn color="primary" label="Generate QR Code" @click="generateQrCode" />

      <canvas id="qr-code">

    </canvas>

  </q-page>
</template>

<script>

import QRious from 'qrious'

export default {
  name: 'PageIndex',
  data () {
    return {
    }
  },
  props: ['lightningInvoice'],
  methods: {
    generateQrCode: function () {
      console.log(this.lightningInvoice)
      if (this.lightningInvoice !== '' && this.lightningInvoice !== '\n') {
        QRious({
          level: 'H',
          padding: 25,
          size: 300,
          element: document.getElementById('qr-code'),
          value: this.lightningInvoice
        })
      }
    }
  }
}
</script>
