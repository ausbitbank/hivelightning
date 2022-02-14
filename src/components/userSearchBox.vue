<template>
  <q-select
    clearable
    new-value-mode="add"
    auto-complete
    :value="input"
    use-input
    hide-selected
    fill-input
    input-debounce="100"
    v-model="input"
    :label="label"
    :options="usernameSuggestions"
    @filter="filterFn"
    @filter-abort="abortFilterFn"
    @input="$emit('selectUsername', input)" />
</template>
<script>
import badActorList from '@hiveio/hivescript/bad-actors.json'
export default {
  name: 'userSearchBox',
  data () {
    return {
      input: this.username,
      usernameSuggestions: [],
      badActors: badActorList
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
      console.log('model set ' + val)
    }
  }
}
</script>
