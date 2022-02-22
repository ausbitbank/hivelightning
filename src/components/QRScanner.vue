<template>
  <div id="reader" width="600px"></div>
</template>

<script>
// eslint-disable-next-line import/default
import Html5QrcodeScanner from 'html5-qrcode'

export default {
  name: 'QRScanner',
  data () {
    return {
      data: ''
    }
  },
  props: {
    qrbox: {
      type: Number,
      default: 250
    },
    fps: {
      type: Number,
      default: 10
    }
  },
  mounted () {
    const config = {
      fps: this.fps,
      qrbox: this.qrbox
    }
    const html5QrcodeScanner = new Html5QrcodeScanner('qr-code-full-region', config)
    html5QrcodeScanner.render(this.onScanSuccess)
  },
  methods: {
    onScanSuccess (decodedText, decodedResult) {
      this.$emit('result', decodedText, decodedResult)
    }
  }
}
</script>
