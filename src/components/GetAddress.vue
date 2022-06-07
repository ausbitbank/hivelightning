<template>
  <q-card flat class="text-center q-pa-md">
    <div class="text-h6 q-pb-lg">Lightning Address</div>
    <div class="text-title text-center">
      <q-icon name="bolt" style="font-size: 1.3em"/> Lightning Address
      <q-icon name="qr_code_2"></q-icon>
      to <i class="pi pi-hiveio" style="font-size: 1.3em"></i> Hive
    </div>
    <usersearch
      :username="hiveAccname"
      @selectUsername="setUsername"
      label="To Hive account">
    </usersearch>
    <q-dialog
    v-model="qrpopup"
    @before-hide="clearData"
    >
      <q-card rounded class="text-center">
        <q-spinner-grid
          v-if="showLoading"
          color="primary"
          size="300px"
        />
        <q-card-section class="items-center q-pb-sm">
          <div class="container image" id="qr-code" ref="qrcode" style="width: 300px"></div>
        </q-card-section>
        <q-card-section class="q-pa-md q-gutter-lg">
          <q-btn
            class="glossy"
            rounded
            icon="save"
            size="2"
            label="png
            file" @click="downloadQR('png')"></q-btn>
          <q-btn
            class="glossy"
            rounded
            icon="save"
            label="svg file"
            @click="downloadQR('svg')"></q-btn>
        </q-card-section>
      </q-card>
    </q-dialog>
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
import userSearchBoxVue from 'src/components/userSearchBox.vue'
import QRCode from 'qr-code-styling'

export default {
  name: 'GetAddress',
  components: {
    usersearch: userSearchBoxVue
  },
  data () {
    return {
      hiveAccname: '',
      qrpopup: false,
      lightningInvoice: '',
      qrCode: new QRCode(),
      displayButton: false,
      showLoading: false
    }
  },
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  // directives: {
  //   autofocus: {
  //     inserted (el) {
  //       el.focus()
  //       console.log('input inserted')
  //     }
  //   }
  // },
  computed: {
  },
  methods: {
    downloadQR (filetype) {
      const fileName = this.hiveAccname + '_ln_v4vapp_address'
      this.qrCode.download({ name: fileName, extension: filetype })
    },
    async setUsername (u) {
      this.qrpopup = true
      this.hiveAccname = u
      const apiUrl = this.serviceStatus.apiUrl
      const url = apiUrl + '/v1/lnurlp/qrcode/text/' + u + '?source=v4v.app'
      const response = await this.$axios.get(url)
      this.lightningInvoice = response.data.prefix
      this.getQRCode()
    },
    getQRCode () {
      // sets the QR code based on current status
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
      this.qrCode.append(this.$refs.qrcode)
    },
    clearData () {
      this.hiveAccname = ''
      this.qrpopup = false
      this.lightningInvoice = ''
      this.qrCode = new QRCode()
      this.displayButton = false
    }
  },
  mounted () {
    if (this.$route.params.hiveAccname) {
      this.qrpopup = true
      this.showLoading = true
      setTimeout(() => {
        this.setUsername(this.$route.params.hiveAccname)
        this.qrpopup = true
        this.showLoading = false
      }, 4000).then(() => { })
    }
  }
}
</script>
