<template>
  <q-dialog ref="dialog" @hide="onDialogHide">
  <!-- <q-dialog v-model="qrpopup" @show="drawQRcode"> -->
    <q-card class="q-dialog-plugin">
      <q-card-section class="row items-center q-pb-none">
        <div class="text-h6">Send Lightning</div>
        <q-space />
        <q-btn icon="close" flat round dense v-close-popup />
      </q-card-section>
      <q-card-section>
        <!-- <div>
          <div id="qr-code" ref="qrcode" @click="copySelect"></div>
          <div>Click image to copy invoice code</div>
          <q-input
            type="textarea"
            id="copy-text"
            :value="lightningInvoice"
            autogrow
            autofocus
            @click="copySelect"
            ref="copyText" />
        </div> -->
      </q-card-section>
      <q-card-actions align="right">
        <q-btn color="primary" label="OK" @click="onOKClick" />
        <q-btn color="primary" label="Cancel" @click="onCancelClick" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script>
export default {
  props:
    // ...your custom props
    ['lightningInvoice', 'hiveAccname', 'paymentHash'],
  methods: {
    // following method is REQUIRED
    // (don't change its name --> "show")
    show () {
      this.$refs.dialog.show()
    },

    // following method is REQUIRED
    // (don't change its name --> "hide")
    hide () {
      this.$refs.dialog.hide()
    },

    onDialogHide () {
      // required to be emitted
      // when QDialog emits "hide" event
      this.$emit('hide')
    },

    onOKClick () {
      // on OK, it is REQUIRED to
      // emit "ok" event (with optional payload)
      // before hiding the QDialog
      this.$emit('ok')
      // or with payload: this.$emit('ok', { ... })

      // then hiding dialog
      this.hide()
    },

    onCancelClick () {
      // we just need to hide dialog
      this.hide()
    }
  }
}
</script>
