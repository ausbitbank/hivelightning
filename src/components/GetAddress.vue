<template>
  <q-card flat class="text-center q-pa-md">
    <div class="text-h6 q-pb-lg">Lightning Address</div>
    <div class="text-title text-center">
      Get a <q-icon name="bolt" /> Lightning Address QR code forwarding to <i class="pi pi-hiveio"></i> Hive
    </div>
    <usersearch
      :username="hiveAccname"
      @selectUsername="setUsername"
      label="To Hive account">
    </usersearch>
    <q-dialog>
      v-model="qrpopup"
      <q-card>
        <q-card-section>
          <q-img v-if="laQRcode"></q-img>
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

export default {
  name: 'GetAddress',
  components: {
    usersearch: userSearchBoxVue
  },
  data () {
    return {
      hiveAccname: '',
      qrpopup: false,
      laQRcode: null
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
  },
  methods: {
    async setUsername (u) {
      this.hiveAccname = u
      const apiUrl = this.serviceStatus.apiUrl
      const url = apiUrl + '/v1/lnurlp/qrcode/' + u
      console.log(url)
      const response = await this.$axios.get(url)
      this.qrpopup = true
      this.laQRcode = response.data
      console.log(response)
    },
    tidyNumber (x) {
      if (x) {
        const parts = x.toString().split('.')
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
        return parts.join('.')
      } else {
        return null
      }
    }
  },
  mounted () {
  }
}
</script>
