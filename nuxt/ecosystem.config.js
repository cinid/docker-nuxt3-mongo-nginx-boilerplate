module.exports = {
  apps: [
    {
      name: process.env.APP_NAME,
      port: process.env.NUXT_PORT,
      exec_mode: 'cluster',
      instances: 'max',
      script: './.output/server/index.mjs'
    }
  ]
}
