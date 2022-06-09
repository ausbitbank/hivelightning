<template>
<div>
  <q-dialog v-model="show" persistent>
    <q-card style="min-width: 350px">
      <q-card-section>
        <div class="text-h6">How many sats to send?</div>
      </q-card-section>

      <q-card-section>
        <q-input dense v-model="amt" autofocus @keyup.enter="prompt = false" />
      </q-card-section>

      <q-card-section class="q-pt-none">
        <q-input dense v-model="cmt" autofocus @keyup.enter="prompt = false" />
      </q-card-section>

      <q-card-actions align="right" class="text-primary">
        <q-btn flat label="Cancel" v-close-popup />
        <q-btn flat label="Send" v-close-popup />
      </q-card-actions>
    </q-card>
  </q-dialog>
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
export default {
  name: 'ammountComment',
  data () {
    return {
      show: true,
      amt: 5000,
      cmt: ''
    }
  },
  computed: {
  },
  props: ['amount', 'comment'],
  watch: {
  },
  methods: {
  },
  mounted () {
    console.log('amount comment')
  }
}
</script>
