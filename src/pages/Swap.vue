<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md row items-start q-gutter-sm">
      <q-card class="my-card q-pa-xs">
        <q-card-section class="q-pa-xs q-ma-sm q-mb-none" align="left">
          <p align="center" class="text-weight-bold">Two options for larger swaps</p>
          <p class="q-mb-none" align="left">Blocktrades <a href="https://blocktrades.us/en/trade?input_coin_type=hive&output_coin_type=btc" target="_blank">Hive to BTC</a>
        or <a href="https://blocktrades.us/en/trade?input_coin_type=btc&output_coin_type=hive" target="_blank">BTC to Hive</a>.
          </p>
        </q-card-section>
        <q-card-actions class="q-mt-none q-pa-none">
          <q-btn  class="q-mt-none q-pa-none" flat color="primary" label="SimpleSwap (Extra Information expand)"
            @click="expanded = !expanded"
          />
          <q-btn
            class="q-mt-none q-pa-none"
            color="grey"
            round
            flat
            dense
            :icon="expanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down'"
            @click="expanded = !expanded"
          />
        </q-card-actions>
        <q-slide-transition>
          <div v-show="expanded">
            <q-separator />
            <q-card-section class="q-mt-none q-pa-sm text-body2">
              <p>SimpleSwap is a 3rd party site which offers access to exchange 300+ cryptocurrencies,
            requires no signup and has a competitive rate.</p>
              <p>Before using the links or this widget read their <a href="https://simpleswap.io/faq?ref=9dc25a08a3d5">FAQ.</a>.</p>
                <p>Any support request must be sent directly to SimpleSwap</p>
                <p>Hive wallet address is as simple as your username.</p>
                <p>Wallet addresses for other crypto currencies are varied in their
                   approach and we suggest you be familiar with the currency
                   you're sending or receiving</p>
                <p>Minimum deposit is usually above $60 USD in your chosen currency,
                  but each currency is different
                After sending currency to SimpleSwap you are done but
                you can watch steps 4-7 progress on the SimpleSwap widget.
                Some swaps can take a long time depending on the type of crypto</p>
                <p>If you have access to a crypto exchange that includes HIVE and know
                how to exchane your currency that way it will be less expensive than this option.</p>
            </q-card-section>
          </div>
        </q-slide-transition>
          <q-card-section align="center">
            <iframe id="simpleswap-frame"
              name="SimpleSwap Widget" width="350px" height="392px"
              src="https://simpleswap.io/widget/b35b515a-eb86-4822-bb7c-fb1029f8d5ea"
              frameborder="0">
            </iframe>
          </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>
<style scoped>
</style>

<script>

export default {
  name: 'PageInfo',
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  computed: {},
  data () {
    return {
      expanded: false
    }
  },
  mounted () {
  },
  methods: {
    tidyNumber (x) {
      if (x) {
        const parts = x.toString().split('.')
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
        return parts.join('.')
      } else {
        return null
      }
    },
    getHiveLink (authperm) { return 'https://hivel.ink/' + authperm }
  }
}
</script>
