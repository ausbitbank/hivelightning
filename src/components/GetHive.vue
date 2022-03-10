<template>
  <q-card flat class="text-center p-pa-md">
    <div class="text-h6">Lightning to Hive</div>
    <usersearch
      :username="hiveAccname"
      @selectUsername="setUsername"
      label="To account"></usersearch>
    <div>
      <div class="q-pa-md">
        <q-input
        name="Memo"
        v-model="memo"
        label="Optional Memo to recipient (will be private)"
        class="text-centre"
        />
      </div>
      <div>
        <v4vpay
          v-bind:prices="prices"
          v-bind:hiveAccname="hiveAccname"
          v-bind:serviceStatus="serviceStatus"
          v-bind:sendHiveTo="sendHiveTo"
          v-bind:memo="memo"
        />
      </div>
      <div class="q-pt-lg">
        <swapstatus
          :sendHiveTo="sendHiveTo"
          :serviceStatus="serviceStatus"
          :swapStatus="serviceStatus.closed_get_hive"
        ></swapstatus>
      </div>
    </div>
  </q-card>
</template>

<style scoped>
</style>

<script>
import userSearchBoxVue from 'src/components/userSearchBox.vue'
import V4VPay from 'src/components/V4VPay.vue'
import SwapStatusVue from 'src/components/SwapStatus.vue'

// import hive from '@hiveio/hive-js'
export default {
  name: 'GetHive',
  data () {
    return {
      hiveAccname: '',
      memo: '',
      nameList: ''
    }
  },
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  methods: {
    setUsername (u) {
      this.hiveAccname = u
    }
  },
  mounted () {
    console.log(this.$route.params)
    if (this.$route.params.hiveAccname) {
      this.hiveAccname = this.$route.params.hiveAccname
    }
    if (this.$route.params.memo) {
      this.memo = this.$route.params.memo
    }
  },
  components: {
    usersearch: userSearchBoxVue,
    v4vpay: V4VPay,
    swapstatus: SwapStatusVue
  }
}
</script>
