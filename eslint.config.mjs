import js from "@eslint/js";
import htmlErb from 'eslint-plugin-html-erb'
import globals from "globals";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    ignores: ["lib/assets/**/*", "vendor/assets/**/*"]
  },
  {
    files: ["**/*.{js,mjs,cjs}"],
    plugins: {
      'js': js,
      'html-erb': htmlErb
    },
    extends: ["js/recommended"],
    languageOptions: { globals: globals.browser }
  },
]);
