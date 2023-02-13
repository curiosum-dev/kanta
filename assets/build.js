const esbuild = require('esbuild')

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = { '.svg': 'dataurl', '.png': 'dataurl' }

const plugins = [
  // Add and configure plugins here
]

let opts = {
  entryPoints: ['js/index.js'],
  bundle: true,
  target: 'es2017',
  logLevel: 'info',
  external: ['*.png', '*.svg', '/images/*', '../images/*'],
  outdir: '../priv/static',
  loader,
  plugins
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: 'inline'
  }
}

if (deploy) {
  opts = {
    ...opts,
    sourcemap: true,
    minify: true
  }

  esbuild.build({...opts, format: 'esm', outExtension: { '.js': '.esm.js' }})
  esbuild.build({...opts, format: 'cjs', outExtension: { '.js': '.cjs.js' }})
}

if (watch) {
  const promise = esbuild.context(opts)

  promise.then(_result => {
    console.log("Watching changes...")

    process.stdin.on('close', () => {
      process.exit(0)
    })

    process.stdin.resume()
  })
}