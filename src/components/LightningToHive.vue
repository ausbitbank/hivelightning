<template>
  <q-card flat class="text-center p-pa-md">
    <div class="text-title text-center">
      Pay a lightning network invoice with Hive or HBD
    </div>
    <usersearch
      @keyup="handleKeyup"
      :username="hiveAccname"
      @selectUsername="setUsername"
      label="To account"></usersearch>
  </q-card>
</template>

<style scoped>
</style>

<script>
import userSearchBoxVue from 'src/components/userSearchBox.vue'

// import hive from '@hiveio/hive-js'
export default {
  name: 'LightningToHive',
  data () {
    return {
      hiveAccname: '',
      nameList: ''
    }
  },
  methods: {
    setUsername (u) {
      this.hiveAccname = u
      console.log(this.hiveAccname)
    },
    handleKeyup () {
      console.log(this.toAccount)
      // this.getHiveAccounts()
    },
    getHiveAccounts () {
      this.$hive.api.getAccountReputations(this.hiveAccname, 10, function (err, data) {
        this.nameList = data
        console.log(err, data)
      })
    }
  },
  mounted () {
    console.log('lightningtohive')
  },
  components: {
    usersearch: userSearchBoxVue
  }
}
</script>
