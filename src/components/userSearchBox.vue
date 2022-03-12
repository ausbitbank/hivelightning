<template>
<div>
  <div class="row items-top q-pa-md">
    <div class="col-8 q-pr-sm">
      <q-select
        clearable
        autocomplete
        hide-selected
        :value="input"
        use-input
        fill-input
        input-debounce="10"
        v-model="input"
        :label="label"
        :options="usernameSuggestions"
        @keyup.esc="clearInput"
        @filter="filterFn"
        @filter-abort="abortFilterFn"
        @input-value="virtualScroll"
        @input="$emit('selectUsername', input)" />
      </div>
      <div class="col-4">
        <q-card class="my-card">
          <q-img
            :src="avatarIRI"
            basic
          >
          <div class="my-text absolute-bottom text-subtitle2 text-center">
            {{ fullName }}
          </div>
          </q-img>
        </q-card>

      </div>
  </div>
</div>
</template>

<style lang="sass" scoped>
.my-card
  width: 100%
  max-width: 200px

.my-text
  padding: 1px
</style>

<script>
import badActorList from '@hiveio/hivescript/bad-actors.json'
export default {
  name: 'userSearchBox',
  data () {
    return {
      input: this.username,
      fullName: '',
      usernameSuggestions: [],
      badActors: badActorList,
      vscrollAcc: null
    }
  },
  computed: {
    avatarIRI: function () {
      if (this.vscrollAcc && this.vscrollAcc.length > 2) {
        const re = /^(?=.{3,16}$)[a-z]([0-9a-z]|[0-9a-z-](?=[0-9a-z])){2,}([.](?=[a-z][0-9a-z-][0-9a-z-])[a-z]([0-9a-z]|[0-9a-z-](?=[0-9a-z])){1,}){0,}$/
        const validName = this.vscrollAcc.match(re)
        if (validName) {
          return 'https://images.hive.blog/u/' + this.vscrollAcc + '/avatar'
        } else { return null }
      } else {
        return 'unkown_hive_user.png'
      }
    }
  },
  props: ['username', 'label'],
  watch: {
    username: function (newState) {
      this.input = newState
    }
  },
  methods: {
    filterFn (val, update, abort) {
      update(() => {
        this.searchHiveUsernames(val)
      })
    },
    virtualScroll (obj) {
      // Sets the value of the selected item
      this.$hive.api.getAccounts([obj], (err, data) => {
        if (err) {
          console.error(err)
        }
        if (data[0] && data[0].posting_json_metadata) {
          this.fullName = JSON.parse(data[0].posting_json_metadata).profile.name
        } else {
          this.fullName = ''
        }
      })
      this.vscrollAcc = obj
    },
    abortFilterFn () {
    },
    searchHiveUsernames (val) {
      if (val.length < 2) {
        return
      }
      const partialusername = val.toLowerCase()

      this.$hive.api.getAccountReputationsAsync(partialusername, 5, (err, data) => {
        console.log(data)
        if (err) {
          console.error(err)
        } else {
          const accounts = data.map(el => {
            return el.account
          }).filter(el => {
            return this.badActors.indexOf(el) === -1
          })
          this.usernameSuggestions = accounts
        }
      })
    },
    clearInput () {
      this.input = ''
      this.fullName = ''
      this.usernameSuggestions = []
    }
  }
}
</script>
