<template>
  <q-card flat class="text-center p-pa-md">
    <div class="text-title text-center">
      Pay a lightning network invoice with Hive or HBD
    </div>
    <div class="q-pa-md">
      <div class="q-gutter-md" style="max-width: 300px">
        <q-input
          v-model="hiveAccname"
          label="Send to Hive Account"
          @keyup="handleKeyup"
          @paste="handleKeyup"
          @keyup.esc="hiveAccname = ''"
          @keyup.enter="getHiveAccounts()"
          :style="invoiceStyles" />
      </div>
      <div class="q-pa-md">
        <div class="q-gutter-md row">
          <q-select
            filled
            :value="model"
            use-input
            hide-selected
            fill-input
            input-debounce="0"
            :options="options"
            @filter="filterFn"
            @input-value="setModel"
            hint="Text autocomplete"
            style="width: 250px; padding-bottom: 32px"
          >
            <template v-slot:no-option>
              <q-item>
                <q-item-section class="text-grey">
                  No results
                </q-item-section>
              </q-item>
            </template>
          </q-select>
        </div>
      </div>
    </div>
  </q-card>
</template>

<style scoped>
</style>

<script>
const stringOptions = [
  'brianoflondon'
].reduce((acc, opt) => {
  for (let i = 1; i <= 5; i++) {
    acc.push(opt + ' ' + i)
  }
  return acc
}, [])

import hive from '@hiveio/hive-js'
export default {
  name: 'LightningToHive',
  data () {
    return {
      hiveAccname: '',
      nameList: ''
    }
  },
  methods: {
    handleKeyup () {
      this.getHiveAccounts()
    },
    getHiveAccounts () {
      hive.api.getAccountReputations(this.hiveAccname, 10, function (err, data) {
        this.nameList = data
        console.log(err, data)
      })
    },
    filterFn (val, update, abort) {
      update(() => {
        const needle = val.toLocaleLowerCase()
        this.options = stringOptions.filter(v => v.toLocaleLowerCase().indexOf(needle) > -1)
      })
    },
    setModel (val) {
      this.model = val
    }
  },
  mounted () {
    console.log('lightningtohive')
  }
}
</script>
