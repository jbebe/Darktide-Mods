import { defineConfig } from 'vite'
import preact from '@preact/preset-vite'
import { viteSingleFile } from "vite-plugin-singlefile"
import MinifyCssModule from 'vite-minify-css-module/vite'

export default defineConfig({
  plugins: [preact(), viteSingleFile(), MinifyCssModule({
    cleanCSS: {
      level: {
        2: {
          mergeSemantically: true,
          restructureRules: true,
        },
      },
    },
  }),],
  build: {
    minify: 'esbuild'
  },
  css: {
    modules: {
      localsConvention: 'camelCaseOnly'
    }
  }
})
