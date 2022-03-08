<template>
  <q-page class="flex flex-center">
    <q-card class="my-card">
      <q-card-section>
        <h5>Welcome to the V4V.app Hive Lightning Gateway</h5>
          <p>For help with the app either leave a comment on the Complete Fee Details page below or send a message on <a href="https://t.me/v4vapp">Telegram.</a> </p>
          <span><a :href="getHiveLink(serviceStatus.dynamic_fees_url)" target="_blank">Complete Fee Details on Hive</a></span>
        <h6>Fees:</h6>
        <q-markup-table>
          <thead>
            <tr>
              <th class="text-left"></th>
              <th class="text-right">Sats</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class="text-left">Conversion Fee (flat)</td>
              <td class="text-right">{{ serviceStatus.conv_fee_sats }}</td>
            </tr>
            <tr>
              <td class="text-left">Conversion Fee (percentage)</td>
              <td class="text-right">{{ serviceStatus.conv_fee_percent *100 }}%</td>
            </tr>
            <tr>
              <td class="text-left">Minimum Invoice</td>
              <td class="text-right">{{ tidyNumber(serviceStatus.minimum_invoice_payment_sats) }}</td>
            </tr>
            <tr>
              <td class="text-left">Maximum Invoice</td>
              <td class="text-right">{{ tidyNumber(serviceStatus.maximum_invoice_payment_sats) }}</td>
            </tr>
          </tbody>
        </q-markup-table>
      </q-card-section>
    </q-card>
  </q-page>
</template>
<style scoped>
</style>

<script>
// import MainLayout from 'src/layouts/MainLayout.vue'

export default {
  name: 'PageInfo',
  props: ['prices', 'sendHiveTo', 'serviceStatus'],
  computed: {},
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
