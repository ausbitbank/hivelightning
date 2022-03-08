<template>
<div>
  <div class="row items-center q-pa-md">
    <div class="col-10 q-pr-sm">
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
      <div class="col-2">
        <q-img :src="avatarIRI" width="64px" height="64px" />
      </div>
  </div>
</div>
</template>
<script>
import badActorList from '@hiveio/hivescript/bad-actors.json'
export default {
  name: 'userSearchBox',
  data () {
    return {
      input: this.username,
      usernameSuggestions: [],
      badActors: badActorList,
      vscrollAcc: null
    }
  },
  computed: {
    avatarIRI: function () {
      console.log(this.usernameSuggestions)
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
      console.log(obj)
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
      this.usernameSuggestions = []
    }
  }
}
</script>
