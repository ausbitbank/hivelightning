<template>
  <q-card flat class="text-center p-pa-md">
    <div class="text-h6">Lightning to Hive</div>
    <usersearch
      :username="hiveAccname"
      @selectUsername="setUsername"
      label="To Hive account"></usersearch>
    <div>
      <div class="row">
        <div class="col-8">
          <div class="q-pa-md">
            <q-input
            name="Memo"
            v-model="memo"
            :label=memoLabel
            class="text-centre"
            />
          </div>
        </div>
        <div class="col">
          <div class="q-pa-md">
            <q-toggle
              v-model="privateMemo"
              label="Public/Private Memo"
              left-label
            />
          </div>
        </div>
      </div>
      <div>
        <v4vpay
          v-bind:prices="prices"
          v-bind:hiveAccname="hiveAccname"
          v-bind:serviceStatus="serviceStatus"
          v-bind:sendHiveTo="sendHiveTo"
          v-bind:memo="memo"
          v-bind:privateMemo="privateMemo"
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
      nameList: '',
      privateMemo: false
    }
  },
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  computed: {
    memoLabel: function () {
      if (this.privateMemo) {
        return 'Optional Private memo sent to recipient'
      } else {
        return 'Optional Public memo sent to recipient'
      }
    }
  },
  methods: {
    setUsername (u) {
      this.hiveAccname = u
    }
  },
  mounted () {
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
