<template>
<div>
  <div class="row items-center q-pa-md">
    <div class="col-10 q-pr-sm">
      <q-select
        clearable
        auto-complete
        :value="input"
        use-input
        hide-selected
        fill-input
        input-debounce="100"
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
        <q-img :src="avatarIRI" width="64px" height="64px"/>
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
      console.log(this.vscrollAcc)
      console.log(this.usernameSuggestions[0])
      console.log(this.input)
      if (this.vscrollAcc) {
        return 'https://images.hive.blog/u/' + this.vscrollAcc + '/avatar'
      } else { return null }
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
    setModel (val) {
      this.input = val
      console.log(this.input)
    },
    clearInput () {
      this.input = ''
      this.usernameSuggestions = []
    }
  }
}
</script>
