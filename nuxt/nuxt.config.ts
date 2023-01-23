// See: https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: false,
  
  // See: https://nuxt.com/docs/getting-started/installation#prerequisites
  typescript: {
    shim: false
  },

  // Temporary workaround
  // See: https://github.com/nuxt/nuxt/issues/15189
  experimental: {
    writeEarlyHints: false,
  }
})
