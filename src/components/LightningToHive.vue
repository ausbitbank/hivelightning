<template>
  <q-card flat class="text-center p-pa-md">
    <div class="text-h6">Lightning to Hive</div>
    <usersearch
      :username="hiveAccname"
      @selectUsername="setUsername"
      label="To account"></usersearch>
    <div>
      <div>
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
          v-bind:memo="memo"
        />
      </div>
    </div>
  </q-card>
</template>

<style scoped>
</style>

<script>
import userSearchBoxVue from 'src/components/userSearchBox.vue'
import V4VPay from 'src/components/V4VPay.vue'

// import hive from '@hiveio/hive-js'
export default {
  name: 'LightningToHive',
  data () {
    return {
      hiveAccname: '',
      memo: '',
      nameList: ''
    }
  },
  props: ['prices'],
  methods: {
    setUsername (u) {
      this.hiveAccname = u
    }
  },
  mounted () {
    console.log('lightningtohive')
  },
  components: {
    usersearch: userSearchBoxVue,
    v4vpay: V4VPay
  }
}
</script>
