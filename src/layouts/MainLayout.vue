<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar class="bg-red text-white q-my-md shadow-2">
        <q-btn flat round dense icon="menu" class="q-mr-sm" />
        <q-space />
        <q-btn-toggle
          v-model="model"
          flat stretch
          toggle-color="yellow"
          :options="[
            {label: 'Hive to Lightning', value: 'h2l'},
            {label: 'Lightning to Hive', value: 'l2h'},
          ]"
        />
      </q-toolbar>
    </q-header>
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>
<script>

export default {
  name: 'MainLayout',
  data () {
    return {
      model: 'h2l'
    }
  }
}
</script>
